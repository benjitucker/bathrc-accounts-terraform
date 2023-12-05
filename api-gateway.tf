# S3 Integration:

locals {
  s3_response_params = [
    {
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
    },
    {
      status_code                   = "400",
      integration_selection_pattern = "4\\d{2}"
    },
    {
      status_code                   = "500",
      integration_selection_pattern = "5\\d{2}"
    },
  ]
}

/*
module "callback_api" {
  source                  = "./api"
  parent_id               = aws_api_gateway_resource.ui.id
  path_part               = "callback"
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  http_methods            = ["GET"]
  integration_arn_uri     = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/index.html"
  integration_credentials = aws_iam_role.s3_proxy_role.arn
  integration_http_method = "GET"
  integration_type        = "AWS"
  method_responses        = local.s3_method_responses
}
*/

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
  response_parameters = [
    {
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
  ]
}

/*
resource "aws_api_gateway_resource" "ui" {
  parent_id   = aws_api_gateway_rest_api.MyS3.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  path_part   = "ui"
}

resource "aws_api_gateway_method" "ui" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_resource.ui.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "S3Integration-index" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.ui.id
  http_method = aws_api_gateway_method.ui.http_method

  # Included because of this issue: https://github.com/hashicorp/terraform/issues/10501
  integration_http_method = "GET"
  type                    = "AWS"

  uri         = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/index.html"
  credentials = aws_iam_role.s3_proxy_role.arn
}

resource "aws_api_gateway_method_response" "StatusIndex200" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.ui.id
  http_method = aws_api_gateway_method.ui.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Timestamp"      = true
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "IntegrationIndexResponse200" {
  depends_on = [aws_api_gateway_integration.S3Integration-index]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.ui.id
  http_method = aws_api_gateway_method.ui.http_method
  status_code = aws_api_gateway_method_response.StatusIndex200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}
*/

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
  response_parameters     = local.s3_response_params
}

/*
resource "aws_api_gateway_resource" "Item" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  parent_id   = aws_api_gateway_resource.ui.id
  path_part   = "{item}"
}

resource "aws_api_gateway_method" "GetBuckets" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_resource.Item.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.item" = true
  }
}

resource "aws_api_gateway_integration" "S3Integration" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Item.id
  http_method = aws_api_gateway_method.GetBuckets.http_method

  # Included because of this issue: https://github.com/hashicorp/terraform/issues/10501
  integration_http_method = "GET"
  type                    = "AWS"

  uri         = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/{item}"
  credentials = aws_iam_role.s3_proxy_role.arn

  request_parameters = {
    "integration.request.path.item" = "method.request.path.item"
  }
}

resource "aws_api_gateway_method_response" "Status200" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Item.id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Timestamp"      = true
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "Status400" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Item.id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = "400"
}

resource "aws_api_gateway_method_response" "Status500" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Item.id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = "500"
}

resource "aws_api_gateway_integration_response" "IntegrationResponse200" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Item.id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = aws_api_gateway_method_response.Status200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}

resource "aws_api_gateway_integration_response" "IntegrationResponse400" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Item.id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = aws_api_gateway_method_response.Status400.status_code

  selection_pattern = "4\\d{2}"
}

resource "aws_api_gateway_integration_response" "IntegrationResponse500" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Item.id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = aws_api_gateway_method_response.Status500.status_code

  selection_pattern = "5\\d{2}"
}
*/
# Lambda Integration:

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

/*
resource "aws_api_gateway_resource" "backend-lambda" {
  path_part   = "backend"
  parent_id   = aws_api_gateway_rest_api.MyS3.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
}

resource "aws_api_gateway_resource" "backend-item" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  parent_id   = aws_api_gateway_resource.backend-lambda.id
  path_part   = "{item}"
}

resource "aws_api_gateway_method" "backend-lambda-get" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_resource.backend-lambda.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "backend-item-get" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_resource.backend-item.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.item" = true
  }
}

resource "aws_api_gateway_integration" "backend-lambda" {
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  resource_id             = aws_api_gateway_resource.backend-lambda.id
  http_method             = aws_api_gateway_method.backend-lambda-get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.bathrc-accounts-backend.invoke_arn
}

resource "aws_api_gateway_integration" "backend-item" {
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  resource_id             = aws_api_gateway_resource.backend-item.id
  http_method             = aws_api_gateway_method.backend-item-get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.bathrc-accounts-backend.invoke_arn

  request_parameters = {
    "integration.request.path.item" = "method.request.path.item"
  }
}

resource "aws_api_gateway_method" "backend-lambda-post" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_resource.backend-lambda.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "backend-item-post" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_resource.backend-item.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.item" = true
  }
}

resource "aws_api_gateway_integration" "backend-lambda-post" {
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  resource_id             = aws_api_gateway_resource.backend-lambda.id
  http_method             = aws_api_gateway_method.backend-lambda-post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.bathrc-accounts-backend.invoke_arn
}

resource "aws_api_gateway_integration" "backend-item-post" {
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  resource_id             = aws_api_gateway_resource.backend-item.id
  http_method             = aws_api_gateway_method.backend-item-post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.bathrc-accounts-backend.invoke_arn

  request_parameters = {
    "integration.request.path.item" = "method.request.path.item"
  }
}
*/

# DEPLOYMENT:

resource "aws_api_gateway_deployment" "S3APIDeployment" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id

  triggers = {
    trigger = join("", [
      module.ui_api.deployment_trigger,
      module.ui_item_api.deployment_trigger,
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
