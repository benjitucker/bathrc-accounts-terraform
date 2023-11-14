locals {
  #domain_name = "bathrc.co.uk"
  #subdomain   = "accounts"
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 2.0"

  name          = "bathrc-accounts"
  description   = "Bath RC Accounts API"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = [
      "content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"
    ]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  create_api_domain_name = false

  # Access logs

  # Routes and integrations
  integrations = {
    "GET /hello" = {
      #lambda_arn             = "arn:aws:lambda:eu-west-1:052235179155:function:my-function"
      lambda_arn             = module.bathrc-accounts-backend.arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    #    "GET /some-route-with-authorizer" = {
    #      integration_type = "HTTP_PROXY"
    #      integration_uri  = "some url"
    #      authorizer_key   = "azure"
    #    }

    /*
    "GET /some-route" = {
      lambda_arn               = module.lambda_function.lambda_function_arn
      payload_format_version   = "2.0"
      authorization_type       = "JWT"
      authorizer_id            = aws_apigatewayv2_authorizer.authzero_authorizer.id
      throttling_rate_limit    = 80
      throttling_burst_limit   = 40
      detailed_metrics_enabled = true
    }
    */

    /* Note, API Gateway can be used to proxy the static website hosted in S3, meaning that the static part and rest
     * APIs have the same origin (API GW) and no need for a custom domain
     * See https://repost.aws/knowledge-center/api-gateway-s3-website-proxy
     */
    "GET /ui" = {
      integration_method = "GET"
      integration_type   = "AWS"
      /* See https://docs.aws.amazon.com/apigateway/latest/api/API_PutIntegration.html for the uri details */
      integration_uri        = "arn:aws:apigateway:${var.aws_region}:s3:path/${local.bucket_name}/index.html"
      credentials_arn        = aws_iam_role.s3_proxy_role.arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000

      response_parameters = jsonencode([
        {
          status_code = 200
          mappings = {
            "append:header.timestamp"      = "$response.header.date",
            "append:header.content-length" = "$response.header.content-length",
            "append:header.content-type"   = "$response.header.content-type"
          }
        }
      ])
    }

    "$default" = {
      #lambda_arn = "arn:aws:lambda:eu-west-1:052235179155:function:my-default-function"
      lambda_arn = module.bathrc-accounts-backend.arn
    }
  }

  #  authorizers = {
  #    "azure" = {
  #      authorizer_type  = "JWT"
  #      identity_sources = "$request.header.Authorization"
  #      name             = "azure-auth"
  #      audience         = ["d6a38afd-45d6-4874-d1aa-3c5c558aqcc2"]
  #      issuer           = "https://sts.windows.net/aaee026e-8f37-410e-8869-72d9154873e4/"
  #    }
  #  }

  tags = local.tags
}

output "api-endpoint" {
  value = module.api_gateway.apigatewayv2_api_api_endpoint
}

/*
resource "aws_apigatewayv2_authorizer" "authzero_authorizer" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = random_pet.this.id

  jwt_configuration {
    audience = ["example"]
    issuer   = "https://${aws_cognito_user_pool.this.endpoint}"
  }
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
