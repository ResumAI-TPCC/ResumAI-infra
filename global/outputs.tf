output "workload_identity_provider" {
  description = "Provider name for google-github-actions/auth."
  value       = module.github_workload_identity.provider_name
}

output "terraform_runner_emails" {
  description = "Terraform runner service account emails."
  value       = module.github_workload_identity.terraform_runner_emails
}

output "deploy_staging_email" {
  description = "GitHub Actions deployer service account for QA/staging."
  value       = google_service_account.deploy_staging.email
}

output "deploy_prod_email" {
  description = "Keyless GitHub Actions deployer service account for production."
  value       = google_service_account.deploy_prod.email
}

output "terraform_plan_readonly_email" {
  description = "Read-only GitHub Actions identity used for post-merge plans."
  value       = google_service_account.terraform_plan_readonly.email
}
