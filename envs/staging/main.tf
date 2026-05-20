locals {
  common_labels = {
    app       = "resumai"
    env       = var.env
    managedby = "terraform"
  }

  backend_runtime_sa   = "resumai-backend@${var.project_id}.iam.gserviceaccount.com"
  cloud_run_runtime_sa = "367288272676-compute@developer.gserviceaccount.com"
}

module "backend_runtime_sa" {
  source = "../../modules/iam_service_account"

  project_id   = var.project_id
  account_id   = "resumai-backend"
  display_name = "resumai-backend"
  description  = "Service account for ResumAI backend to upload and download resumes from GCS"
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
  image                = "gcr.io/resumai-platform/backend-test:5cee408999ed50730c7e3e4cb277b200d267aed5"
  container_name       = "backend-test-1"
  service_account_name = local.cloud_run_runtime_sa
  ingress              = "all"
  max_scale            = "3"
}
