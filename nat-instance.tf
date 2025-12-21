
# Security group for NAT instance
resource "aws_security_group" "nat_sg" {
  name        = "nat-instance-sg"
  description = "Allow HTTPS traffic to and from NAT instance"
  vpc_id      = local.vpc_id

  # Allow inbound SSH (optional)
  #ingress {
  #  from_port   = 22
  #  to_port     = 22
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  # Allow inbound HTTPS traffic from private subnets
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.private_cidr]
  }

  # Allow all outbound HTTPS traffic
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get latest Amazon Linux 2 ARM64 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }
}

# NAT EC2 instance
resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t4g.nano"
  subnet_id                   = local.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]

  # Enable NAT functionality
  user_data = <<-EOF
              #!/bin/bash
              sysctl -w net.ipv4.ip_forward=1
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF

  tags = local.tags
}

# Update route table of private subnet to use the NAT instance
resource "aws_route_table_association" "private_subnets" {
  subnet_id      = local.private_subnet_id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "private" {
  vpc_id = local.vpc_id
  tags   = local.tags
}

# Add default route via NAT instance
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id
}
