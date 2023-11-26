resource "aws_api_gateway_resource" "api" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "api" {
  rest_api_id        = var.rest_api_id
  resource_id        = aws_api_gateway_resource.api.id
  http_method        = var.http_method
  authorization      = var.authorization
  request_parameters = var.method_request_parameters
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.api.http_method
  integration_http_method = var.integration_http_method
  type                    = var.integration_type
  uri                     = var.integration_arn_uri
  credentials             = var.integration_credentials
  request_parameters      = var.integration_request_parameters
}

resource "aws_api_gateway_method_response" "api" {
  for_each = var.method_responses

  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.api.id
  http_method         = aws_api_gateway_method.api.http_method
  status_code         = each.value.status_code
  response_parameters = each.value.method_response_parameters
  response_models     = each.value.method_response_models
}


resource "aws_api_gateway_integration_response" "IntegrationResponse200" {
  depends_on = [aws_api_gateway_integration.api]
  for_each   = var.method_responses

  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.api.id
  http_method         = aws_api_gateway_method.api.http_method
  status_code         = each.value.status_code
  response_parameters = each.value.integration_response_parameters
  selection_pattern   = each.value.integration_selection_pattern
}
