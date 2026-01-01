
# Security group for NAT instance
resource "aws_security_group" "nat_ec2_sg" {
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

  # Allow inbound HTTPS traffic from the private subnet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Allow all HTTPS traffic from the VPC CIDR"
  }

  # Allow all HTTPS outbound traffic
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.tags
}

# Fetch the latest ARM64 Amazon Linux 2023 AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"] # Using ARM for cost optimization
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Create the NAT instance in the public subnet
resource "aws_instance" "nat_ec2_instance" {
  instance_type = "t4g.nano" # ARM-based instance for cost optimization
  ami           = data.aws_ami.latest_amazon_linux.id
  subnet_id     = local.public_subnet_id

  # Bootstrap script to configure NAT functionality
  user_data = <<-EOF
#!/bin/bash
sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/custom-ip-forwarding.conf
sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf
sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo service iptables save
EOF

  source_dest_check      = false # Required for NAT functionality
  vpc_security_group_ids = [aws_security_group.nat_ec2_sg.id]

  tags = local.tags
}

# Use the existing private route tables from the VPC module
resource "aws_route" "private_nat_route" {
  route_table_id         = local.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_ec2_instance.primary_network_interface_id
}
