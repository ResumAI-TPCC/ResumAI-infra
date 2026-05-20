variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "pool_id" {
  description = "Workload Identity pool ID."
  type        = string
}

variable "provider_id" {
  description = "Workload Identity provider ID."
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or user that owns the infra repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name allowed to impersonate the service accounts."
  type        = string
}

variable "terraform_runners" {
  description = "Terraform runner service accounts keyed by environment."
  type = map(object({
    account_id   = string
    display_name = string
    ref          = string
    roles        = list(string)
  }))
}

variable "state_bucket_names" {
  description = "State bucket names keyed by runner key. Matching keys receive objectAdmin on the bucket."
  type        = map(string)
  default     = {}
}

