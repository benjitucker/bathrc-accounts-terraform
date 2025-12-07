data "aws_iam_policy_document" "compose" {
  statement {
    sid    = "AllowLambdaService"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
  }
}

resource "aws_ecr_repository_policy" "compose" {
  repository = aws_ecr_repository.compose.name
  policy     = data.aws_iam_policy_document.compose.json
}

resource "aws_ecr_repository" "compose" {
  name = var.lambda_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}
