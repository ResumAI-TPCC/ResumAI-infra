variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Cloud SQL instance name."
  type        = string
}

variable "region" {
  description = "Cloud SQL region."
  type        = string
}

variable "database_version" {
  description = "PostgreSQL database version."
  type        = string
  default     = "POSTGRES_15"

  validation {
    condition     = startswith(var.database_version, "POSTGRES_")
    error_message = "database_version must be a PostgreSQL version such as POSTGRES_15."
  }
}

variable "tier" {
  description = "Cloud SQL machine tier."
  type        = string
}

variable "availability_type" {
  description = "ZONAL or REGIONAL availability."
  type        = string
  default     = "ZONAL"
}

variable "disk_type" {
  description = "PD_SSD or PD_HDD."
  type        = string
  default     = "PD_SSD"
}

variable "disk_size_gb" {
  description = "Initial disk size in GB."
  type        = number
  default     = 10
}

variable "deletion_protection" {
  description = "Protect the instance from deletion."
  type        = bool
  default     = true
}

variable "backup_enabled" {
  description = "Enable automated backups."
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable PostgreSQL point-in-time recovery."
  type        = bool
  default     = true
}

variable "ipv4_enabled" {
  description = "Assign a public IPv4 address."
  type        = bool
  default     = false
}

variable "private_network" {
  description = "Self-link of the VPC used for private IP."
  type        = string
  default     = null
  nullable    = true
}

variable "database_flags" {
  description = "PostgreSQL database flags."
  type        = map(string)
  default     = {}
}

variable "databases" {
  description = "Databases to create in the instance."
  type        = set(string)
  default     = []
}

variable "labels" {
  description = "Instance labels."
  type        = map(string)
  default     = {}
}
