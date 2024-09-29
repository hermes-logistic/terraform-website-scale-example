resource "google_compute_security_policy" "backend" {
  depends_on = [
    google_project_service.iam
  ]
  type = "CLOUD_ARMOR"
  name = join("-", ["waf", local.project_name, local.environment])

  rule {
    action   = "deny(403)"
    priority = "10"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "Block XSS"
  }

  rule {
    action   = "deny(403)"
    priority = "20"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      }
    }
    description = "Block SQL Injection"
  }

  rule {
    action   = "deny(403)"
    priority = "30"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('lfi-v33-stable')"
      }
    }
    description = "Block Inclusión de archivos locales"
  }

  rule {
    action   = "deny(403)"
    priority = "40"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('scannerdetection-v33-stable')"
      }
    }
    description = "Block scanner"
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}

resource "google_compute_security_policy" "edge" {
  depends_on = [
    google_project_service.iam
  ]
  type = "CLOUD_ARMOR_EDGE"
  name = join("-", ["edge", local.project_name, local.environment])

  rule {
    action   = "allow"
    priority = "10"
    match {
      expr {
        expression = "origin.region_code == 'SV'"
      }
    }
    description = "permit all trafict only from"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}