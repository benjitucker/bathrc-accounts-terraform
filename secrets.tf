resource "aws_ssm_parameter" "jotform-apikey" {
  name        = "bathrc-jotform-apikey"
  description = "API key for Jotform access"
  type        = "SecureString"
  value       = var.jotform_apikey
  tags        = local.tags
}
