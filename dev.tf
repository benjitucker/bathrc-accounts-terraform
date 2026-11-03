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
    FORM_TITLE_SUFFIX = " DEV" // only accept "Training DEV" and "Training Administration DEV"
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
