# ResumAI Infrastructure

Terraform source of truth for ResumAI GCP infrastructure.

## Layout

- `bootstrap/` creates the remote state buckets. Run this once with local state.
- `global/` owns cross-environment infrastructure such as GitHub Workload Identity Federation.
- `envs/staging/` and `envs/prod/` are per-environment stacks with separate GCS backends.
- `modules/` contains reusable Terraform modules.
- `docs/` contains runbooks and design notes.

## P0 Bootstrap Order

1. Authenticate to GCP with an account allowed to create buckets, service accounts, IAM bindings, and WIF resources.
2. Run bootstrap:

   ```powershell
   cd bootstrap
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

3. Initialize global:

   ```powershell
   cd ../global
   terraform init
   terraform plan -out=tfplan
   ```

4. Initialize each environment:

   ```powershell
   cd ../envs/staging
   terraform init

   cd ../prod
   terraform init
   ```

The environment stacks are intentionally minimal in P0. P1/P2 add module calls and import blocks for live resources.

