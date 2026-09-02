# Existing Resource Import Runbook

## Safety Rules

1. Use the environment-specific Terraform runner and remote state.
2. Back up the current state object version before applying imports.
3. Use declarative `import` blocks with exact resource IDs.
4. Save every plan and reject any unexpected `delete` or `replace` action.
5. Import and configuration adoption must not change live application
   revisions, credentials, public access, or runtime identities.
6. Never put secret payloads in Terraform configuration or variables. Treat
   saved plans and state as sensitive: importing a legacy resource can capture
   plaintext values that already exist in that resource.

## Staging

```powershell
$env:GOOGLE_IMPERSONATE_SERVICE_ACCOUNT = "tf-runner-staging@resumai-platform.iam.gserviceaccount.com"
cd envs/staging
terraform init -reconfigure
terraform plan -out staging-import.tfplan -detailed-exitcode
terraform show -no-color staging-import.tfplan
```

Apply only when the plan contains imports/additive IAM changes and no
unexpected destroy or replacement:

```powershell
terraform apply staging-import.tfplan
terraform plan -detailed-exitcode
```

The final command must exit `0` and report `No changes`.

## Production

```powershell
$env:GOOGLE_IMPERSONATE_SERVICE_ACCOUNT = "tf-runner-prod@resumai-platform.iam.gserviceaccount.com"
cd envs/prod
terraform init -reconfigure
terraform plan -out prod-import.tfplan -detailed-exitcode
```

Production apply requires explicit human approval after reviewing the saved
plan. The initial adoption plan is expected to import exactly
`prod-service` and `prod-resumai-resumes` without modifying them.

The initial production import captured the legacy Cloud Run revision's
plaintext secret in saved plans and historical state. The service now uses
`prod-gemini-api-key:latest` and the captured key has been revoked. Do not
upload old plans as evidence or print their full contents into CI logs;
historical state generations must still be treated as sensitive.

## After Import

- Run `terraform state list` and compare it with the inventory.
- Run a second plan and require `No changes`.
- Verify both Cloud Run services are Ready and still reference their pre-import
  images and runtime identities.
- Retain the reviewed plan output as acceptance evidence, excluding sensitive
  values.
