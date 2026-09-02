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

variable "iam_members" {
  description = "Additive IAM members on this service account, keyed by a stable name."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}

