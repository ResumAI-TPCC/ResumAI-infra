resource "google_storage_bucket" "this" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = var.public_access_prevention
  labels                      = var.labels
  force_destroy               = false

  dynamic "versioning" {
    for_each = var.versioning_enabled == null ? [] : [var.versioning_enabled]

    content {
      enabled = versioning.value
    }
  }
}

resource "google_storage_bucket_iam_member" "this" {
  for_each = var.iam_members

  bucket = google_storage_bucket.this.name
  role   = each.value.role
  member = each.value.member
}
