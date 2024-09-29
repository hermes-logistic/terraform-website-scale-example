resource "google_artifact_registry_repository" "registry" {
  depends_on = [
    google_project_service.iam
  ]
  project       = data.terraform_remote_state.project.outputs.project_id
  location      = var.region
  repository_id = local.project_name
  description   = "${local.project_name} Registry repository"
  format        = "DOCKER"
  docker_config {
    immutable_tags = true
  }
  cleanup_policy_dry_run = false
  cleanup_policies {
    id     = "delete-prerelease"
    action = "DELETE"
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["alpha", "v0"]
      older_than   = "2592000s"
    }
  }
  cleanup_policies {
    id     = "keep-tagged-release"
    action = "KEEP"
    condition {
      tag_state             = "TAGGED"
      tag_prefixes          = ["release"]
      package_name_prefixes = ["webapp", "mobile"]
    }
  }
  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      package_name_prefixes = ["webapp", "mobile", "sandbox"]
      keep_count            = 5
    }
  }
}