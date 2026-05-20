resource "google_storage_bucket" "terraform_state" {
  for_each = var.state_buckets

  name                        = each.value
  project                     = var.project_id
  location                    = var.state_bucket_location
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = merge(var.labels, { stack = each.key })

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age                   = 30
      with_state            = "ARCHIVED"
      matches_storage_class = ["STANDARD"]
    }

    action {
      type = "Delete"
    }
  }
}

