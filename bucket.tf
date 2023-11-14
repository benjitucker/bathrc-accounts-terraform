locals {
  bucket_name = "bathrc-accounts-frontend"
}

module "frontend_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = local.bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  versioning = {
    enabled = false
  }
}

#for: resource "aws_s3_bucket_policy" "this" {
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.s3_proxy_role.arn]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
}

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

resource "aws_iam_role_policy_attachment" "s3_proxy_role_file_upload_attachment" {
  depends_on = [
    aws_iam_policy.s3_file_access_policy,
  ]

  role       = aws_iam_role.s3_proxy_role.name
  policy_arn = aws_iam_policy.s3_file_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_proxy_role_api_gateway_attachment" {
  depends_on = [
    aws_iam_policy.s3_file_access_policy,
  ]

  role       = aws_iam_role.s3_proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_iam_policy" "s3_file_access_policy" {
  name        = "${var.env_name}-github-s3-file-upload-policy"
  path        = "/"
  description = "${var.env_name} s3 file access policy"

  policy = data.aws_iam_policy_document.bucket_policy.json
}
