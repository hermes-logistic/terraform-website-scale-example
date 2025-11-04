output "project_id" {
  value = google_project.project.project_id
}

output "wif_provider" {
  value = google_iam_workload_identity_pool_provider.oidc-provider-pool.name
}

output "service_account" {
  value = {
    for k, v in google_service_account.network : k => v.email
  }
}

output "apigateway_api_id" {
  value = google_api_gateway_api.api.api_id
  
}