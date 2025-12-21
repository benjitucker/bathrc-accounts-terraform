locals {
  lambda_policy = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonSESFullAccess",
    aws_iam_policy.ssm_access.arn
  ]

  lambda_policy_count  = length(local.lambda_policy)
  lambda_function_name = var.lambda_name

  default_environment = {
    ENV_NAME = var.env_name
  }
}

resource "aws_iam_policy" "ssm_access" {
  name        = "ssm-parameter-access"
  description = "Allow Lambda to read all SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${local.lambda_function_name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role" {
  role       = aws_iam_role.iam_for_lambda.name
  count      = local.lambda_policy_count
  policy_arn = local.lambda_policy[count.index]
}

locals {
  dst_ecr_urn = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

data "docker_registry_image" "in-ghcr" {
  name = "${var.ghcr_urn}/${var.lambda_name}:${var.image_tag}"
}

locals {
  sha_id         = substr(split(":", data.docker_registry_image.in-ghcr.sha256_digest)[1], 0, 8)
  dest_image_tag = "${var.image_tag}-${local.sha_id}"
}

resource "skopeo2_copy" "update-local-ecr" {
  source_image      = "docker://${var.ghcr_urn}/${var.lambda_name}:${var.image_tag}"
  destination_image = "docker://${local.dst_ecr_urn}/${var.lambda_name}:${local.dest_image_tag}"

  preserve_digests = true
  keep_image       = true
  copy_all_images  = true
  docker_digest    = data.docker_registry_image.in-ghcr.sha256_digest

  depends_on = [aws_ecr_repository.compose]
}

resource "aws_lambda_function" "default" {
  package_type = "Image"
  image_uri    = "${local.dst_ecr_urn}/${var.lambda_name}:${local.dest_image_tag}"

  function_name = local.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  architectures = [var.arch]

  memory_size = var.memory_size
  timeout     = var.timeout

  publish = true

  tags = var.tags

  tracing_config {
    mode = "Active"
  }

  /* Include the image id in the environment variables so that the lambda gets replaced
   * when deploying new version. This is a replacement for the source_code_hash which
   * we cannot calculate when using images.
   */
  environment {
    variables = merge(var.environment_variables, local.default_environment, {
      IMAGE_ID = data.docker_registry_image.in-ghcr.id
    })
  }

  /* Run lambda in VPC such that all traffic is routed via the NAT */
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  depends_on = [skopeo2_copy.update-local-ecr, aws_ecr_repository_policy.compose]
}

resource "random_pet" "lambda_alias" {
}

resource "aws_lambda_alias" "default" {
  name             = "lambda-alias-${random_pet.lambda_alias.id}"
  description      = "Alias for latest version of ${local.lambda_function_name}"
  function_name    = aws_lambda_function.default.arn
  function_version = aws_lambda_function.default.version
}

resource "aws_security_group" "lambda" {
  name        = "${local.lambda_function_name}-sg"
  description = "Security group for ${local.lambda_function_name} lambda"
  vpc_id      = var.vpc_id

  # No ingress rules => blocks all inbound traffic
  ingress = []

  /* Allow any outward HTTPS communication */
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_lambda_function_url" "default" {
  function_name = aws_lambda_function.default.function_name
  //  qualifier          = "my_alias"
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://eu.jotform.com"]
    allow_methods     = ["POST"]
    //    allow_headers     = ["date", "keep-alive"]
    //    expose_headers    = ["keep-alive", "date"]
    max_age = 86400
  }
}

resource "aws_lambda_permission" "function_invoke" {
  statement_id  = "AllowPublicFunctionAccess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "*"
}
