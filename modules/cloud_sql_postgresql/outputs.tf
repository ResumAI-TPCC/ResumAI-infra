output "name" {
  description = "Cloud SQL instance name."
  value       = google_sql_database_instance.this.name
}

output "connection_name" {
  description = "Cloud SQL connection name."
  value       = google_sql_database_instance.this.connection_name
}

output "database_names" {
  description = "Managed database names."
  value       = keys(google_sql_database.this)
}
