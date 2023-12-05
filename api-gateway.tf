resource "aws_iam_role" "s3_proxy_role" {
  name               = "${var.env_name}-s3-proxy-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.s3_proxy_policy.json
}

data "aws_iam_policy_document" "s3_proxy_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "s3_proxy_role_api_gateway_attachment" {
  role       = aws_iam_role.s3_proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_api_gateway_rest_api" "MyS3" {
  name        = "MyS3"
  description = "API for S3 Integration"
}

# S3 Integration:

locals {
  s3_200_response_params = {
    status_code = "200",
    method_response_parameters = {
      "method.response.header.Timestamp"      = true
      "method.response.header.Content-Length" = true
      "method.response.header.Content-Type"   = true
    },
    method_response_models = {
      "application/json" = "Empty"
    },
    integration_response_parameters = {
      "method.response.header.Timestamp"      = "integration.response.header.Date"
      "method.response.header.Content-Length" = "integration.response.header.Content-Length"
      "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
    },
  }

  s3_400_response_params = {
    status_code                   = "400",
    integration_selection_pattern = "4\\d{2}"
  }

  s3_500_response_params = {
    status_code                   = "500",
    integration_selection_pattern = "5\\d{2}"
  }
}

module "ui_api" {
  source                  = "./api"
  parent_id               = aws_api_gateway_rest_api.MyS3.root_resource_id
  path_part               = "ui"
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  http_methods            = ["GET"]
  integration_arn_uri     = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/index.html"
  integration_credentials = aws_iam_role.s3_proxy_role.arn
  integration_http_method = "GET"
  integration_type        = "AWS"
  response_parameters     = [local.s3_200_response_params]
}

module "ui_item_api" {
  source       = "./api"
  parent_id    = module.ui_api.resource_id
  path_part    = "{item}"
  rest_api_id  = aws_api_gateway_rest_api.MyS3.id
  http_methods = ["GET"]

  request_parameters = {
    method_request_parameters      = { "method.request.path.item" = true }
    integration_request_parameters = { "integration.request.path.item" = "method.request.path.item" }
  }
  integration_arn_uri     = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/{item}"
  integration_credentials = aws_iam_role.s3_proxy_role.arn
  integration_http_method = "GET"
  integration_type        = "AWS"
  response_parameters     = [local.s3_200_response_params, local.s3_400_response_params, local.s3_500_response_params]
}

module "callback_api" {
  source                  = "./api"
  parent_id               = module.ui_api.resource_id
  path_part               = "callback"
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  http_methods            = ["GET"]
  integration_arn_uri     = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/index.html"
  integration_credentials = aws_iam_role.s3_proxy_role.arn
  integration_http_method = "GET"
  integration_type        = "AWS"
  response_parameters     = [local.s3_200_response_params, local.s3_400_response_params, local.s3_500_response_params]
}

# Lambda Integration:

module "bathrc-accounts-authorizer" {
  source = "./lambda"

  lambda_name = "bathrc-accounts-authorizer"
  image_tag   = "release"

  env_name       = var.env_name
  ghcr_urn       = "ghcr.io/benjitucker"
  subnet_ids     = local.private_subnet_ids
  vpc_id         = local.vpc_id
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  memory_size = 256

  environment_variables = {
    AUTH0_DOMAIN   = var.auth0_domain
    AUTH0_AUDIENCE = auth0_resource_server.backend.identifier
  }

  tags = local.tags
}

resource "aws_api_gateway_authorizer" "backend" {
  name                             = "bathrc-accounts-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.MyS3.id
  authorizer_uri                   = module.bathrc-accounts-authorizer.invoke_arn
  type                             = "TOKEN"
  authorizer_result_ttl_in_seconds = 300
}

module "backend" {
  source                  = "./api"
  parent_id               = aws_api_gateway_rest_api.MyS3.root_resource_id
  path_part               = "backend"
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  http_methods            = ["GET", "POST"]
  authorizer_id           = aws_api_gateway_authorizer.backend.id
  integration_arn_uri     = module.bathrc-accounts-backend.invoke_arn
  integration_http_method = "POST"
  integration_type        = "AWS_PROXY"
}

module "backend-item" {
  source                  = "./api"
  parent_id               = module.backend.resource_id
  path_part               = "{item}"
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  http_methods            = ["GET", "POST"]
  authorizer_id           = aws_api_gateway_authorizer.backend.id
  integration_arn_uri     = module.bathrc-accounts-backend.invoke_arn
  integration_http_method = "POST"
  integration_type        = "AWS_PROXY"
}

# DEPLOYMENT:

resource "aws_api_gateway_deployment" "S3APIDeployment" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id

  triggers = {
    trigger = join("", [
      module.ui_api.deployment_trigger,
      module.ui_item_api.deployment_trigger,
      module.callback_api.deployment_trigger,
      module.backend.deployment_trigger,
      module.backend-item.deployment_trigger,
      ]
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "S3APIStage" {
  deployment_id = aws_api_gateway_deployment.S3APIDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  stage_name    = "bathrc"
}

resource "aws_api_gateway_usage_plan" "S3API" {
  name = "${var.env_name}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.MyS3.id
    stage  = aws_api_gateway_stage.S3APIStage.stage_name
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 20
  }
}

# OUTPUT:

output "apigw-invoke-url" {
  value = aws_api_gateway_stage.S3APIStage.invoke_url
}

output "ui-url" {
  value = "${aws_api_gateway_stage.S3APIStage.invoke_url}/ui"
}
