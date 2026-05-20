output "pool_name" {
  description = "Full Workload Identity pool resource name."
  value       = google_iam_workload_identity_pool.this.name
}

output "provider_name" {
  description = "Full Workload Identity provider resource name for GitHub Actions auth."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "terraform_runner_emails" {
  description = "Terraform runner service account emails keyed by environment."
  value       = { for key, sa in google_service_account.terraform_runner : key => sa.email }
}

