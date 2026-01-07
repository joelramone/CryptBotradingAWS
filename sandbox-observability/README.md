# CryptoBotradingAWS – Observability (Sandbox)

## Included
- CloudWatch Log Groups (retention enforced)
- SNS topic for alarms (+ optional email subscriptions)
- Alarms:
  - AWS/Lambda: Errors, Throttles, Duration p95
  - AWS/States: ExecutionsFailed (optional)
  - Custom EMF: OrdersRouted flow drop, LambdaError spikes
  - Metric math: Error rate for execution_router
- CloudWatch Dashboard
- Saved Logs Insights queries
- Runbook

## Variables
- `alarm_email_subscriptions`: emails for SNS subscription
- `metric_namespace`: EMF namespace (default `CryptoBot`)
- `orders_routed_zero_minutes`: flow drop window
- `lambda_duration_p95_threshold_ms`: duration alarm threshold
- `lambda_error_rate_threshold`: error rate alarm threshold
