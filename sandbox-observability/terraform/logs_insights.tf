resource "aws_cloudwatch_query_definition" "by_request_id" {
  name = "${local.name_prefix}-logs-by-request-id"

  log_group_names = [
    for _, lg in aws_cloudwatch_log_group.lambda : lg.name
  ]

  query_string = <<EOT
fields @timestamp, level, message, request_id, trace_id, symbol, strategy_id, execution_id, service
| filter request_id = "REPLACE_ME"
| sort @timestamp asc
EOT
}

resource "aws_cloudwatch_query_definition" "by_trace_id" {
  name = "${local.name_prefix}-logs-by-trace-id"

  log_group_names = [
    for _, lg in aws_cloudwatch_log_group.lambda : lg.name
  ]

  query_string = <<EOT
fields @timestamp, level, message, request_id, trace_id, symbol, strategy_id, execution_id, service
| filter trace_id = "REPLACE_ME"
| sort @timestamp asc
EOT
}

resource "aws_cloudwatch_query_definition" "errors_last_60m" {
  name = "${local.name_prefix}-errors-last-60m"

  log_group_names = [
    for _, lg in aws_cloudwatch_log_group.lambda : lg.name
  ]

  query_string = <<EOT
fields @timestamp, level, message, request_id, trace_id, symbol, strategy_id, execution_id, service
| filter level in ["ERROR"] or message like /error/i
| sort @timestamp desc
| limit 200
EOT
}

resource "aws_cloudwatch_query_definition" "by_symbol_strategy" {
  name = "${local.name_prefix}-logs-by-symbol-strategy"

  log_group_names = [
    for _, lg in aws_cloudwatch_log_group.lambda : lg.name
  ]

  query_string = <<EOT
fields @timestamp, level, message, request_id, trace_id, symbol, strategy_id, execution_id, service
| filter symbol = "REPLACE_SYMBOL" and strategy_id = "REPLACE_STRATEGY"
| sort @timestamp asc
EOT
}
