resource "google_project_iam_member" "this" {
  for_each = var.project_members

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_service_account_iam_member" "this" {
  for_each = var.service_account_members

  service_account_id = each.value.service_account_id
  role               = each.value.role
  member             = each.value.member
}
