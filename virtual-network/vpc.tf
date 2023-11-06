resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = merge(var.tags, {
    Name        = var.env_name
    Description = var.description
  })
}

