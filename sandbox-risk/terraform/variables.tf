# --- add these variables (keep your existing ones) ---

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "tf_state_bucket" {
  type = string
}

# S3 key (path) to the infra-core terraform state (contains lambda_execution_role_arn)
variable "infra_core_state_key" {
  type = string
}
