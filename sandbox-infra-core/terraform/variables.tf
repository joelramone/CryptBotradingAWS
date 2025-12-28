variable "project_name" {
  type    = string
  default = "CryptoBotradingAWS"
}

variable "environment" {
  description = "dev | stg | prod"
  type        = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Terraform backend naming (inputs)
variable "tf_state_bucket" {
  type = string
}

variable "tf_lock_table" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

# Guardrails
variable "is_production" {
  description = "Enable destructive protections (prevent_destroy) for prod-like environments."
  type        = bool
  default     = false
}

variable "force_destroy_state_bucket" {
  description = "If true, allows deleting the state bucket even if it contains objects (never enable in prod)."
  type        = bool
  default     = false
}

# KMS (recommended)
variable "enable_kms" {
  type    = bool
  default = true
}

# IAM deployer trust toggles
variable "enable_trust_root_account" {
  type    = bool
  default = false
}

variable "enable_trust_github_oidc" {
  type    = bool
  default = true
}
