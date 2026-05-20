resource "google_secret_manager_secret" "this" {
  project   = var.project_id
  secret_id = var.secret_id
  labels    = var.labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "this" {
  for_each = var.iam_members

  project   = var.project_id
  secret_id = google_secret_manager_secret.this.secret_id
  role      = each.value.role
  member    = each.value.member
}
