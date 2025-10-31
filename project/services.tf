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

resource "google_project_service" "iam" {
  depends_on = [
    google_project_service.usage
  ]
  project = google_project.project.project_id
  service = "iam.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "networking" {
  depends_on = [
    google_project_service.iam
  ]
  project = google_project.project.project_id
  service = "servicenetworking.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "connector" {
  depends_on = [
    google_project_service.networking
  ]
  project = google_project.project.project_id
  service = "vpcaccess.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "registry" {
  depends_on = [
    google_project_service.connector
  ]
  project = google_project.project.project_id
  service = "artifactregistry.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "sql" {
  depends_on = [
    google_project_service.registry
  ]
  project = google_project.project.project_id
  service = "sqladmin.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "dns" {
  depends_on = [
    google_project_service.registry
  ]
  project = google_project.project.project_id
  service = "dns.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}