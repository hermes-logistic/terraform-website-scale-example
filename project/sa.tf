resource "google_service_account" "network" {
  depends_on = [ google_iam_workload_identity_pool_provider.oidc-provider-pool ]
  for_each = var.services
  account_id = "terraform-${each.value.name}"
  project = google_project.project.project_id
}

resource "google_service_account_iam_member" "sa-member" {
  depends_on = [ google_service_account.network ]
  for_each = var.services
  service_account_id = google_service_account.network[each.key].name
  role = "roles/iam.serviceAccountTokenCreator"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.terraform-pool.name}/attribute.terraform_workspace_name/gcp-${each.value.name}-development-${local.project_name}"
}

resource "google_project_iam_member" "network" {
  count    = contains(values(var.services)[*].name, "network") ? 1 : 0
  project  = google_project.project.project_id
  role     = "roles/networkmanagement.admin"
  member   = "serviceAccount:${google_service_account.network["network"].email}"
  depends_on = [google_service_account.network]
}

resource "google_project_iam_member" "network-compute" {
  count    = contains(values(var.services)[*].name, "network") ? 1 : 0
  project  = google_project.project.project_id
  role     = "roles/compute.networkAdmin"
  member   = "serviceAccount:${google_service_account.network["network"].email}"
  depends_on = [google_service_account.network]
}

resource "google_project_iam_member" "network-vpc" {
  count    = contains(values(var.services)[*].name, "network") ? 1 : 0
  project  = google_project.project.project_id
  role     = "roles/vpcaccess.admin"
  member   = "serviceAccount:${google_service_account.network["network"].email}"
  depends_on = [google_service_account.network]
}

resource "google_project_iam_member" "registry" {
  count    = contains(values(var.services)[*].name, "network") ? 1 : 0
  project  = google_project.project.project_id
  role     = "roles/artifactregistry.admin"
  member   = "serviceAccount:${google_service_account.network["network"].email}"
  depends_on = [google_service_account.network]
}

resource "google_project_iam_member" "compute" {
  count    = contains(values(var.services)[*].name, "keycloak") ? 1 : 0
  project  = google_project.project.project_id
  role     = "roles/compute.admin"
  member   = "serviceAccount:${google_service_account.network["keycloak"].email}"
  depends_on = [google_service_account.network]
}

resource "google_project_iam_member" "sql" {
  count    = contains(values(var.services)[*].name, "keycloak") ? 1 : 0
  project  = google_project.project.project_id
  role     = "roles/cloudsql.admin"
  member   = "serviceAccount:${google_service_account.network["keycloak"].email}"
  depends_on = [google_service_account.network]
}

resource "google_project_iam_member" "sql-client" {
  count    = contains(values(var.services)[*].name, "keycloak") ? 1 : 0
  project  = google_project.project.project_id
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:${google_service_account.network["keycloak"].email}"
  depends_on = [google_service_account.network]
}

resource "google_service_account_iam_member" "kc-client" {
  count    = contains(values(var.services)[*].name, "keycloak") ? 1 : 0
  service_account_id = google_service_account.network["keycloak"].name
  role     = "roles/iam.serviceAccountUser"
  member   = "serviceAccount:${google_service_account.network["keycloak"].email}"
  depends_on = [google_service_account.network]
}