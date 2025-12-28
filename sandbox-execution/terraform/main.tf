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


# --- add this block near the top (keep your existing code) ---

data "terraform_remote_state" "infra_core" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = var.infra_core_state_key
    region = var.aws_region
  }
}

locals {
  lambda_exec_role_arn = data.terraform_remote_state.infra_core.outputs.lambda_execution_role_arn
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




# --- then, in your existing aws_lambda_function resources, set the role like this ---

# resource "aws_lambda_function" "execution_router" {
#   ...
#   role = local.lambda_exec_role_arn
#   ...
# }
