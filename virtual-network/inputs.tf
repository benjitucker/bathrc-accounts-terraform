variable "description" {
  type = string
}

variable "env_name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "tags" {
  type    = map
  default = {}
}

#
# Set this if you want extra private subnets created.
# 
#
variable "public_cidr" {
  type = string
}

variable "public_subnet_count" {
  type = string
}

variable "private_cidr" {
  type = string
}

variable "private_subnet_count" {
  type = string
}

variable "private_extra_cidr" {
  type    = string
  default = "0.0.0.0/32"
}

variable "private_extra_subnet_count" {
  type    = string
  default = "0"
}
