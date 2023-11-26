variable "parent_id" {
  type = string
}

variable "path_part" {
  type = string
}

variable "rest_api_id" {
  type = string
}

variable "http_method" {
  type = string
}

variable "authorization" {
  type    = string
  default = "NONE"
}

variable "method_request_parameters" {
  type    = map(bool)
  default = {}
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
  type = string
}

variable "integration_request_parameters" {
  type    = map(string)
  default = {}
}

variable "method_responses" {
  type = list(object({
    status_code                     = string
    method_response_parameters      = optional(map(bool), {})
    method_response_models          = optional(map(string), {})
    integration_response_parameters = optional(map(string), {})
    integration_selection_pattern   = optional(string, null)
  }))
  default = []
}
