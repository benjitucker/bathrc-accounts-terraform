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

locals {
  whitelist_script_template_vars = {
    SERVICE_NAME                  = "bathrc-accounts"
    MONGODB_ATLAS_PUBLIC_API_KEY  = random_password.mongo_public_key_ssm_param_name.result
    MONGODB_ATLAS_PRIVATE_API_KEY = random_password.mongo_private_key_ssm_param_name.result
    MONGODB_ATLAS_ORG_ID          = data.mongodbatlas_project.default.org_id
    MONGODB_ATLAS_PROJECT_ID      = data.mongodbatlas_project.default.project_id
  }
}

resource "random_password" "mongo_public_key_ssm_param_name" {
  length  = 16
  special = false
}

resource "random_password" "mongo_private_key_ssm_param_name" {
  length  = 16
  special = false
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
      content : templatefile("${path.module}/mongo-whitelist.sh", local.whitelist_script_template_vars),
      permissions : "0755",
    },
    {
      path : "/etc/yum.repos.d/mongodb-org-6.0.repo",
      content : file("${path.module}/mongodb-org-6.0.repo"),
      permissions : "0755",
    },
  ]
  user_data_runcmd = [
    ["yum", "install", "-y", "jq", "mongodb-atlas-cli"],
    ["/mongo-whitelist.sh"],
    ["rm", "/mongo-whitelist.sh"],
  ]
}
