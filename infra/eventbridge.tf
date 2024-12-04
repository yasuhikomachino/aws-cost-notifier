resource "aws_scheduler_schedule" "lambda-eventbridge-scheduler" {
  name = "${local.name_prefix}-lambda-eventbridge_scheduler"

  schedule_expression          = "cron(0 0 * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.daily_cost_notification.arn
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
  }
}
