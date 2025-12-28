output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "tfstate_bucket_arn" {
  value = aws_s3_bucket.tfstate.arn
}

output "tflock_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}

output "tflock_table_arn" {
  value = aws_dynamodb_table.tf_lock.arn
}

output "tfstate_kms_key_arn" {
  value = var.enable_kms ? aws_kms_key.tfstate[0].arn : null
}
