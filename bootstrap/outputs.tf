output "state_bucket_names" {
  description = "Terraform state bucket names."
  value       = { for name, bucket in google_storage_bucket.terraform_state : name => bucket.name }
}

