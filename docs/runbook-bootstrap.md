# P0 Bootstrap Runbook

## Prerequisites

- Terraform `~> 1.9`
- Google provider `~> 5.40`
- A local GCP identity with permission to create GCS buckets, service accounts, IAM bindings, and Workload Identity Federation resources in `resumai-platform`

## 1. Create Remote State Buckets

```powershell
cd bootstrap
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Expected buckets:

- `resumai-infra-tfstate-global`
- `resumai-infra-tfstate-staging`
- `resumai-infra-tfstate-prod`

All buckets have uniform bucket-level access, public access prevention, object versioning, and a 30-day noncurrent-version lifecycle rule.

## 2. Create WIF and Terraform Runner Service Accounts

Create `global/terraform.tfvars` from `global/terraform.tfvars.example`, then set `github_owner`.

```powershell
cd ../global
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

The output `workload_identity_provider` is the value used by `google-github-actions/auth@v2`.

## 3. Verify Environment Backends

```powershell
cd ../envs/staging
terraform init
terraform validate

cd ../prod
terraform init
terraform validate
```

P0 is complete when `terraform init` succeeds for `global`, `envs/staging`, and `envs/prod` against the GCS backend.

