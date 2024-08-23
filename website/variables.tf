data "google_client_config" "default" {}

variable "region" {
  type        = string
  description = "value of the region"
}

variable "zone" {
  type        = string
  description = "value of the zone"
}

variable "sa_website_roles" {
  type        = list(string)
  description = "roles for the service account"
  default     = []
}

variable "organization" {
  type        = string
  default     = "hermes-logistic"
  description = "terraform cloud organization"
}

variable "gcp_workspace" {
  type        = string
  description = "workspace on created resources network"
}

data "terraform_remote_state" "project" {
  backend = "remote"

  config = {
    organization = var.organization
    workspaces = {
      name = var.gcp_workspace
    }
  }
}


locals {
  project_name = element(split("-", terraform.workspace), 1)
  environment  = element(split("-", terraform.workspace), 2)
}