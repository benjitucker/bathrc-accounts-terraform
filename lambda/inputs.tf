variable "lambda_name" {
  type = string
}

variable "ghcr_urn" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "env_name" {
  type = string
}

variable "arch" {
  type    = string
  default = "x86_64"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "memory_size" {
  type    = string
  default = "128"
}

variable "timeout" {
  type    = string
  default = "180"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources that support them"
  default     = {}
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "image_name" {
  type        = string
  description = "Name of the image in GHCR to deploy. Defaults to lambda_name."
  default     = null
}

variable "ssm_policy_name" {
  type        = string
  description = "Name of the IAM policy that lets the Lambda read SSM parameters. Must be unique per Lambda."
  default     = "ssm-parameter-access"
}

variable "dynamodb_full_access" {
  type        = bool
  description = "Attach AmazonDynamoDBFullAccess. Set false and pass a narrower policy in extra_policy_arns instead."
  default     = true
}

variable "extra_policy_arns" {
  type        = list(string)
  description = "Additional IAM policy ARNs to attach to the Lambda role."
  default     = []
}
