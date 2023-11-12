locals {
  domain_name = "bathrc.co.uk"
  subdomain   = "accounts"
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
  #domain_name                 = "terraform-aws-modules.modules.tf"
  #domain_name_certificate_arn = "arn:aws:acm:eu-west-1:052235179155:certificate/2b3a7ed9-05e1-4f9e-952b-27744ba06da6"
  domain_name                 = local.domain_name
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  # Access logs
  #default_stage_access_log_destination_arn = "arn:aws:logs:eu-west-1:835367859851:log-group:debug-apigateway"
  #default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "POST /" = {
      #lambda_arn             = "arn:aws:lambda:eu-west-1:052235179155:function:my-function"
      lambda_arn             = module.bathrc-accounts-backend.alias
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

    "$default" = {
      #lambda_arn = "arn:aws:lambda:eu-west-1:052235179155:function:my-default-function"
      lambda_arn = module.bathrc-accounts-backend.alias
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

  tags = {
    Name = "bathrc-accounts"
  }
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
