locals {
  mongo_application_username = "application"
  mongo_application_password = random_password.mongo_application_password.result

  mongo_admin_username = "admin"
  mongo_admin_password = random_password.mongo_admin_password.result

  extra_uri_options = "&connectTimeoutMS=60000"

  # If the cluster is created by terraform (for production)
  mongo_uri_srv = mongodbatlas_cluster.default.srv_address

  mongo_application_user_uri_srv = replace(
    "${local.mongo_uri_srv}/${var.mongo_database}${local.extra_uri_options}",
    "mongodb+srv://",
    "mongodb+srv://${local.mongo_application_username}:${local.mongo_application_password}@"
  )

  mongo_region = replace(upper(var.aws_region), "-", "_")
}

data "mongodbatlas_project" "default" {
  name = var.mongo_project
}

resource "mongodbatlas_cluster" "default" {
  project_id = data.mongodbatlas_project.default.id

  name = var.mongo_cluster

  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = local.mongo_region
  provider_instance_size_name = "M0"
}

resource "random_password" "mongo_application_password" {
  length  = 16
  special = false
}

resource "random_password" "mongo_admin_password" {
  length  = 16
  special = false
}

resource "mongodbatlas_project_ip_access_list" "nat_gw" {
  project_id = data.mongodbatlas_project.default.id
  ip_address = aws_eip.nat.public_ip
  comment    = "NAT Gateway (Terraform managed)"
}

resource "mongodbatlas_database_user" "admin" {
  username = local.mongo_admin_username
  password = local.mongo_admin_password

  project_id         = data.mongodbatlas_project.default.id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}

resource "mongodbatlas_database_user" "application" {
  username = local.mongo_application_username
  password = local.mongo_application_password

  project_id         = data.mongodbatlas_project.default.id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}
