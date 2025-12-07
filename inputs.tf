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

# These come from the TF cloud variables (https://app.terraform.io/app/bathrc-accounts/workspaces/bathrc-accounts/variables):
variable "aws_account_id" {
  type = string
}
