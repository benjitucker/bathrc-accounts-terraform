# S3 Integration:

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

resource "aws_api_gateway_resource" "Folder" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  parent_id   = aws_api_gateway_rest_api.MyS3.root_resource_id
  path_part   = "{folder}"
}

resource "aws_api_gateway_resource" "Item" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  parent_id   = aws_api_gateway_resource.Folder.id
  path_part   = "{item}"
}

resource "aws_api_gateway_method" "GetBuckets" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_rest_api.MyS3.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "S3Integration" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
  http_method = aws_api_gateway_method.GetBuckets.http_method

  # Included because of this issue: https://github.com/hashicorp/terraform/issues/10501
  integration_http_method = "GET"

  type = "AWS"

  # See uri description: https://docs.aws.amazon.com/apigateway/api-reference/resource/integration/
  #  uri         = "arn:aws:apigateway:${var.aws_region}:s3:path//"
  #  credentials = aws_iam_role.s3_api_gateway_role.arn
  uri         = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/index.html"
  credentials = aws_iam_role.s3_proxy_role.arn
}

resource "aws_api_gateway_method_response" "Status200" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
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
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = "400"
}

resource "aws_api_gateway_method_response" "Status500" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = "500"
}

resource "aws_api_gateway_integration_response" "IntegrationResponse200" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
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
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = aws_api_gateway_method_response.Status400.status_code

  selection_pattern = "4\\d{2}"
}

resource "aws_api_gateway_integration_response" "IntegrationResponse500" {
  depends_on = [aws_api_gateway_integration.S3Integration]

  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
  http_method = aws_api_gateway_method.GetBuckets.http_method
  status_code = aws_api_gateway_method_response.Status500.status_code

  selection_pattern = "5\\d{2}"
}

# Lambda Integration:

resource "aws_api_gateway_resource" "backend-lambda" {
  path_part   = "backend"
  parent_id   = aws_api_gateway_rest_api.MyS3.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
}

resource "aws_api_gateway_method" "backend-lambda-get" {
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  resource_id   = aws_api_gateway_resource.backend-lambda.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "backend-lambda" {
  rest_api_id             = aws_api_gateway_rest_api.MyS3.id
  resource_id             = aws_api_gateway_resource.backend-lambda.id
  http_method             = aws_api_gateway_method.backend-lambda-get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.bathrc-accounts-backend.invoke_arn
}


# DEPLOYMENT:

resource "aws_api_gateway_deployment" "S3APIDeployment" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.Folder.id,
      aws_api_gateway_resource.Item.id,
      aws_api_gateway_method.GetBuckets.id,
      aws_api_gateway_integration.S3Integration.id,
      aws_api_gateway_resource.backend-lambda.id,
      aws_api_gateway_method.backend-lambda-get.id,
      aws_api_gateway_integration.backend-lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "S3APIStage" {
  deployment_id = aws_api_gateway_deployment.S3APIDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.MyS3.id
  stage_name    = "MyS3"
}


# OUTPUT:

output "apigw-invoke-url" {
  value = aws_api_gateway_stage.S3APIStage.invoke_url
}
