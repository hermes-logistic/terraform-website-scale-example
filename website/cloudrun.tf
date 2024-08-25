data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.spa.location
  project     = google_cloud_run_service.spa.project
  service     = google_cloud_run_service.spa.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service" "spa" {
  depends_on = [
    google_project_service.run
  ]
  name     = join("-", [local.project_name, local.environment])
  location = var.region
  metadata {
    namespace = data.terraform_remote_state.project.outputs.project_id
    annotations = {
      "run.googleapis.com/client-name" = "terraform"
      "run.googleapis.com/ingress"     = "internal-and-cloud-load-balancing"
    }
  }
  template {
    spec {
      service_account_name = google_service_account.spa.email
      containers {
        image = "gcr.io/google-containers/hpa-example"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      metadata[0].annotations["run.googleapis.com/client-name"]
    ]
  }
}

resource "google_compute_region_network_endpoint_group" "spa" {
  depends_on = [
    google_cloud_run_service.spa
  ]
  name                  = join("-", [local.environment, local.project_name])
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_service.spa.name
  }
}