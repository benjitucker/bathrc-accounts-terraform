# IGW for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.env_name}-gw"
  })
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

locals {
  /* 3 or less if not available (e.g. us-west-1 is overloaded and only gives us 2 AZs to play with) */
  az_count      = min(3, length(data.aws_availability_zones.available.names))
  public_count  = min(local.az_count, var.public_subnet_count)
  private_count = min(local.az_count, var.private_subnet_count)
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count = local.private_count

  cidr_block        = cidrsubnet(var.private_cidr, 3, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.env_name}-private-${data.aws_availability_zones.available.names[count.index]}"
  })
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count = local.public_count

  cidr_block              = cidrsubnet(var.public_cidr, 3, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.env_name}-public-${data.aws_availability_zones.available.names[count.index]}"
  })
}

resource "aws_subnet" "private-extra" {
  count = var.private_extra_subnet_count

  cidr_block        = cidrsubnet(var.private_extra_cidr, 3, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.env_name}-private-extra-${data.aws_availability_zones.available.names[count.index]}"
  })
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "nat" {
  count      = local.private_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat" {
  count         = local.private_count
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.nat[*].id, count.index)

  tags = {
    Name = "${var.env_name}-pac-${count.index}"
  }
}

# Create a new route table for the private subnets
# And make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = local.private_count
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.env_name}-private-${count.index}"
  })
}

resource "aws_route" "private" {
  count = local.private_count

  route_table_id = aws_route_table.private[count.index].id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = local.private_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
