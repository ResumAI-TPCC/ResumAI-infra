# Staging / QA Inventory

Inventory captured from project `resumai-platform` in region `asia-southeast1`.

## Cloud Run

| Resource | Value |
| --- | --- |
| Service | `test-service` |
| Runtime service account | `cloud-run-staging-runtime@resumai-platform.iam.gserviceaccount.com` |
| Image | `gcr.io/resumai-platform/backend-test:5cee408999ed50730c7e3e4cb277b200d267aed5` |
| Max scale | `3` |
| App version | `QA` |
| Bucket env var | `GCS_BUCKET_NAME=resumai-platform-resumes` |
| Object prefix env var | `GCS_OBJECT_PREFIX=resumes` |

The current revision template contains plaintext environment values. P1 imports the service but ignores revision template drift so secret values are not committed to Terraform.

## GCS

| Bucket | Location | UBLA | Public access prevention | Notes |
| --- | --- | --- | --- | --- |
| `resumai-platform-resumes` | `ASIA-SOUTHEAST1` | enabled | enforced | QA resume uploads bucket |

Bucket IAM members imported for the backend runtime service account:

| Role | Member |
| --- | --- |
| `roles/storage.objectCreator` | `serviceAccount:resumai-backend@resumai-platform.iam.gserviceaccount.com` |
| `roles/storage.objectViewer` | `serviceAccount:resumai-backend@resumai-platform.iam.gserviceaccount.com` |
| `roles/storage.objectAdmin` | `serviceAccount:cloud-run-staging-runtime@resumai-platform.iam.gserviceaccount.com` |

## Secret Manager

| Secret | Replication | Notes |
| --- | --- | --- |
| `gemini-api-key` | automatic | Runtime accessor is managed; secret versions are intentionally not imported |

## Service Accounts

| Service account | Display name | P1 status |
| --- | --- | --- |
| `resumai-backend@resumai-platform.iam.gserviceaccount.com` | `resumai-backend` | imported |
| `cloud-run-staging-runtime@resumai-platform.iam.gserviceaccount.com` | `Cloud Run staging runtime` | imported |
| `github-actions-sa@resumai-platform.iam.gserviceaccount.com` | `github-actions-sa` | imported |
| `local-dev-uploader@resumai-platform.iam.gserviceaccount.com` | `local-dev-uploader` | inventoried, not imported |
| `367288272676-compute@developer.gserviceaccount.com` | Compute Engine default service account | legacy; runtime access removed after migration |

## Out Of Scope For P1

- Secret versions.
- GCR images.
- Firebase Hosting resources.
- Prod resources such as `prod-service` and `prod-resumai-resumes`.
