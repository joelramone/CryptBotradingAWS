resource "aws_dynamodb_table" "tf_lock" {
  name         = var.tf_lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = var.is_production
  }

  tags = merge(local.tags, {
    Component = "backend"
    Name      = "${var.project_name}-${var.environment}-tflock"
  })
}
