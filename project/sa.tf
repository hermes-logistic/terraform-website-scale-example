resource "google_service_account" "network" {
  depends_on = [ google_iam_workload_identity_pool_provider.oidc-provider-pool ]
  account_id = "terraform-network"
}

resource "google_service_account_iam_member" "sa-member" {
  depends_on = [ google_service_account.network ]
  service_account_id = google_service_account.network.name
  role = "roles/iam.serviceAccountTokenCreator"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.terraform-pool.name}/attribute.terraform_workspace_name/gcp-network-development-${local.project_name}"
}

resource "google_project_iam_member" "eventreceiver" {
  project = var.project
  role    = "roles/networkmanagement.admin"
  member  = "serviceAccount:${google_service_account.network.email}"
}