locals {
  flow_drop_period_seconds = 300
  flow_drop_eval_periods   = max(1, floor((var.orders_routed_zero_minutes * 60) / local.flow_drop_period_seconds))
}

# Flow drop: OrdersRouted == 0 over N minutes
resource "aws_cloudwatch_metric_alarm" "orders_routed_zero" {
  alarm_name          = "${local.name_prefix}-orders-routed-zero"
  alarm_description   = "OrdersRouted is zero (possible flow drop) over last ${var.orders_routed_zero_minutes} minutes"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = local.flow_drop_eval_periods
  threshold           = 0
  treat_missing_data  = "breaching"

  metric_query {
    id = "m1"
    metric {
      metric_name = "OrdersRouted"
      namespace   = var.metric_namespace
      period      = local.flow_drop_period_seconds
      stat        = "Sum"
      dimensions = {
        service = "execution-router"
      }
    }
    return_data = true
  }

  alarm_actions = [aws_sns_topic.observability_alarms.arn]
  ok_actions    = [aws_sns_topic.observability_alarms.arn]
}

# EMF error spikes: LambdaError > 0
resource "aws_cloudwatch_metric_alarm" "execution_router_lambda_error" {
  alarm_name          = "${local.name_prefix}-execution-router-lambdaerror"
  alarm_description   = "LambdaError (custom EMF) > 0 for execution-router"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  treat_missing_data  = "notBreaching"

  metric_name = "LambdaError"
  namespace   = var.metric_namespace
  period      = 60
  statistic   = "Sum"

  dimensions = {
    service = "execution-router"
  }

  alarm_actions = [aws_sns_topic.observability_alarms.arn]
  ok_actions    = [aws_sns_topic.observability_alarms.arn]
}

# Error rate: Errors / Invocations > threshold (execution_router)
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate_execution_router" {
  alarm_name          = "${local.name_prefix}-execution-router-error-rate"
  alarm_description   = "Lambda error rate too high for execution-router"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.lambda_error_rate_threshold
  treat_missing_data  = "notBreaching"

  metric_query {
    id = "e"
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"
      dimensions = {
        FunctionName = var.lambda_function_names["execution_router"]
      }
    }
    return_data = false
  }

  metric_query {
    id = "i"
    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"
      dimensions = {
        FunctionName = var.lambda_function_names["execution_router"]
      }
    }
    return_data = false
  }

  metric_query {
    id          = "er"
    expression  = "IF(i>0, e/i, 0)"
    label       = "ErrorRate"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.observability_alarms.arn]
  ok_actions    = [aws_sns_topic.observability_alarms.arn]
}
