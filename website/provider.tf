terraform {
  required_version = "~> 1.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project = data.terraform_remote_state.project.outputs.project_id
  region  = var.region
  zone    = var.zone
}