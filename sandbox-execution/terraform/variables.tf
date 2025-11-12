variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Región AWS"
}

variable "env" {
  type        = string
  default     = "prod"
}

variable "common_tags" {
  type = map(string)
  default = {
    Project = "CryptoBotradingAWS"
    Managed = "Terraform"
  }
}

# Si usás CMK propio, poné el ARN acá; si no, dejá null.
variable "kms_key_id" {
  type        = string
  default     = null
}

# Secret names
variable "binance_prod_secret_name" {
  type        = string
  default     = "trading/prod/binance"
}

variable "alpaca_prod_secret_name" {
  type        = string
  default     = "trading/prod/alpaca"
}

# Valores sensibles (no los subas en claro)
variable "binance_api_key"     { type = string; sensitive = true }
variable "binance_secret_key"  { type = string; sensitive = true }
variable "alpaca_api_key"      { type = string; sensitive = true }
variable "alpaca_secret_key"   { type = string; sensitive = true }
