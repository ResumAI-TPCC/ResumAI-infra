locals {
  common_labels = {
    app       = "resumai"
    env       = var.env
    managedby = "terraform"
  }

  cloud_run_runtime_sa = "cloud-run-prod-runtime@${var.project_id}.iam.gserviceaccount.com"
  prod_deployer_sa     = "deploy-prod@${var.project_id}.iam.gserviceaccount.com"
  legacy_deployer_sa   = "github-actions-sa@${var.project_id}.iam.gserviceaccount.com"
}

module "cloud_run_runtime_sa" {
  source = "../../modules/iam_service_account"

  project_id   = var.project_id
  account_id   = "cloud-run-prod-runtime"
  display_name = "Cloud Run production runtime"
  description  = "Least-privilege runtime identity for the ResumAI production backend."

  iam_members = {
    prod_deployer_runtime_user = {
      role   = "roles/iam.serviceAccountUser"
      member = "serviceAccount:${local.legacy_deployer_sa}"
    }
    wif_prod_deployer_runtime_user = {
      role   = "roles/iam.serviceAccountUser"
      member = "serviceAccount:${local.prod_deployer_sa}"
    }
  }
}

module "resumes_bucket" {
  source = "../../modules/gcs_bucket"

  project_id                  = var.project_id
  name                        = "prod-resumai-resumes"
  location                    = "ASIA-SOUTHEAST1"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  iam_members = {
    cloud_run_bucket_reader = {
      role   = "roles/storage.legacyBucketReader"
      member = "serviceAccount:${local.cloud_run_runtime_sa}"
    }
    cloud_run_object_admin = {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:${local.cloud_run_runtime_sa}"
    }
  }
}

module "gemini_api_key_secret" {
  source = "../../modules/secret_manager"

  project_id = var.project_id
  secret_id  = "prod-gemini-api-key"

  iam_members = {
    cloud_run_secret_accessor = {
      role   = "roles/secretmanager.secretAccessor"
      member = "serviceAccount:${local.cloud_run_runtime_sa}"
    }
    prod_deployer_secret_viewer = {
      role   = "roles/secretmanager.viewer"
      member = "serviceAccount:${local.prod_deployer_sa}"
    }
  }
}

module "backend" {
  source = "../../modules/cloud_run_service"

  project_id           = var.project_id
  name                 = "prod-service"
  location             = var.region
  image                = "gcr.io/resumai-platform/backend-prod:809afb8a50131ab95b35d07234d7e0e735d6607d"
  container_name       = "backend-prod-1"
  service_account_name = local.cloud_run_runtime_sa
  ingress              = "all"
  max_scale            = "10"
  port                 = 8000

  environment_variables = {
    ALLOWED_ORIGINS   = "https://resumai-application.web.app"
    APP_VERSION       = "1.0.0"
    GCP_PROJECT_ID    = var.project_id
    GCS_BUCKET_NAME   = module.resumes_bucket.name
    GCS_OBJECT_PREFIX = "resumes"
    GEMINI_MODEL      = "gemini-3-flash-preview"
    LLM_PROVIDER      = "gemini"
  }

  secret_environment_variables = {
    GEMINI_API_KEY = {
      secret_name = module.gemini_api_key_secret.secret_id
      version     = "latest"
    }
  }
}

