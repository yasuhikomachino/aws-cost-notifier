resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${local.name_prefix}-daily-cost-notification"
  retention_in_days = 30
  skip_destroy      = false
}
