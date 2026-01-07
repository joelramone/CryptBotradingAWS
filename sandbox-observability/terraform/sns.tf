resource "aws_sns_topic" "observability_alarms" {
  name = "${local.name_prefix}-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.alarm_email_subscriptions)
  topic_arn = aws_sns_topic.observability_alarms.arn
  protocol  = "email"
  endpoint  = each.value
}
