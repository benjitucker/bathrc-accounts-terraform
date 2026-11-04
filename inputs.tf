variable "aws_region" {
  // putting all bathrc accounts resources in eu-west-3 (Paris)
  type    = string
  default = "eu-west-3"
}

variable "env_name" {
  type    = string
  default = "bathrc-accounts"
}

variable "vpc_subnet_cidr" {
  type    = string
  default = "10.106.80.0/21"
}

# These come from the TF cloud variables (https://app.terraform.io/app/benjitucker-bathrc/workspaces/bathrc-accounts/variables):
variable "aws_account_id" {
  type = string
}

variable "github_pat" {
  type      = string
  sensitive = true
}

variable "jotform_apikey" {
  type      = string
  sensitive = true
}

variable "account_number" {
  type      = string
  sensitive = true
}

variable "sort_code" {
  type      = string
  sensitive = true
}

variable "test_email_address" {
  type      = string
  sensitive = true
}

variable "test_email_address2" {
  type      = string
  sensitive = true
}

variable "club_email_address" {
  type      = string
  sensitive = true
}

variable "training_email_address" {
  type      = string
  sensitive = true
}

# Stripe (dev environment). Both are optional: while empty, no SSM parameter is created and the
# dev Lambda reports the missing setting when a payment is attempted. They come from the TF cloud
# variables, marked sensitive.
variable "stripe_dev_secret_key" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Stripe test-mode restricted key (rk_test_...) for the dev Lambda, with Checkout Sessions: Write"
}

variable "stripe_dev_webhook_secret" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Signing secret (whsec_...) of the dev Stripe webhook endpoint"
}
