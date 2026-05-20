locals {
  repository = "${var.github_owner}/${var.github_repository}"
}

resource "google_iam_workload_identity_pool" "this" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions"
  description               = "Federates GitHub Actions OIDC tokens for ResumAI infrastructure."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub"
  description                        = "GitHub Actions OIDC provider for ${local.repository}."

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "assertion.repository_owner == '${var.github_owner}' && assertion.repository == '${local.repository}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "terraform_runner" {
  for_each = var.terraform_runners

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = "Terraform runner for ${each.key} managed by Workload Identity Federation."
}

resource "google_project_iam_member" "terraform_runner_roles" {
  for_each = {
    for pair in flatten([
      for runner_key, runner in var.terraform_runners : [
        for role in runner.roles : {
          key        = "${runner_key}/${role}"
          runner_key = runner_key
          role       = role
        }
      ]
    ]) : pair.key => pair
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.terraform_runner[each.value.runner_key].email}"
}

resource "google_service_account_iam_member" "github_impersonation" {
  for_each = var.terraform_runners

  service_account_id = google_service_account.terraform_runner[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/attribute.ref/${each.value.ref}"
}

resource "google_storage_bucket_iam_member" "state_access" {
  for_each = {
    for runner_key, bucket_name in var.state_bucket_names : runner_key => bucket_name
    if contains(keys(var.terraform_runners), runner_key)
  }

  bucket = each.value
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform_runner[each.key].email}"
}
