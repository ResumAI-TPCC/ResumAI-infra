resource "google_sql_database_instance" "this" {
  project             = var.project_id
  name                = var.name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size_gb
    disk_autoresize   = true
    user_labels       = var.labels

    backup_configuration {
      enabled                        = var.backup_enabled
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
    }

    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = var.private_network
    }

    dynamic "database_flags" {
      for_each = var.database_flags

      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_sql_database" "this" {
  for_each = var.databases

  project  = var.project_id
  instance = google_sql_database_instance.this.name
  name     = each.value
}
