resource "google_project_service" "cloudresourcemanager" {
  project = google_project.project.project_id
  service = "cloudresourcemanager.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "usage" {
  depends_on = [
    google_project_service.cloudresourcemanager
   ]
  project = google_project.project.project_id
  service = "serviceusage.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}