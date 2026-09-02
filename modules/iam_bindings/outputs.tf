output "project_member_ids" {
  description = "IDs of project IAM member resources."
  value       = { for key, binding in google_project_iam_member.this : key => binding.id }
}

output "service_account_member_ids" {
  description = "IDs of service-account IAM member resources."
  value       = { for key, binding in google_service_account_iam_member.this : key => binding.id }
}
