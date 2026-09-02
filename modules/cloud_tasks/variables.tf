variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Cloud Tasks queue name."
  type        = string
}

variable "location" {
  description = "Cloud Tasks queue location."
  type        = string
}

variable "max_dispatches_per_second" {
  description = "Maximum queue dispatch rate."
  type        = number
  default     = 10
}

variable "max_concurrent_dispatches" {
  description = "Maximum concurrent task dispatches."
  type        = number
  default     = 10
}

variable "max_attempts" {
  description = "Maximum task attempts."
  type        = number
  default     = 5
}

variable "max_retry_duration" {
  description = "Maximum retry duration as a duration string."
  type        = string
  default     = "3600s"
}

variable "min_backoff" {
  description = "Minimum retry backoff."
  type        = string
  default     = "1s"
}

variable "max_backoff" {
  description = "Maximum retry backoff."
  type        = string
  default     = "60s"
}

variable "max_doublings" {
  description = "Maximum number of exponential backoff doublings."
  type        = number
  default     = 5
}

variable "logging_sampling_ratio" {
  description = "Fraction of operations written to Cloud Logging."
  type        = number
  default     = 1

  validation {
    condition     = var.logging_sampling_ratio >= 0 && var.logging_sampling_ratio <= 1
    error_message = "logging_sampling_ratio must be between 0 and 1."
  }
}
