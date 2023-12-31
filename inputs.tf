variable "aws_region" {
  // putting all bathrc accounts resources in eu-west-3 (Paris)
  type    = string
  default = "eu-west-3"
}

variable "mongo_database" {
  type    = string
  default = "bathrc-accounts"
}

variable "mongo_project" {
  type    = string
  default = "bathrc-accounts"
}

variable "mongo_cluster" {
  type    = string
  default = "bathrc-accounts"
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

variable "mongo_public_key" {
  type = string
}

variable "mongo_private_key" {
  type = string
}

variable "test_instance" {
  type    = bool
  default = false
}

variable "auth0_domain" {
  type = string
}

variable "auth0_client_id" {
  type = string
}

variable "auth0_client_secret" {
  type = string
}
