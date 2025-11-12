variable "secret_name" {
  description = "Nombre del secreto en Secrets Manager"
  type        = string
}

variable "description" {
  description = "Descripción del secreto"
  type        = string
  default     = null
}

variable "secret_json" {
  description = "Contenido del secreto como mapa (se serializa a JSON)"
  type        = map(string)
  sensitive   = true
}

variable "kms_key_id" {
  description = "ARN/ID de KMS CMK (null usa AWS managed key)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags a aplicar al secreto"
  type        = map(string)
  default     = {}
}
