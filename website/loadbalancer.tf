resource "google_compute_global_address" "spa" {
  name = "website"
}

resource "google_compute_backend_service" "spa" {
  depends_on = [
    google_cloud_run_service.spa,
  ]
  name       = "backend"
  protocol   = "HTTPS"
  enable_cdn = true
  backend {
    group = google_compute_region_network_endpoint_group.spa.id
  }
  compression_mode                = "AUTOMATIC"
  connection_draining_timeout_sec = 300
}

resource "google_compute_managed_ssl_certificate" "www" {
  name = join("-", [local.project_name, "website", "www"])
  managed {
    domains = [
      "hello.hermesv.dev"
    ]
  }
}

resource "google_compute_url_map" "spa" {
  depends_on = [
    google_compute_backend_service.spa,
  ]
  name            = local.project_name
  default_service = google_compute_backend_service.spa.id
  host_rule {
    hosts        = [
      "hello.hermesv.dev"
    ]
    path_matcher = "hello"
  }
  path_matcher {
    name            = "hello"
    default_service = google_compute_backend_service.spa.id
    path_rule {
      paths = [
        "/",
      ]
      service = google_compute_backend_service.spa.id
    }
  }
}