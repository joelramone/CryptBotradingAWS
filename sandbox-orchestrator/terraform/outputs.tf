output "sfn_runtime_role_arn" {
  value = try(data.terraform_remote_state.infra_core.outputs.sfn_execution_role_arn, null)
}
