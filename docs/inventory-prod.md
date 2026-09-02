# Production Inventory

Inventory captured from project `resumai-platform` in region
`asia-southeast1`. Sensitive environment values were not read or recorded.

## Cloud Run

| Resource | Value |
| --- | --- |
| Service | `prod-service` |
| Runtime service account | `cloud-run-prod-runtime@resumai-platform.iam.gserviceaccount.com` |
| Image | `gcr.io/resumai-platform/backend-prod:809afb8a50131ab95b35d07234d7e0e735d6607d` |
| Container | `backend-prod-1` |
| Port | `8000` |
| Max scale | `10` |

The service uses a dedicated least-privilege runtime identity. `GEMINI_API_KEY`
references `prod-gemini-api-key:latest`; no plaintext value is present in the
current Cloud Run revision. The previous production API key was revoked after
an upload-and-analysis smoke test passed.

## GCS

| Bucket | Location | UBLA | Public access prevention |
| --- | --- | --- | --- |
| `prod-resumai-resumes` | `ASIA-SOUTHEAST1` | enabled | enforced |

The production runtime service account has bucket-scoped
`roles/storage.objectAdmin` plus `roles/storage.legacyBucketReader`. The latter
is required because the application calls `bucket.exists()` before object
operations.

## Secret Manager and IAM

- Secret container: `prod-gemini-api-key`; secret versions are not managed by
  Terraform.
- Runtime secret access: secret-scoped
  `roles/secretmanager.secretAccessor` on `prod-gemini-api-key`.
- Keyless deployer: `deploy-prod@resumai-platform.iam.gserviceaccount.com`.
- GitHub `main` assumes the deployer through WIF; no service-account key is
  required. The deployer has `roles/iam.serviceAccountUser` only on
  `cloud-run-prod-runtime` and secret-scoped metadata viewer access.

## Terraform and WIF

- Remote state: `gs://resumai-infra-tfstate-prod/envs/prod/default.tfstate`
- Terraform runner: `tf-runner-prod@resumai-platform.iam.gserviceaccount.com`
- WIF subject: `repo:ResumAI-TPCC/ResumAI-infra:ref:refs/heads/main`
- Application deploy WIF subject:
  `repo:ResumAI-TPCC/ResumAI:ref:refs/heads/main`
- The production state was empty before this adoption plan.

## Absent Resources

- No Cloud SQL instance; Cloud SQL Admin API is disabled.
- No Cloud Tasks queue; Cloud Tasks API is disabled.

Only the existing Cloud Run service and GCS bucket have import blocks. Cloud
SQL and Cloud Tasks resources are not fabricated or created as part of safe
adoption.
