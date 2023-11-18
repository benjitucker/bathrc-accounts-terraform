module "mongo_public_key_secret" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "~> 1.0"

  name        = random_password.mongo_public_key_ssm_param_name.result
  value       = var.mongo_public_key
  secure_type = true
}

module "mongo_private_key_secret" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "~> 1.0"

  name        = random_password.mongo_private_key_ssm_param_name.result
  value       = var.mongo_private_key
  secure_type = true
}
