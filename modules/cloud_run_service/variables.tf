variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Cloud Run service name."
  type        = string
}

variable "location" {
  description = "Cloud Run service location."
  type        = string
}

variable "image" {
  description = "Container image currently deployed."
  type        = string
}

variable "container_name" {
  description = "Cloud Run container name."
  type        = string
}

variable "service_account_name" {
  description = "Runtime service account email."
  type        = string
}

variable "ingress" {
  description = "Cloud Run ingress annotation value."
  type        = string
  default     = "all"
}

variable "max_scale" {
  description = "Cloud Run max scale annotation value."
  type        = string
  default     = "3"
}

variable "labels" {
  description = "Labels applied to the Cloud Run service."
  type        = map(string)
  default     = {}
}

variable "metadata_annotations" {
  description = "Additional service-level annotations."
  type        = map(string)
  default     = {}
}

variable "template_annotations" {
  description = "Additional revision template annotations used for disaster recovery."
  type        = map(string)
  default     = {}
}

variable "port" {
  description = "Container port exposed by the service."
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Non-sensitive environment variables used when recreating the service."
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Secret Manager references used as environment variables when recreating the service."
  type = map(object({
    secret_name = string
    version     = string
  }))
  default = {}
}

