module "bathrc-accounts-backend" {
  source = "./lambda"

  lambda_name = "bathrc-accounts-backend"
  image_tag   = "latest"

  env_name       = var.env_name
  ghcr_urn       = "ghcr.io/benjitucker"
  subnet_ids     = [local.private_subnet_id]
  vpc_id         = local.vpc_id
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  memory_size = 256

  environment_variables = {
    TEST_MODE = "true" // Enable Test mode where emails only go to test addresses
  }

  tags = local.tags
}
