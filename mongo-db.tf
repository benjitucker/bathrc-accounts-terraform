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

  name       = var.mongo_cluster
  num_shards = 1

  replication_factor           = 3
  backup_enabled               = false
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "7.0"

  //Provider Settings "block"
  provider_name               = "AWS"
  disk_size_gb                = 10
  provider_disk_iops          = 100
  provider_volume_type        = "STANDARD"
  provider_instance_size_name = "M10"
  provider_region_name        = local.mongo_region
}

resource "random_password" "mongo_application_password" {
  length  = 16
  special = false
}

resource "random_password" "mongo_admin_password" {
  length  = 16
  special = false
}

resource "mongodbatlas_project_ip_access_list" "peering" {
  project_id = data.mongodbatlas_project.default.id
  cidr_block = local.cidr
  comment    = "vpc-peering (Terraform managed)"
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

resource "mongodbatlas_network_container" "default" {
  project_id       = data.mongodbatlas_project.default.id
  atlas_cidr_block = "192.168.248.0/21"
  provider_name    = "AWS"
  region_name      = local.mongo_region
}

resource "mongodbatlas_network_peering" "default" {
  project_id             = data.mongodbatlas_project.default.id
  container_id           = mongodbatlas_network_container.default.id
  provider_name          = "AWS"
  aws_account_id         = var.aws_account_id
  vpc_id                 = local.vpc_id
  route_table_cidr_block = local.cidr
  accepter_region_name   = var.aws_region
}

resource "aws_vpc_peering_connection_accepter" "default" {
  vpc_peering_connection_id = mongodbatlas_network_peering.default.connection_id
  auto_accept               = true
}

resource "aws_route" "atlas" {
  count                     = local.az_count
  route_table_id            = local.route_table_id[count.index]
  destination_cidr_block    = mongodbatlas_network_peering.default.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.default.connection_id
}
