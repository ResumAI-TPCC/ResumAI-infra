# Cloud Run Service

Imports or creates a protected first-generation Cloud Run service with a
recovery-oriented revision template.

Application CD owns images and live revision configuration, so Terraform
ignores revision-template and traffic drift after import. The configured
runtime identity, port, non-sensitive environment variables, and Secret
Manager references are used if the service must be recreated during disaster
recovery. Secret values must never be passed to this module.

