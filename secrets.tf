resource "aws_ssm_parameter" "test_email_address" {
  name        = "test-email-address"
  description = "Email address to send test emails too"
  type        = "SecureString"
  value       = var.test_email_address
  tags        = local.tags
}

resource "aws_ssm_parameter" "test_email_address2" {
  name        = "test-email-address2"
  description = "2nd email address to send test emails too"
  type        = "SecureString"
  value       = var.test_email_address2
  tags        = local.tags
}

resource "aws_ssm_parameter" "club_email_address" {
  name        = "club-email-address"
  description = "email address for the club, used for reply-to"
  type        = "SecureString"
  value       = var.club_email_address
  tags        = local.tags
}

resource "aws_ssm_parameter" "training_email_address" {
  name        = "training-email-address"
  description = "email address for the training emails sender"
  type        = "SecureString"
  value       = var.training_email_address
  tags        = local.tags
}

resource "aws_ssm_parameter" "bathrc_account_number" {
  name        = "bathrc-account-number"
  description = "Account number"
  type        = "SecureString"
  value       = var.account_number
  tags        = local.tags
}

resource "aws_ssm_parameter" "bathrc_sort_code" {
  name        = "bathrc-sort-code"
  description = "Sort code"
  type        = "SecureString"
  value       = var.sort_code
  tags        = local.tags
}

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
