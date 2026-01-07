terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix      = "${var.project_name}-${var.env}"
  custom_namespace = var.metric_namespace
}

# Enforce log retention (Lambda may auto-create log groups with infinite retention)
resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = var.lambda_function_names
  name              = "/aws/lambda/${each.value}"
  retention_in_days = var.log_retention_days
}

# AWS/Lambda alarms: Errors / Throttles / Duration p95
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each            = var.lambda_function_names
  alarm_name          = "${local.name_prefix}-${each.key}-errors"
  alarm_description   = "Lambda errors > 0 for ${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = { FunctionName = each.value }

  alarm_actions = [aws_sns_topic.observability_alarms.arn]
  ok_actions    = [aws_sns_topic.observability_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  for_each            = var.lambda_function_names
  alarm_name          = "${local.name_prefix}-${each.key}-throttles"
  alarm_description   = "Lambda throttles > 0 for ${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = { FunctionName = each.value }

  alarm_actions = [aws_sns_topic.observability_alarms.arn]
  ok_actions    = [aws_sns_topic.observability_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_p95" {
  for_each            = var.lambda_function_names
  alarm_name          = "${local.name_prefix}-${each.key}-duration-p95"
  alarm_description   = "Lambda duration p95 too high for ${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  extended_statistic  = "p95"
  threshold           = var.lambda_duration_p95_threshold_ms
  treat_missing_data  = "notBreaching"

  dimensions = { FunctionName = each.value }

  alarm_actions = [aws_sns_topic.observability_alarms.arn]
  ok_actions    = [aws_sns_topic.observability_alarms.arn]
}

# Optional Step Functions alarms
resource "aws_cloudwatch_metric_alarm" "sfn_failed" {
  for_each            = var.step_function_arns
  alarm_name          = "${local.name_prefix}-sfn-${each.key}-failed"
  alarm_description   = "Step Function failed executions > 0 for ${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = { StateMachineArn = each.value }

  alarm_actions = [aws_sns_topic.observability_alarms.arn]
  ok_actions    = [aws_sns_topic.observability_alarms.arn]
}

# CloudWatch Dashboard (Lambda + EMF custom metrics)
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-observability"
  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "text"
          x      = 0
          y      = 0
          width  = 24
          height = 2
          properties = {
            markdown = "# ${local.name_prefix} Observability\nLogs estructurados + EMF metrics + alarms + Logs Insights"
          }
        }
      ],
      [
        for idx, k in tolist(keys(var.lambda_function_names)) : {
          type   = "metric"
          x      = (idx % 2) * 12
          y      = 2 + floor(idx / 2) * 6
          width  = 12
          height = 6
          properties = {
            title  = "Lambda ${k} (Errors/Throttles/Duration p95)"
            region = var.aws_region
            metrics = [
              ["AWS/Lambda", "Errors",    "FunctionName", var.lambda_function_names[k], { "stat": "Sum" }],
              [".",          "Throttles", ".",            ".",                         { "stat": "Sum" }],
              [".",          "Duration",  ".",            ".",                         { "stat": "p95" }]
            ]
            period = 60
          }
        }
      ],
      [
        {
          type   = "metric"
          x      = 0
          y      = 2 + ceil(length(var.lambda_function_names) / 2) * 6
          width  = 24
          height = 6
          properties = {
            title  = "Custom EMF (${local.custom_namespace}): Orders / Errors / Latency"
            region = var.aws_region
            metrics = [
              [local.custom_namespace, "OrdersRouted",    "service", "execution-router", { "stat": "Sum" }],
              [local.custom_namespace, "OrdersAttempted", "service", "broker-binance",   { "stat": "Sum" }],
              [local.custom_namespace, "OrdersFilled",    "service", "broker-binance",   { "stat": "Sum" }],
              [local.custom_namespace, "LambdaError",     "service", "execution-router", { "stat": "Sum" }],
              [local.custom_namespace, "LambdaLatency",   "service", "execution-router", { "stat": "p95" }]
            ]
            period = 60
          }
        }
      ]
    )
  })
}
