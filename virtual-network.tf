locals {
  cidr         = var.vpc_subnet_cidr
  cidrs        = cidrsubnets(local.cidr, 3, 2, 3)
  public_cidr  = local.cidrs[0]
  private_cidr = local.cidrs[1]
  /* cidr[2] unused */

  /* 3 or less if not available (e.g. us-west-1 is overloaded and only gives us 2 AZs to play with) */
  az_count = min(3, length(data.aws_availability_zones.available.names))
  azs      = slice(data.aws_availability_zones.available.names, 0, local.az_count)

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                 = "bathrc-accounts"
  cidr                 = var.vpc_subnet_cidr
  azs                  = local.azs
  private_subnets      = [local.private_cidr]
  public_subnets       = [local.public_cidr]
  enable_dns_hostnames = true
  tags                 = local.tags
}

module "nat" {
  source  = "int128/nat-instance/aws"
  version = "~> 2.0"

  name                        = "bathrc-accounts"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids

  user_data_write_files = [
    {
      path : "/mongo-whitelist.sh",
      content : file("/mongo-whitelist.sh"),
      permissions : "0755",
    },
  ]
  user_data_runcmd = [
    ["/mongo-whitelist.sh"],
    ["rm", "/mongo-whitelist.sh"],
  ]
}
