module "bathrc-accounts-backend" {
  source = "./lambda"

  lambda_name = "bathrc-accounts-backend"
  image_tag   = "latest"

  env_name = var.env_name
  ghcr_urn = "ghcr.io/benjitucker"

  // Run the lambda in the public subnet so that it can make outgoing connection to
  // Jotform, without having the expense of a NAT gateway. A security group blocking
  // all inbound traffic protects from external access.
  subnet_ids = local.public_subnet_ids

  vpc_id         = local.vpc_id
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  memory_size = 256

  tags = local.tags
}
