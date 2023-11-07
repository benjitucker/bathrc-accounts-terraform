locals {
  cidr               = var.vpc_subnet_cidr
  cidrs              = cidrsubnets(local.cidr, 3, 2, 3)
  public_cidr        = local.cidrs[0]
  private_cidr       = local.cidrs[1]
  mongo_peering_cidr = local.cidrs[2]

  /* 3 or less if not available (e.g. us-west-1 is overloaded and only gives us 2 AZs to play with) */
  az_count = min(3, length(data.aws_availability_zones.available.names))
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

module "virtual-network" {
  source      = "./virtual-network"
  description = "bathrc-accounts"
  env_name    = var.env_name

  cidr                 = var.vpc_subnet_cidr
  public_cidr          = local.public_cidr
  public_subnet_count  = local.az_count
  private_cidr         = local.private_cidr
  private_subnet_count = local.az_count
  tags                 = local.tags
}
