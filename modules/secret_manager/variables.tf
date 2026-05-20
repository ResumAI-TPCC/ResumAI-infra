variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "secret_id" {
  description = "Secret ID."
  type        = string
}

variable "labels" {
  description = "Secret labels."
  type        = map(string)
  default     = {}
}

variable "iam_members" {
  description = "Secret IAM members keyed by a stable name."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}
