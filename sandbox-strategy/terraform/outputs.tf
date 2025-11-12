output "binance_paper_secret_arn" {
  value       = module.binance_paper.secret_arn
  description = "ARN secreto Binance PAPER"
}

output "alpaca_paper_secret_arn" {
  value       = module.alpaca_paper.secret_arn
  description = "ARN secreto Alpaca PAPER"
}
