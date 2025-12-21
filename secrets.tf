resource "aws_ssm_parameter" "jotform-apikey" {
  name        = "bathrc-jotform-apikey"
  description = "API key for Jotform access"
  type        = "SecureString"
  value       = var.jotform_apikey
  tags        = local.tags
}

resource "aws_security_group" "ssm_vpc_endpoint_sg" {
  name        = "ssm-vpc-endpoint-sg"
  description = "Allow Lambda to access SSM endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint_sg.id]
}
