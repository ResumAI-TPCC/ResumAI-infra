output "id" {
  description = "Cloud Tasks queue ID."
  value       = google_cloud_tasks_queue.this.id
}

output "name" {
  description = "Cloud Tasks queue name."
  value       = google_cloud_tasks_queue.this.name
}
