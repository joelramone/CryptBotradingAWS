resource "aws_kms_key" "tfstate" {
  count                   = var.enable_kms ? 1 : 0
  description             = "${var.project_name}-${var.environment} tfstate encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAccountRootFullAccess"
        Effect   = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  lifecycle {
    prevent_destroy = var.is_production
  }

  tags = merge(local.tags, {
    Component = "kms"
    Name      = "${var.project_name}-${var.environment}-tfstate"
  })
}

resource "aws_kms_alias" "tfstate" {
  count         = var.enable_kms ? 1 : 0
  name          = "alias/${var.project_name}-${var.environment}-tfstate"
  target_key_id = aws_kms_key.tfstate[0].key_id
}
