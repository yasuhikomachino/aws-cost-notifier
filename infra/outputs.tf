output "lambda_function_arn" {
  value = aws_lambda_function.daily_cost_notification.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.daily_cost_notification.function_name
}
