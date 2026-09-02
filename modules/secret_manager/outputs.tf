output "id" {
  description = "Secret resource ID."
  value       = google_secret_manager_secret.this.id
}

output "name" {
  description = "Secret resource name."
  value       = google_secret_manager_secret.this.name
}

output "secret_id" {
  description = "Short Secret Manager secret ID."
  value       = google_secret_manager_secret.this.secret_id
}

