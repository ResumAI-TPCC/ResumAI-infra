# Bootstrap

This stack creates the GCS buckets used by Terraform remote state:

- `resumai-infra-tfstate-global`
- `resumai-infra-tfstate-staging`
- `resumai-infra-tfstate-prod`

It intentionally uses local Terraform state because the remote buckets do not exist before this stack is applied.

Run this stack once before `terraform init` in `global/` or `envs/*/`.

