module "bathrc-accounts-backend" {
  source = "./lambda"

  lambda_name = "bathrc-accounts-backend"
  image_tag   = "release"

  env_name       = var.env_name
  ghcr_urn       = "ghcr.io/benjitucker"
  subnet_ids     = local.private_subnet_ids
  vpc_id         = local.vpc_id
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  memory_size = 256

  environment_variables = {
    MONGO_URI = local.mongo_application_user_uri_srv
  }

  tags = local.tags
}
