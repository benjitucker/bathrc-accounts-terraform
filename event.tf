
# EventBridge rule to trigger daily at 00:00 UTC
resource "aws_cloudwatch_event_rule" "lambda-periodic" {
  name = "lambda-trigger"
  //schedule_expression = "cron(0 * * * ? *)" # hourly (minute=0)
  schedule_expression = "cron(*/5 * * * ? *)" # every 5 minutes for testing
  description         = "Runs Lambda periodically"
}

# Attach Lambda as target
resource "aws_cloudwatch_event_target" "daily_target" {
  rule      = aws_cloudwatch_event_rule.lambda-periodic.name
  target_id = "periodic-lambda"
  arn       = module.bathrc-accounts-backend.arn

  input = jsonencode({
    //period = "hourly"
    period = "run-test" // for testing
  })
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.bathrc-accounts-backend.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda-periodic.arn
}
