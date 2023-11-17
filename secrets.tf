module "mongo_admin_username_secret" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "~> 1.0"

  name        = "MONGO_ATLAS_API_PK"
  value       = local.mongo_admin_username
  secure_type = true
}

module "mongo_admin_password_secret" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "~> 1.0"

  name        = "MONGO_ATLAS_API_SK"
  value       = local.mongo_admin_password
  secure_type = true
}

module "mongo_project_id_param" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "~> 1.0"

  name  = "MONGO_ATLAS_API_PROJECT_ID"
  value = data.mongodbatlas_project.default.project_id
}
