variable "project_id" {
  description = "GCP project that owns the Terraform state buckets."
  type        = string
  default     = "resumai-platform"
}

variable "region" {
  description = "Default GCP region."
  type        = string
  default     = "asia-southeast1"
}

variable "state_bucket_location" {
  description = "Location for Terraform state buckets."
  type        = string
  default     = "ASIA-SOUTHEAST1"
}

variable "state_buckets" {
  description = "Terraform state buckets keyed by stack name."
  type        = map(string)
  default = {
    global  = "resumai-infra-tfstate-global"
    staging = "resumai-infra-tfstate-staging"
    prod    = "resumai-infra-tfstate-prod"
  }
}

variable "labels" {
  description = "Labels applied to bootstrap-managed resources."
  type        = map(string)
  default = {
    app       = "resumai"
    component = "terraform-state"
    managedby = "terraform"
  }
}

