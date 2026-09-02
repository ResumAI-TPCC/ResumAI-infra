resource "google_cloud_run_service" "this" {
  name     = var.name
  project  = var.project_id
  location = var.location

  metadata {
    labels = var.labels
    annotations = merge({
      "run.googleapis.com/ingress" = var.ingress
    }, var.metadata_annotations)
  }

  template {
    metadata {
      annotations = merge({
        "autoscaling.knative.dev/maxScale" = var.max_scale
      }, var.template_annotations)
    }

    spec {
      service_account_name = var.service_account_name

      containers {
        name  = var.container_name
        image = var.image

        ports {
          container_port = var.port
        }

        dynamic "env" {
          for_each = var.environment_variables

          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = var.secret_environment_variables

          content {
            name = env.key

            value_from {
              secret_key_ref {
                name = env.value.secret_name
                key  = env.value.version
              }
            }
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
      template,
      traffic,
    ]
  }
}

