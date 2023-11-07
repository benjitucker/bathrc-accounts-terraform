output "arn" {
  value = aws_lambda_function.default.arn
}

output "role_arn" {
  value = aws_iam_role.iam_for_lambda.arn
}

output "name" {
  value = local.lambda_function_name
}

output "alias" {
  value = aws_lambda_alias.default.name
}
