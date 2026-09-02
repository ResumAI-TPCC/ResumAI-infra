locals {
  common_labels = {
    app       = "resumai"
    env       = var.env
    managedby = "terraform"
  }

  backend_runtime_sa   = "resumai-backend@${var.project_id}.iam.gserviceaccount.com"
  cloud_run_runtime_sa = "cloud-run-staging-runtime@${var.project_id}.iam.gserviceaccount.com"
  deploy_staging_sa    = "deploy-staging@${var.project_id}.iam.gserviceaccount.com"
}

module "backend_runtime_sa" {
  source = "../../modules/iam_service_account"

  project_id   = var.project_id
  account_id   = "resumai-backend"
  display_name = "resumai-backend"
  description  = "Service account for ResumAI backend to upload and download resumes from GCS"
}

module "cloud_run_runtime_sa" {
  source = "../../modules/iam_service_account"

  project_id   = var.project_id
  account_id   = "cloud-run-staging-runtime"
  display_name = "Cloud Run staging runtime"
}

resource "google_service_account_iam_member" "deploy_staging_runtime_user" {
  service_account_id = module.cloud_run_runtime_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.deploy_staging_sa}"
}

module "github_actions_sa" {
  source = "../../modules/iam_service_account"

  project_id   = var.project_id
  account_id   = "github-actions-sa"
  display_name = "github-actions-sa"
  description  = "Service account for GitHub Actions CI/CD."
}

module "resumes_bucket" {
  source = "../../modules/gcs_bucket"

  project_id                  = var.project_id
  name                        = "resumai-platform-resumes"
  location                    = "ASIA-SOUTHEAST1"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  iam_members = {
    backend_object_creator = {
      role   = "roles/storage.objectCreator"
      member = "serviceAccount:${local.backend_runtime_sa}"
    }
    backend_object_viewer = {
      role   = "roles/storage.objectViewer"
      member = "serviceAccount:${local.backend_runtime_sa}"
    }
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
  secret_id  = "gemini-api-key"

  iam_members = {
    cloud_run_secret_accessor = {
      role   = "roles/secretmanager.secretAccessor"
      member = "serviceAccount:${local.cloud_run_runtime_sa}"
    }
  }
}

module "backend" {
  source = "../../modules/cloud_run_service"

  project_id           = var.project_id
  name                 = "test-service"
  location             = var.region
  image                = "gcr.io/resumai-platform/backend-test:dab14e4e02145e4af58a8281d81c375b2b8015f6"
  container_name       = "backend-test-1"
  service_account_name = local.cloud_run_runtime_sa
  ingress              = "all"
  max_scale            = "3"
  port                 = 8000

  environment_variables = {
    ALLOWED_ORIGINS   = "https://resumai-platform.web.app"
    APP_VERSION       = "QA"
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
