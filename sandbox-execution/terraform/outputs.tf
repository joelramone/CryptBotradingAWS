output "binance_prod_secret_arn" {
  value       = module.binance_prod.secret_arn
  description = "ARN secreto Binance PROD"
}

output "alpaca_prod_secret_arn" {
  value       = module.alpaca_prod.secret_arn
  description = "ARN secreto Alpaca PROD"
}

output "binance_prod_read_policy_json" {
  value       = module.binance_prod.read_policy_json
  description = "Policy JSON lectura Binance PROD"
  sensitive   = true
}

output "alpaca_prod_read_policy_json" {
  value       = module.alpaca_prod.read_policy_json
  description = "Policy JSON lectura Alpaca PROD"
  sensitive   = true
}
