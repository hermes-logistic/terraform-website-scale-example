output "cloudrun_url" {
  value = google_cloud_run_service.spa.status[0].url
}