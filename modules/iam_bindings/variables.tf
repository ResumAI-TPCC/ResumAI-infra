variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "project_members" {
  description = "Additive project IAM members keyed by a stable name."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}

variable "service_account_members" {
  description = "Additive service-account IAM members keyed by a stable name."
  type = map(object({
    service_account_id = string
    role               = string
    member             = string
  }))
  default = {}
}
