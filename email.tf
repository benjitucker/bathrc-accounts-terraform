resource "aws_ses_domain_identity" "bathridingclub" {
  domain = "bathridingclub.co.uk"
}

resource "aws_ses_domain_dkim" "bathridingclub" {
  domain = aws_ses_domain_identity.bathridingclub.domain
}

resource "aws_ses_email_identity" "training_email" {
  email = "training@bathridingclub.co.uk"
}

output "ses_verification_token" {
  description = "ses_verification_token → TXT record in 123-reg for domain verification."
  value       = aws_ses_domain_identity.bathridingclub.verification_token
}

output "ses_dkim_tokens" {
  description = "ses_dkim_tokens → 3 CNAME records for DKIM."
  value       = aws_ses_domain_dkim.bathridingclub.dkim_tokens
}

/* Removed the expensive SES VPC endpoint as the NAT instance is now cheaper.
# Security group for the VPC endpoint
resource "aws_security_group" "ses_vpc_endpoint_sg" {
  name        = "ses-vpc-endpoint-sg"
  description = "Allow Lambda to access SES endpoint"
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

# VPC Endpoint for SES (API, not SMTP)
resource "aws_vpc_endpoint" "ses" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.email"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ses_vpc_endpoint_sg.id]
  subnet_ids          = module.vpc.private_subnets
}
 */
