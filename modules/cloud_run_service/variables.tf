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

