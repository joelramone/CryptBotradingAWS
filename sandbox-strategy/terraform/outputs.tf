output "binance_paper_secret_arn" {
  value       = module.binance_paper.secret_arn
  description = "ARN secreto Binance PAPER"
}

output "alpaca_paper_secret_arn" {
  value       = module.alpaca_paper.secret_arn
  description = "ARN secreto Alpaca PAPER"
}

# (optional) expose which runtime role was used
output "lambda_runtime_role_arn" {
  value = try(data.terraform_remote_state.infra_core.outputs.lambda_execution_role_arn, null)
}
