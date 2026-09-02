# Terraform Recovery Runbook

## State Recovery

Remote state buckets use object versioning and public access prevention:

- `resumai-infra-tfstate-global`
- `resumai-infra-tfstate-staging`
- `resumai-infra-tfstate-prod`

If a state object is damaged, stop all Terraform runs, identify the last known
good object generation, copy it to a separate backup location, and restore it
only after peer review. Never delete a lock unless its owner and process have
been verified as stale.

## Resource Recovery

1. Restore global WIF and Terraform runners first.
2. Initialize the target environment against its existing GCS backend.
3. Review a refresh-only plan before any normal plan.
4. Cloud Run modules contain recovery configuration, while application CD owns
   live revisions and traffic.
5. Restore Secret Manager containers and IAM without storing secret versions in
   Terraform; secret payload recovery follows the separate secrets procedure.
6. Cloud SQL modules enforce deletion protection and `prevent_destroy`.
7. Do not enable or create Cloud SQL/Cloud Tasks solely because modules exist.

## Validation

```powershell
terraform fmt -check -recursive
terraform validate
terraform plan -detailed-exitcode
```

Exit code `0` means no changes, `2` means a reviewed change exists, and `1`
means an error. Treat any destroy or replacement as a stop condition.
