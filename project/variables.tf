data "google_client_config" "default" {}

variable "project" {
  type        = string
  description = "value of the project, project name must be 4 to 30 characters with lowercase and uppercase letters, numbers, hyphen, single-quote, double-quote, space, and exclamation point"
}

variable "org_id" {
  type        = number
  description = "value of the organization id"
}

variable "folder_id" {
  type        = number
  description = "value of the folder id"
}

variable "billing_account_id" {
  type        = string
  description = "value of the billing account id"
}

variable "services" {
  type = map(object({
    name = string
  }))
  default = {
    "network" = {
      name = "network"
    },
    "keycloak" = {
      name = "keycloak"
    }
  }
}

locals {
  project_name = element(split("-", terraform.workspace), 1)
  environment  = element(split("-", terraform.workspace), 2)
}