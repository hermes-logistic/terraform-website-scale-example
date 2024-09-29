resource "google_project_service" "run" {
  project = data.terraform_remote_state.project.outputs.project_id
  service = "run.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "artifactregistry" {
  project = data.terraform_remote_state.project.outputs.project_id
  service = "artifactregistry.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}