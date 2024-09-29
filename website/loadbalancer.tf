resource "google_compute_global_address" "spa" {
  name = "website"
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = google_cloud_run_service.spa.name
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.spa.name
  }
}

resource "google_compute_backend_service" "spa" {
  depends_on = [
    google_cloud_run_service.spa,
  ]
  name       = "backend"
  protocol   = "HTTP"
  enable_cdn = true
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
  compression_mode = "AUTOMATIC"
  connection_draining_timeout_sec = 300
  security_policy = "https://www.googleapis.com/compute/v1/${google_compute_security_policy.backend.id}"
  edge_security_policy = google_compute_security_policy.edge.id
}

resource "google_compute_url_map" "spa" {
  depends_on = [
    google_compute_backend_service.spa,
  ]
  name            = local.project_name
  default_service = google_compute_backend_service.spa.id
}

resource "google_compute_managed_ssl_certificate" "spa" {
  name    = join("-", [local.project_name, "app"])
  managed {
    domains = [
      "hello.hermesv.dev"
    ]
  }
}

resource "google_compute_target_https_proxy" "spa" {
  depends_on = [
    google_compute_url_map.spa,
    google_compute_managed_ssl_certificate.spa,
  ]
  name    = local.project_name
  url_map = google_compute_url_map.spa.self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.spa.id,
  ]
}

resource "google_compute_target_http_proxy" "spa" {
  name    = local.project_name
  url_map = google_compute_url_map.spa.id
}

resource "google_compute_global_forwarding_rule" "spa" {
  depends_on = [
    google_compute_target_https_proxy.spa,
    google_compute_global_address.spa
  ]
  name       = local.project_name
  target     = google_compute_target_https_proxy.spa.self_link
  ip_address = google_compute_global_address.spa.address
  port_range = "443"
}

resource "google_compute_global_forwarding_rule" "spa_http" {
  depends_on = [
    google_compute_target_http_proxy.spa,
    google_compute_global_address.spa
  ]
  name       = "${local.project_name}-http"
  target     = google_compute_target_http_proxy.spa.self_link
  ip_address = google_compute_global_address.spa.address
  port_range = "80"
}