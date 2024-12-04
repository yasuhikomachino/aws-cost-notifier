# Lambda
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lambda_role" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# Cost Explorer
data "aws_iam_policy_document" "lambda_cost_explorer_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ce:GetCostAndUsage"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "lambda_cost_explorer_policy" {
  name   = "${local.name_prefix}-lambda-cost-explorer-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_cost_explorer_policy.json
}

# CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logs_policy" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# EventBridge
resource "aws_iam_role" "eventbridge_scheduler_role" {
  name               = "${local.name_prefix}-eventbridge-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_scheduler_assume_role_policy.json
}
data "aws_iam_policy_document" "eventbridge_scheduler_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "eventbridge_invoke_lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      aws_lambda_function.daily_cost_notification.arn,
    ]
  }
}
resource "aws_iam_role_policy" "eventbridge_invoke_lambda_policy" {
  name   = "${local.name_prefix}-eventbridge-invoke-lambda-policy"
  role   = aws_iam_role.eventbridge_scheduler_role.name
  policy = data.aws_iam_policy_document.eventbridge_invoke_lambda_policy.json
}

