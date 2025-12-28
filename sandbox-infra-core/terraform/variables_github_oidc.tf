variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_ref_patterns" {
  type    = list(string)
  default = ["refs/heads/main"]
}
