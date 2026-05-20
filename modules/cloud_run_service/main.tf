resource "google_cloud_run_service" "this" {
  name     = var.name
  project  = var.project_id
  location = var.location

  metadata {
    annotations = {
      "run.googleapis.com/ingress"  = var.ingress
      "run.googleapis.com/maxScale" = var.max_scale
    }
  }

  template {
    spec {
      service_account_name = var.service_account_name

      containers {
        name  = var.container_name
        image = var.image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
      template,
      traffic,
    ]
  }
}

