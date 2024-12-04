# Slack Webhook URL
data "aws_ssm_parameter" "slack_webhook_url" {
  name = "SLACK_WEBHOOK_URL_COST_NOTIFIER"
}
