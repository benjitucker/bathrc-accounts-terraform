variable "parent_id" {
  type = string
}

variable "path_part" {
  type = string
}

variable "rest_api_id" {
  type = string
}

variable "http_methods" {
  type = list(string)
}

variable "integration_http_method" {
  type = string
}

variable "integration_type" {
  type = string
}

variable "integration_arn_uri" {
  type = string
}

variable "integration_credentials" {
  type    = string
  default = null
}

variable "request_parameters" {
  type = object({
    method_request_parameters      = optional(map(bool), {})
    integration_request_parameters = optional(map(string), {})
  })
  default = {
    method_request_parameters      = {},
    integration_request_parameters = {}
  }
}

variable "response_parameters" {
  type = list(object({
    status_code                     = string
    method_response_parameters      = optional(map(bool), {})
    method_response_models          = optional(map(string), {})
    integration_response_parameters = optional(map(string), {})
    integration_selection_pattern   = optional(string, null)
  }))
  default = []
}

variable "authorizer_id" {
  type    = string
  default = null
}
