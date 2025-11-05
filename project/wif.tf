resource "google_iam_workload_identity_pool" "terraform-pool" {
  depends_on = [ google_project_service.iam ]
  workload_identity_pool_id = "terraform-pool"
  display_name              = "terraform-pool"
  description               = "Workload identity pool for Terraform"
  project                   = google_project.project.project_id
}

resource "google_iam_workload_identity_pool_provider" "oidc-provider-pool" {
  depends_on = [ google_iam_workload_identity_pool.terraform-pool ]
  workload_identity_pool_id          = google_iam_workload_identity_pool.terraform-pool.workload_identity_pool_id
  project                            = google_project.project.project_id
  display_name                       = "Terraform OIDC provider"
  workload_identity_pool_provider_id = "terraform-provider"
  attribute_mapping                  = {
    "attribute.terraform_workspace_name" = "assertion.terraform_workspace_name"
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name"
    "google.subject" = "assertion.sub"
  }
  attribute_condition = "assertion.terraform_organization_name==\"hermes-logistic\""
  oidc {
    issuer_uri        = "https://app.terraform.io"
  }
}

resource "google_iam_workload_identity_pool" "github-pool" {
  depends_on = [ google_project_service.iam ]
  workload_identity_pool_id = "github-pool"
  display_name              = "github-pool"
  description               = "Workload identity pool for Github"
  project                   = google_project.project.project_id
}

resource "google_iam_workload_identity_pool_provider" "github-provider-pool" {
  depends_on = [ google_iam_workload_identity_pool.terraform-pool ]
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-pool.workload_identity_pool_id
  project                            = google_project.project.project_id
  display_name                       = "Github OIDC provider"
  workload_identity_pool_provider_id = "github-provider"
  attribute_mapping                  = {
    "attribute.repository_owner" = "assertion.repository_owner"
    "google.subject" = "assertion.sub"
  }
  attribute_condition = "assertion.repository_owner==\"hermes-logistic\""
  oidc {
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}