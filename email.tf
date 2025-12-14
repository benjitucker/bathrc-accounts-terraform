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
