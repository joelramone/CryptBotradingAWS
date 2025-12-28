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

# --- then, in your existing aws_lambda_function resources, set the role like this ---

# resource "aws_lambda_function" "audit_logger" {
#   ...
#   role = local.lambda_exec_role_arn
#   ...
# }

# resource "aws_lambda_function" "notifier" {
#   ...
#   role = local.lambda_exec_role_arn
#   ...
# }
