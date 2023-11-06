variable "lambda_name" {
  type = string
}

variable "ecr_prefix" {
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
