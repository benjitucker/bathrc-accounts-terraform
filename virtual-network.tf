locals {
  cidr         = var.vpc_subnet_cidr
  cidrs        = cidrsubnets(local.cidr, 3, 2, 3)
  public_cidr  = local.cidrs[0]
  private_cidr = local.cidrs[1]
  /* cidr[2] unused */

  /* 3 or less if not available (e.g. us-west-1 is overloaded and only gives us 2 AZs to play with) */
  az_count = min(3, length(data.aws_availability_zones.available.names))
  azs      = slice(data.aws_availability_zones.available.names, 0, local.az_count)

  #vpc_id          = module.virtual-network.vpc_id
  #route_table_id  = module.virtual-network.route_table_id
  #virtual_network = module.virtual-network
  #private_subnet = local.virtual_network.private_subnet[*]

  vpc_id             = module.vpc.vpc_id
  route_table_id     = module.vpc.private_route_table_ids[0]
  private_subnet_ids = module.vpc.private_subnets
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

/*
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
*/

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "main"
  #  cidr                 = "172.18.0.0/16"
  cidr = var.vpc_subnet_cidr
  #azs                  = ["us-west-2a", "us-west-2b", "us-west-2c"]
  azs = local.azs
  #private_subnets      = ["172.18.64.0/20", "172.18.80.0/20", "172.18.96.0/20"]
  #public_subnets       = ["172.18.128.0/20", "172.18.144.0/20", "172.18.160.0/20"]
  private_subnets      = [local.private_cidr]
  public_subnets       = [local.public_cidr]
  enable_dns_hostnames = true
}

module "nat" {
  source  = "int128/nat-instance/aws"
  version = "~> 2.0"

  name                        = "main"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "nat-instance-main"
  }
}
