/* Development environment for bathrc-accounts-backend.
 *
 * A second copy of the Lambda that runs alongside production without touching it:
 *  - its own DynamoDB tables (dev-*), on-demand so they cost nothing at test volumes
 *  - DynamoDB access limited to the dev-* tables only
 *  - TEST_MODE, so every email goes to the test addresses only
 *  - only accepts the "... DEV" copies of the Jotform forms
 *  - no EventBridge schedule; the hourly job is invoked by hand when testing
 *  - deploys ghcr.io/benjitucker/bathrc-accounts-backend:dev, built from the backend's dev branch
 *
 * IMPORTANT: the :dev image must exist in GHCR before this is applied, and must not be
 * deleted while this module exists, otherwise every plan (including production's) fails.
 */

locals {
  dev_env_name     = "${var.env_name}-dev"
  dev_table_prefix = "dev-"
  dev_tags         = merge(local.tags, { env_name = local.dev_env_name })

  dev_stripe_secret_key_param     = "dev-stripe-secret-key"
  dev_stripe_webhook_secret_param = "dev-stripe-webhook-secret"
  dev_pay_link_secret_param       = "dev-pay-link-secret"
  dev_public_base_url_param       = "dev-public-base-url"
}

module "bathrc-accounts-backend-dev" {
  source = "./lambda"

  lambda_name = "bathrc-accounts-backend-dev"
  image_name  = "bathrc-accounts-backend"
  image_tag   = "dev"

  env_name       = local.dev_env_name
  ghcr_urn       = "ghcr.io/benjitucker"
  subnet_ids     = [local.private_subnet_id]
  vpc_id         = local.vpc_id
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  memory_size = 256

  // Must differ from production's "ssm-parameter-access"
  ssm_policy_name = "ssm-parameter-access-dev"

  // No access to the production tables: only the dev-* tables
  dynamodb_full_access = false
  extra_policy_arns    = [aws_iam_policy.dev_dynamodb_access.arn]

  environment_variables = {
    TEST_MODE         = "true" // all emails go to the test addresses only
    TABLE_NAME_PREFIX = local.dev_table_prefix
    FORM_TITLE_SUFFIX = " DEV"            // only accept "Training DEV" and "Training Administration DEV"
    PAYMENT_MODE      = "stripe"          // enables the post-submission /redirect endpoint
    TRAINING_FORM_ID  = "263062182377357" // the Training DEV form, for the hourly catch-up and /redirect

    // Names of the SSM parameters holding the Stripe secrets (see below)
    STRIPE_SECRET_KEY_PARAM     = local.dev_stripe_secret_key_param
    STRIPE_WEBHOOK_SECRET_PARAM = local.dev_stripe_webhook_secret_param
    PAY_LINK_SECRET_PARAM       = local.dev_pay_link_secret_param
    PUBLIC_BASE_URL_PARAM       = local.dev_public_base_url_param
  }

  tags = local.dev_tags
}

resource "aws_iam_policy" "dev_dynamodb_access" {
  name        = "dev-dynamodb-access"
  description = "Allow the dev Lambda to use the dev-* DynamoDB tables only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = flatten([
          for table in [
            aws_dynamodb_table.dev-training-submissions,
            aws_dynamodb_table.dev-transactions,
            aws_dynamodb_table.dev-members,
          ] : [table.arn, "${table.arn}/index/*"]
        ])
      }
    ]
  })

  tags = local.dev_tags
}

resource "aws_dynamodb_table" "dev-training-submissions" {
  name         = "${local.dev_table_prefix}TrainingSubmissions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "submissionState"
    type = "S"
  }

  attribute {
    name = "trainingDate"
    type = "S"
  }

  global_secondary_index {
    name            = "StateDateIndex"
    hash_key        = "submissionState"
    range_key       = "trainingDate"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "expireAt"
    enabled        = true
  }

  tags = local.dev_tags
}

resource "aws_dynamodb_table" "dev-transactions" {
  name         = "${local.dev_table_prefix}Transactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "txnType"
    type = "S"
  }

  attribute {
    name = "txnDate"
    type = "S"
  }

  global_secondary_index {
    name            = "TypeDateIndex"
    hash_key        = "txnType"
    range_key       = "txnDate"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "expireAt"
    enabled        = true
  }

  tags = local.dev_tags
}

resource "aws_dynamodb_table" "dev-members" {
  name         = "${local.dev_table_prefix}Members"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  tags = local.dev_tags
}

output "dev_jotform_webhook_url" {
  description = "Webhook URL for the Training DEV and Training Administration DEV forms"
  value       = module.bathrc-accounts-backend-dev.function_url
}

# Stripe secrets for the dev Lambda. The key and webhook secret are only stored once they have
# been set in the TF cloud variables; until then the parameters don't exist.
resource "aws_ssm_parameter" "dev_stripe_secret_key" {
  count       = nonsensitive(var.stripe_dev_secret_key != "") ? 1 : 0
  name        = local.dev_stripe_secret_key_param
  description = "Stripe test-mode restricted key for the dev Lambda"
  type        = "SecureString"
  value       = var.stripe_dev_secret_key
  tags        = local.dev_tags
}

resource "aws_ssm_parameter" "dev_stripe_webhook_secret" {
  count       = nonsensitive(var.stripe_dev_webhook_secret != "") ? 1 : 0
  name        = local.dev_stripe_webhook_secret_param
  description = "Signing secret of the dev Stripe webhook endpoint"
  type        = "SecureString"
  value       = var.stripe_dev_webhook_secret
  tags        = local.dev_tags
}

# Signs the payment links in emails and pages. Generated here, so nobody needs to handle it.
resource "random_password" "dev_pay_link_secret" {
  length  = 48
  special = false
}

resource "aws_ssm_parameter" "dev_pay_link_secret" {
  name        = local.dev_pay_link_secret_param
  description = "Signs the dev Lambda's payment links"
  type        = "SecureString"
  value       = random_password.dev_pay_link_secret.result
  tags        = local.dev_tags
}

# The dev Lambda's own address, for the payment links in emails. Read at runtime, so there is
# no dependency cycle between the Lambda and its function URL.
resource "aws_ssm_parameter" "dev_public_base_url" {
  name        = local.dev_public_base_url_param
  description = "The dev Lambda's function URL, for payment links in emails"
  type        = "String"
  value       = trimsuffix(module.bathrc-accounts-backend-dev.function_url, "/")
  tags        = local.dev_tags
}

output "dev_stripe_webhook_url" {
  description = "Register this as the dev webhook endpoint in the Stripe dashboard (test mode)"
  value       = "${module.bathrc-accounts-backend-dev.function_url}stripe-webhook"
}
