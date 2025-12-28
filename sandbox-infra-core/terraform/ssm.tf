resource "aws_ssm_parameter" "environment" {
  name  = "/${var.project_name}/${var.environment}/environment"
  type  = "String"
  value = var.environment
  tags  = local.tags
}
