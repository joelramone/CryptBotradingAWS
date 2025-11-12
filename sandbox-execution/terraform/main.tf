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

module "binance_prod" {
  source      = "../../modules/secret"
  secret_name = var.binance_prod_secret_name
  description = "Binance LIVE keys - Execution"
  kms_key_id  = var.kms_key_id
  tags        = merge(local.base_tags, { Broker = "binance", Purpose = "execution" })

  secret_json = {
    api_key    = var.binance_api_key
    secret_key = var.binance_secret_key
  }
}

module "alpaca_prod" {
  source      = "../../modules/secret"
  secret_name = var.alpaca_prod_secret_name
  description = "Alpaca LIVE keys - Execution"
  kms_key_id  = var.kms_key_id
  tags        = merge(local.base_tags, { Broker = "alpaca", Purpose = "execution" })

  secret_json = {
    api_key    = var.alpaca_api_key
    secret_key = var.alpaca_secret_key
  }
}
