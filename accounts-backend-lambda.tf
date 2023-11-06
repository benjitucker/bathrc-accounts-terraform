module "compliance-lambda" {
  source = "./lambda"

  lambda_name = "bathrc-accounts-backend"
  image_tag   = "release"

  env_name   = var.env_name
  ecr_prefix = "ghcr.io/benjitucker"
  subnet_ids = local.private_subnet.*.id
  vpc_id     = local.vpc_id

  memory_size = 256
}
