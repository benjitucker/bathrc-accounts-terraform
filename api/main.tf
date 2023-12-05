resource "aws_api_gateway_resource" "api" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "api" {
  for_each = toset(var.http_methods)

  rest_api_id        = var.rest_api_id
  resource_id        = aws_api_gateway_resource.api.id
  http_method        = each.key
  authorization      = var.authorizer_id == null ? "NONE" : "CUSTOM"
  authorizer_id      = var.authorizer_id
  request_parameters = var.request_parameters.method_request_parameters
}

resource "aws_api_gateway_integration" "api" {
  for_each = aws_api_gateway_method.api

  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = each.value.http_method
  integration_http_method = var.integration_http_method
  type                    = var.integration_type
  uri                     = var.integration_arn_uri
  credentials             = var.integration_credentials
  request_parameters      = var.request_parameters.integration_request_parameters
}

locals {
  method_response_params = distinct(flatten([
    for http_method in var.http_methods : [
      for method_response in var.response_parameters : {
        http_method     = http_method
        method_response = method_response
      }
    ]
  ]))
}

resource "aws_api_gateway_method_response" "api" {
  depends_on = [
    aws_api_gateway_method.api
  ]

  for_each = {
    for entry in local.method_response_params :
    "${entry.http_method}.${entry.method_response.status_code}" => entry
  }

  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.api.id
  http_method         = each.value.http_method
  status_code         = each.value.method_response.status_code
  response_parameters = each.value.method_response.method_response_parameters
  response_models     = each.value.method_response.method_response_models
}

resource "aws_api_gateway_integration_response" "api" {
  depends_on = [
    aws_api_gateway_method.api,
    aws_api_gateway_integration.api,
    aws_api_gateway_method_response.api
  ]

  for_each = {
    for entry in local.method_response_params :
    "${entry.http_method}.${entry.method_response.status_code}" => entry
  }

  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.api.id
  http_method         = each.value.http_method
  status_code         = each.value.method_response.status_code
  response_parameters = each.value.method_response.integration_response_parameters
  selection_pattern   = each.value.method_response.integration_selection_pattern
}
