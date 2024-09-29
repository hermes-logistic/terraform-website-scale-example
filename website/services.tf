resource "google_project_service" "run" {
  depends_on = [
    google_project_service.iam,
  ]
  project = data.terraform_remote_state.project.outputs.project_id
  service = "run.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}