output "secret_arn" {
  description = "ARN del secreto"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Nombre del secreto"
  value       = aws_secretsmanager_secret.this.name
}

output "read_policy_json" {
  description = "Policy JSON que permite leer el secreto (útil para roles)"
  value       = data.aws_iam_policy_document.read_secret.json
  sensitive   = true
}
