output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "alarm_topic_arn" {
  value = aws_sns_topic.observability_alarms.arn
}

output "log_groups" {
  value = { for k, lg in aws_cloudwatch_log_group.lambda : k => lg.name }
}

output "alarms" {
  value = {
    errors        = { for k, a in aws_cloudwatch_metric_alarm.lambda_errors : k => a.alarm_name }
    throttles     = { for k, a in aws_cloudwatch_metric_alarm.lambda_throttles : k => a.alarm_name }
    duration      = { for k, a in aws_cloudwatch_metric_alarm.lambda_duration_p95 : k => a.alarm_name }
    sfn_failed    = { for k, a in aws_cloudwatch_metric_alarm.sfn_failed : k => a.alarm_name }
    flow_drop     = aws_cloudwatch_metric_alarm.orders_routed_zero.alarm_name
    custom_errors = aws_cloudwatch_metric_alarm.execution_router_lambda_error.alarm_name
    error_rate    = aws_cloudwatch_metric_alarm.lambda_error_rate_execution_router.alarm_name
  }
}

output "logs_insights_queries" {
  value = {
    by_request_id      = aws_cloudwatch_query_definition.by_request_id.name
    by_trace_id        = aws_cloudwatch_query_definition.by_trace_id.name
    errors_last_60m    = aws_cloudwatch_query_definition.errors_last_60m.name
    by_symbol_strategy = aws_cloudwatch_query_definition.by_symbol_strategy.name
  }
}
