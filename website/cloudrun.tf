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
  }
  template {
    spec {
      service_account_name = google_service_account.spa.email
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations,
      template.0.spec.0.containers.0.image
    ]
  }
}