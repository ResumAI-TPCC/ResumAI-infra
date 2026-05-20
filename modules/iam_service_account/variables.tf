variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "account_id" {
  description = "Service account ID."
  type        = string
}

variable "display_name" {
  description = "Service account display name."
  type        = string
}

variable "description" {
  description = "Service account description."
  type        = string
  default     = null
}

