output "deployment_trigger" {
  value = sha1(jsonencode([
    var.integration_credentials,
    var.integration_arn_uri,
    var.integration_type,
    var.method_request_parameters,
    var.authorizer_id,
    var.http_methods,
    var.rest_api_id,
    var.path_part,
    var.parent_id,
    var.integration_http_method,
    var.integration_request_parameters,
    var.method_responses,
  ]))
}

output "resource_id" {
  value = aws_api_gateway_resource.api.id
}
