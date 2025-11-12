variable "aws_region" {
  type        = string
  default     = "us-east-1"
}

variable "env" {
  type        = string
  default     = "dev"
}

variable "common_tags" {
  type = map(string)
  default = {
    Project = "CryptoBotradingAWS"
    Managed = "Terraform"
  }
}

variable "kms_key_id" {
  type        = string
  default     = null
}

variable "binance_paper_secret_name" {
  type        = string
  default     = "trading/dev/binance-paper"
}

variable "alpaca_paper_secret_name" {
  type        = string
  default     = "trading/dev/alpaca-paper"
}

variable "binance_api_key"    { type = string; sensitive = true }
variable "binance_secret_key" { type = string; sensitive = true }
variable "alpaca_api_key"     { type = string; sensitive = true }
variable "alpaca_secret_key"  { type = string; sensitive = true }
