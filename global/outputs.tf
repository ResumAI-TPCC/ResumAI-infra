output "workload_identity_provider" {
  description = "Provider name for google-github-actions/auth."
  value       = module.github_workload_identity.provider_name
}

output "terraform_runner_emails" {
  description = "Terraform runner service account emails."
  value       = module.github_workload_identity.terraform_runner_emails
}

