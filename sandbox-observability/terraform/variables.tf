variable "project_name" {
  type    = string
  default = "CryptoBotradingAWS"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "metric_namespace" {
  description = "Custom EMF metrics namespace emitted by the app"
  type        = string
  default     = "CryptoBot"
}

variable "lambda_function_names" {
  description = "Map of logical service => lambda function name"
  type        = map(string)
  default = {
    execution_router = "cryptobot-execution-router"
    audit_logger     = "cryptobot-audit-logger"
    audit_notifier   = "cryptobot-audit-notifier"
  }
}

variable "step_function_arns" {
  description = "Optional: Map of workflow name => StepFunction ARN"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "lambda_duration_p95_threshold_ms" {
  description = "Alarm threshold for AWS/Lambda Duration p95 (ms)"
  type        = number
  default     = 5000
}

variable "alarm_email_subscriptions" {
  description = "Email addresses to subscribe to the alarm SNS topic"
  type        = list(string)
  default     = []
}

variable "orders_routed_zero_minutes" {
  description = "Window (minutes) to detect flow drop (OrdersRouted == 0)"
  type        = number
  default     = 10
}

variable "lambda_error_rate_threshold" {
  description = "Error rate threshold for execution_router (Errors/Invocations)"
  type        = number
  default     = 0.02
}
