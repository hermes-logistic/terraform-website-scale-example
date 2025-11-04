resource "google_api_gateway_api" "api" {
  depends_on = [ 
    google_project.project,
    google_project_service.apigateway,
    google_project_service.servicecontrol, 
    google_project_service.servicemanagement 
  ]
  provider = google-beta
  project = google_project.project.project_id
  api_id = join("-", [local.project_name, "api", local.environment])
}