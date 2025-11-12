terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  base_tags = merge(var.common_tags, {
    Env = var.env
  })
}

module "binance_paper" {
  source      = "../../modules/secret"
  secret_name = var.binance_paper_secret_name
  description = "Binance PAPER/DEV keys - Strategy"
  kms_key_id  = var.kms_key_id
  tags        = merge(local.base_tags, { Broker = "binance", Purpose = "strategy-paper" })

  secret_json = {
    api_key    = var.binance_api_key
    secret_key = var.binance_secret_key
  }
}

module "alpaca_paper" {
  source      = "../../modules/secret"
  secret_name = var.alpaca_paper_secret_name
  description = "Alpaca PAPER/DEV keys - Strategy"
  kms_key_id  = var.kms_key_id
  tags        = merge(local.base_tags, { Broker = "alpaca", Purpose = "strategy-paper" })

  secret_json = {
    api_key    = var.alpaca_api_key
    secret_key = var.alpaca_secret_key
  }
}
