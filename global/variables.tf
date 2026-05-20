variable "project_id" {
  description = "GCP project ID."
  type        = string
  default     = "resumai-platform"
}

variable "region" {
  description = "Default GCP region."
  type        = string
  default     = "asia-southeast1"
}

variable "github_owner" {
  description = "GitHub organization or user that owns this infra repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub infra repository name."
  type        = string
  default     = "resumai-infra"
}

