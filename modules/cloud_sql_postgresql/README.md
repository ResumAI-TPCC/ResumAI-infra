# Cloud SQL PostgreSQL

Creates or imports a protected PostgreSQL Cloud SQL instance and optional
databases. Deletion protection and Terraform `prevent_destroy` are enabled by
default. Passwords and database users are deliberately outside this module so
credentials are never stored in Terraform state.
