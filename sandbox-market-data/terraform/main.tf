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
  sfn_exec_role_arn    = data.terraform_remote_state.infra_core.outputs.sfn_execution_role_arn
}

# --- then, in your existing aws_sfn_state_machine resource, set the role like this ---

# resource "aws_sfn_state_machine" "scalper" {
#   ...
#   role_arn = local.sfn_exec_role_arn
#   ...
# }

# --- and ensure any aws_lambda_function referenced here (if any) uses ---
# role = local.lambda_exec_role_arn
