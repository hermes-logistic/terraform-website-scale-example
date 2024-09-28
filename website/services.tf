resource "google_project_service" "usage" {
  project = data.terraform_remote_state.project.outputs.project_id
  service = "serviceusage.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "iam" {
  depends_on = [
    google_project_service.usage
  ]
  project = data.terraform_remote_state.project.outputs.project_id
  service = "iam.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "run" {
  depends_on = [
    google_project_service.iam,
    google_project_service.usage
  ]
  project = data.terraform_remote_state.project.outputs.project_id
  service = "run.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}