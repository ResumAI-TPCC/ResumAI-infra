resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
}

resource "google_service_account_iam_member" "this" {
  for_each = var.iam_members

  service_account_id = google_service_account.this.name
  role               = each.value.role
  member             = each.value.member
}

