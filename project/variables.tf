data "google_client_config" "default" {}

variable "project" {
  type        = string
  description = "value of the project"
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

locals {
  project_name = element(split("-", terraform.workspace), 1)
  environment  = element(split("-", terraform.workspace), 2)
}