variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Bucket name."
  type        = string
}

variable "location" {
  description = "Bucket location."
  type        = string
}

variable "storage_class" {
  description = "Bucket storage class."
  type        = string
  default     = "STANDARD"
}

variable "uniform_bucket_level_access" {
  description = "Whether uniform bucket-level access is enabled."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Public access prevention setting."
  type        = string
  default     = "enforced"
}

variable "versioning_enabled" {
  description = "Whether bucket object versioning is enabled. Null leaves the block unmanaged for import parity."
  type        = bool
  default     = null
  nullable    = true
}

variable "labels" {
  description = "Bucket labels."
  type        = map(string)
  default     = {}
}

variable "iam_members" {
  description = "Bucket IAM members keyed by a stable name."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}
