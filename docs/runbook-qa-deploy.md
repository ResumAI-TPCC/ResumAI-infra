# QA Backend Deploy Runbook

QA backend deploys are owned by the application repository `ResumAI-TPCC/ResumAI`.

## Trigger

The workflow `.github/workflows/backend-cd.yml` runs after `Backend CI (Test and Lint)` completes successfully on `develop`.

## Authentication

GitHub Actions uses OIDC through Workload Identity Federation:

- Provider: `projects/367288272676/locations/global/workloadIdentityPools/github-actions/providers/github`
- Service account: `deploy-staging@resumai-platform.iam.gserviceaccount.com`
- Allowed subject: `repo:ResumAI-TPCC/ResumAI:ref:refs/heads/develop`

No service account JSON key is required.

## Image

P1.5 keeps the existing GCR target:

```text
gcr.io/resumai-platform/backend-test:<workflow_run.head_sha>
```

Artifact Registry migration remains a later phase.

## Cloud Run

The workflow deploys:

- Service: `test-service`
- Region: `asia-southeast1`
- Port: `8000`
- Bucket: `resumai-platform-resumes`
- Secret: `GEMINI_API_KEY=gemini-api-key:1`

The deploy workflow must use `--update-secrets` for `GEMINI_API_KEY`; do not pass the Gemini key as a GitHub Actions secret or plaintext env var.

## Verification

After a successful workflow run:

```powershell
gcloud run services describe test-service `
  --project=resumai-platform `
  --region=asia-southeast1 `
  --format="value(status.latestReadyRevisionName)"
```

Terraform should still treat app revision changes as expected runtime drift:

```powershell
$env:GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="tf-runner-staging@resumai-platform.iam.gserviceaccount.com"
cd envs/staging
terraform plan -detailed-exitcode
```

