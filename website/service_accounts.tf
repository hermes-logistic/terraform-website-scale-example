resource "google_service_account" "spa" {
  account_id   = join("-", [local.project_name, local.environment])
  display_name = "Service Account for Cloud Run website"
}

resource "google_project_iam_member" "spa" {
  for_each = toset(var.sa_website_roles)
  project  = data.terraform_remote_state.project.outputs.project_id
  role     = "roles/${each.value}"
  member   = "serviceAccount:${google_service_account.spa.email}"
}