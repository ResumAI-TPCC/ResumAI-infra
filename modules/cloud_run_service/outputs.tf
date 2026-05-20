output "name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_service.this.name
}

output "status_url" {
  description = "Cloud Run service URL."
  value       = google_cloud_run_service.this.status[0].url
}

