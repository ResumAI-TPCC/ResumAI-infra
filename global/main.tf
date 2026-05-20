module "github_workload_identity" {
  source = "../modules/workload_identity"

  project_id        = var.project_id
  pool_id           = "github-actions"
  provider_id       = "github"
  github_owner      = var.github_owner
  github_repository = var.github_repository
  additional_github_repositories = [
    "${var.github_owner}/ResumAI",
  ]

  state_bucket_names = {
    global  = "resumai-infra-tfstate-global"
    staging = "resumai-infra-tfstate-staging"
    prod    = "resumai-infra-tfstate-prod"
  }

  terraform_runners = {
    global = {
      account_id   = "tf-runner-global"
      display_name = "Terraform Runner Global"
      ref          = "refs/heads/main"
      roles = [
        "roles/iam.serviceAccountAdmin",
        "roles/iam.workloadIdentityPoolAdmin",
        "roles/resourcemanager.projectIamAdmin",
        "roles/storage.admin",
      ]
    }
    staging = {
      account_id   = "tf-runner-staging"
      display_name = "Terraform Runner Staging"
      ref          = "refs/heads/develop"
      roles = [
        "roles/artifactregistry.admin",
        "roles/cloudsql.admin",
        "roles/cloudtasks.admin",
        "roles/iam.serviceAccountAdmin",
        "roles/iam.serviceAccountUser",
        "roles/run.admin",
        "roles/secretmanager.admin",
        "roles/storage.admin",
      ]
    }
    prod = {
      account_id   = "tf-runner-prod"
      display_name = "Terraform Runner Prod"
      ref          = "refs/heads/main"
      roles = [
        "roles/artifactregistry.admin",
        "roles/cloudsql.admin",
        "roles/cloudtasks.admin",
        "roles/iam.serviceAccountAdmin",
        "roles/iam.serviceAccountUser",
        "roles/run.admin",
        "roles/secretmanager.admin",
        "roles/storage.admin",
      ]
    }
  }
}

resource "google_service_account" "deploy_staging" {
  project      = var.project_id
  account_id   = "deploy-staging"
  display_name = "Deploy Staging"
  description  = "GitHub Actions deployer for ResumAI QA/staging Cloud Run."
}

resource "google_project_iam_member" "deploy_staging_roles" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
    "roles/secretmanager.viewer",
    "roles/storage.admin",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.deploy_staging.email}"
}

resource "google_service_account_iam_member" "github_deploy_staging" {
  service_account_id = google_service_account.deploy_staging.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${module.github_workload_identity.pool_name}/subject/repo:${var.github_owner}/ResumAI:ref:refs/heads/develop"
}
