terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = var.description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.secret_json)
}

# Policy JSON de solo lectura al secreto (para adjuntar a roles/SA)
data "aws_iam_policy_document" "read_secret" {
  statement {
    sid     = "AllowReadSecret"
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.this.arn
    ]
  }

  dynamic "statement" {
    for_each = var.kms_key_id == null ? [] : [1]
    content {
      sid     = "AllowKMSDecrypt"
      effect  = "Allow"
      actions = ["kms:Decrypt"]
      resources = [var.kms_key_id]
    }
  }
}
