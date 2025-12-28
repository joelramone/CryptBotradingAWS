resource "aws_s3_bucket" "tfstate" {
  bucket        = var.tf_state_bucket
  force_destroy = var.force_destroy_state_bucket

  lifecycle {
    prevent_destroy = var.is_production
  }

  tags = merge(local.tags, {
    Component = "backend"
    Name      = "${var.project_name}-${var.environment}-tfstate"
  })
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms ? aws_kms_key.tfstate[0].arn : null
    }
    bucket_key_enabled = var.enable_kms
  }
}
