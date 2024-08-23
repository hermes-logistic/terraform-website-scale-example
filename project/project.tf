resource "random_id" "id" {
  byte_length = 4
}

resource "google_project" "project" {
  name       = var.project
  project_id = join("-", [local.project_name, random_id.id.hex])
  folder_id  = var.folder_id
  billing_account = var.billing_account_id
  auto_create_network = false
}