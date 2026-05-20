# ResumAI Infrastructure-as-Code Proposal

**Status:** Draft
**Author:** TBD
**Date:** 2026-05-14
**Related ticket:** RA-XX (resumai-infra setup)

---

## 1. Background

ResumAI is currently deployed manually-ish through GitHub Actions:

| Layer | Today | Owned by |
| --- | --- | --- |
| Backend | FastAPI container → **Cloud Run** (`test-service`, `prod-service`, `asia-southeast1`) | `.github/workflows/{backend-cd,prod-cd}.yml` |
| Frontend | Vite SPA → **Firebase Hosting** (targets `platform_site` / `app_site`) | `.github/workflows/{frontend-cd,prod-cd}.yml` |
| Images | `gcr.io/resumai-platform/backend-{test,prod}:<sha>` (Container Registry) | gcloud CLI in workflow |
| Object storage | GCS bucket `resumai-platform-resumes` (+ prod equivalent) | manually created |
| Secrets | GitHub Actions secrets (`GCP_SA_KEY`, `GEMINI_API_KEY`, …) injected as Cloud Run env vars | manually managed |
| Auth from CI | Long-lived **SA JSON key** in `GCP_SA_KEY` / `PROD_GCP_SA_KEY` | manually rotated |
| GCP project | Single project `resumai-platform`; staging/prod separated by service name and hosting target only |
| Database | _Not yet provisioned_ — Cloud SQL PostgreSQL is new |
| Queue | _Not yet provisioned_ — Cloud Tasks is new |

Pain points this proposal addresses:
1. No reproducibility — resources only exist because someone clicked through the console.
2. Drift between staging and prod is invisible.
3. Long-lived SA keys are a credential-leak risk.
4. New resources (Cloud SQL, Cloud Tasks) are coming and we want them codified from day one.
5. Adding/changing infra has no review trail.

---

## 2. Goals (mapped to acceptance criteria)

| AC | Goal |
| --- | --- |
| Terraform repo & module structure created | Stand up `resumai-infra` repo as the single source of truth for GCP resources. |
| Remote state in GCS | One state bucket per env, versioned + object-locked, with state locking. |
| Staging and prod configs exist | Two env stacks composing the same modules, separated by `tfvars` and backend config. |
| Existing resources imported safely | `terraform import` (or `import {}` blocks) for every resource currently in prod/staging; first `plan` shows zero destructive changes. |
| `fmt`, `validate`, `plan` pass cleanly | Enforced in CI before any apply. |

Out of scope (explicit non-goals for this ticket):
- Migrating Firebase Hosting config to Terraform (Firebase resources are partially supported and noisy — track separately).
- Moving frontend build artifacts off Firebase.
- Multi-region failover.

---

## 3. Repository layout

A separate repo `resumai-infra` (not a folder in this monorepo) so that:
- Terraform CI can be tightly scoped (apply only on infra changes).
- IAM on the infra repo can be stricter than the application repo.
- State bucket access can be limited to the infra repo's WIF principal.

```
resumai-infra/
├── README.md
├── .github/workflows/
│   ├── terraform-plan.yml      # PR: fmt, validate, plan, tflint, tfsec
│   └── terraform-apply.yml     # main branch, manual approval per env
├── modules/
│   ├── cloud_run_service/      # backend service + revision config
│   ├── cloud_sql_postgres/     # instance, db, user, private IP
│   ├── gcs_bucket/             # uploads + lifecycle + uniform access
│   ├── secret_manager/         # secret + version (value out-of-band)
│   ├── iam_service_account/    # SA + role bindings (least privilege)
│   ├── cloud_tasks_queue/      # queue + rate config
│   ├── workload_identity/      # pool, provider, SA impersonation binding
│   └── artifact_registry/      # successor to GCR
├── envs/
│   ├── qa/
│   │   ├── backend.tf          # GCS backend → resumai-infra-tfstate-staging
│   │   ├── providers.tf
│   │   ├── main.tf             # composition: calls modules/*
│   │   ├── variables.tf
│   │   ├── terraform.tfvars    # non-secret values
│   │   └── imports.tf          # `import {}` blocks (Terraform 1.5+)
│   └── prod/
│       └── …same layout, distinct tfvars + state bucket
├── global/                     # cross-env: WIF pool, org-level IAM
│   ├── backend.tf
│   ├── main.tf
│   └── …
└── docs/
    ├── runbook-import.md
    ├── runbook-secret-rotation.md
    └── ADRs/
```

**Why `envs/` over Terragrunt or workspaces?**
- Workspaces share a backend; one fat-finger affects all envs. Per-dir backends are safer.
- Terragrunt is great but adds a tool dependency for the team to learn. Keep it vanilla until the duplication is actually painful — modules carry the abstraction weight.

---

## 4. Module catalog

Each module has: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`, `examples/`.

| Module | Resources | Notes |
| --- | --- | --- |
| `cloud_run_service` | `google_cloud_run_v2_service`, IAM bindings | Inputs: image, env, secrets (refs to Secret Manager), SA email, min/max instances, CPU/mem, VPC connector. Used twice per env (today only backend, but leaves room for worker services). |
| `cloud_sql_postgres` | `google_sql_database_instance`, `_database`, `_user`, optional `google_compute_global_address` + private VPC peering | Private IP only; public IP disabled. Backups + PITR on. Maintenance window pinned. |
| `gcs_bucket` | `google_storage_bucket`, lifecycle rules, IAM | Uniform bucket-level access on. Object versioning on for `resumes` bucket. Lifecycle to delete temp prefixes after N days. |
| `secret_manager` | `google_secret_manager_secret` (+ optionally a placeholder version) | **Values are never committed.** The module creates the secret resource; humans/SOPS create the version. Apps reference secrets via Cloud Run's `secrets` block. |
| `iam_service_account` | `google_service_account`, `google_project_iam_member` (least-priv roles) | One SA per workload (backend-runtime, task-publisher, deploy-cd, terraform-runner). |
| `cloud_tasks_queue` | `google_cloud_tasks_queue` | Per-queue: rate limits, retry config. |
| `workload_identity` | `google_iam_workload_identity_pool` + `_provider`, SA impersonation IAM | Replaces SA JSON keys for GitHub Actions. |
| `artifact_registry` | `google_artifact_registry_repository` | New `docker` repo in `asia-southeast1`. Plan to migrate off GCR. |

---

## 5. Environments

### 5.1 Staging vs prod separation

**Recommendation:** keep the current single-project model (`resumai-platform`) **for now** but resource-name-prefix everything by env (`-staging`, `-prod`). Note in an ADR that splitting into two GCP projects is the long-term direction; flag the trade-off (cleaner IAM blast radius vs. one more thing to manage) and defer until we have stakeholder buy-in.

Within the single project:

| Resource | Staging | Prod |
| --- | --- | --- |
| Cloud Run service | `backend-staging` (rename from `test-service`) | `backend-prod` (rename from `prod-service`) |
| Cloud SQL instance | `resumai-pg-staging` (db-g1-small, no HA) | `resumai-pg-prod` (db-custom-2-7680, HA enabled) |
| GCS bucket | `resumai-platform-resumes-staging` | `resumai-platform-resumes-prod` |
| Cloud Tasks queue | `resume-jobs-staging` | `resume-jobs-prod` |
| Secret prefix | `staging-*` | `prod-*` |

> ⚠️ Renaming the Cloud Run services from `test-service`/`prod-service` would break the `firebase.json` rewrites. Two options: (a) keep current names in Terraform to match reality and rename in a later ticket; (b) rename + ship a coordinated frontend deploy. **Default to (a)** for this ticket — minimize blast radius.

### 5.2 Per-env `terraform.tfvars` example

```hcl
# envs/staging/terraform.tfvars
project_id     = "resumai-platform"
region         = "asia-southeast1"
env            = "staging"
backend_image  = "asia-southeast1-docker.pkg.dev/resumai-platform/app/backend"
cloud_run = {
  name           = "test-service"   # keep existing name during import phase
  min_instances  = 0
  max_instances  = 5
  cpu            = "1"
  memory         = "512Mi"
  allow_unauth   = false
}
cloud_sql = {
  tier            = "db-g1-small"
  ha              = false
  backup_enabled  = true
}
```

---

## 6. Remote state

- **One GCS bucket per env** (and one for global):
  - `resumai-infra-tfstate-staging`
  - `resumai-infra-tfstate-prod`
  - `resumai-infra-tfstate-global`
- Object versioning **on**, bucket lifecycle to keep 30 days of non-current versions.
- Uniform bucket-level access on; IAM grants only to the per-env Terraform runner SA.
- State locking via GCS's native `if-generation-match` (Terraform handles this — no DynamoDB analog needed).
- Encryption: Google-managed key for now; CMEK in a follow-up ticket.

```hcl
# envs/prod/backend.tf
terraform {
  backend "gcs" {
    bucket = "resumai-infra-tfstate-prod"
    prefix = "envs/prod"
  }
}
```

**Bootstrap problem:** the state bucket itself must exist before `init`. Solution: a tiny `bootstrap/` Terraform config applied locally **once** to create the three state buckets, then it stores its own state… also in one of them (with a `local` backend committed to history as the record). Document in `runbook-bootstrap.md`.

---

## 7. Workload Identity Federation (replaces SA JSON keys)

Today: `secrets.GCP_SA_KEY` is a long-lived JSON key — pasted into the repo's GitHub Secrets. Risk: exfil = full project access until rotation.

Target:
1. Create a Workload Identity Pool + GitHub OIDC provider (in `global/`).
2. Create one **deployer SA per env** (`deploy-staging@…`, `deploy-prod@…`) with least-priv roles (Cloud Run admin, Artifact Registry writer, Secret Manager accessor — *no* project owner).
3. Bind WIF pool → SA with a condition on `repository_owner` + `repository` + `ref` (e.g. only `refs/heads/develop` can impersonate `deploy-staging`, only `refs/heads/main` can impersonate `deploy-prod`).
4. Update workflows to use `google-github-actions/auth@v2` with `workload_identity_provider` + `service_account` instead of `credentials_json`.
5. Delete the `*_GCP_SA_KEY` GitHub secrets and the underlying SA keys.

This is in the WIF module; rollout is a separate ticket because it touches the app repo's workflows.

---

## 8. Importing existing resources

This is the riskiest part of the ticket. Strategy:

### 8.1 Inventory first
Run `gcloud asset search-all-resources --project=resumai-platform --asset-types=...` for:
- `run.googleapis.com/Service`
- `storage.googleapis.com/Bucket`
- `secretmanager.googleapis.com/Secret`
- `iam.googleapis.com/ServiceAccount`
- `compute.googleapis.com/...` (any networking)

Output → `docs/inventory.md`. This becomes the import checklist.

### 8.2 Use Terraform 1.5+ `import {}` blocks (not CLI)
Prefer declarative imports in `envs/<env>/imports.tf`:

```hcl
import {
  to = module.backend.google_cloud_run_v2_service.this
  id = "projects/resumai-platform/locations/asia-southeast1/services/test-service"
}

import {
  to = module.resumes_bucket.google_storage_bucket.this
  id = "resumai-platform-resumes"
}
```

Benefit: imports are reviewable in PR and reproducible. Run `terraform plan -generate-config-out=generated.tf` to bootstrap module inputs from current state, then hand-edit into proper module calls.

### 8.3 Per-resource safety drill
For every imported resource, **acceptance is `terraform plan` shows zero changes** (or only safe metadata changes like adding labels). Anything else means the module doesn't yet match reality — fix the module, don't apply.

### 8.4 Resources that should _not_ be imported
- GCR images — let them age out, write new ones to Artifact Registry instead.
- Secret **versions** — only the secret resource is in Terraform. Versions are written out-of-band so values never touch state plaintext beyond what Secret Manager itself stores.

### 8.5 Order of import
1. IAM service accounts (lowest blast radius)
2. GCS buckets
3. Secret Manager secrets (resources only, not versions)
4. Cloud Run services
5. _New_ resources (Cloud SQL, Cloud Tasks, Artifact Registry, WIF) — created fresh, no import needed

---

## 9. New resources to add

### 9.1 Cloud SQL PostgreSQL
- Private IP, no public IP, peered to the default VPC.
- `pgaudit` flag on.
- Backups: daily, 7-day retention staging / 30-day prod, point-in-time recovery on prod.
- Tier sketch:
  - Staging: `db-g1-small`, ~30 GB SSD, no HA.
  - Prod: `db-custom-2-7680`, ~100 GB SSD with auto-grow, **HA (regional)**.
- DB schema/migrations are app-owned (Alembic), **not** Terraform.

### 9.2 Cloud Tasks
- One queue per workload type (e.g. `resume-jobs`).
- Sized conservatively until we have real numbers: `max_dispatches_per_second = 5`, `max_concurrent_dispatches = 10`, exponential retry with `max_attempts = 5`.
- Backend gets a `task-publisher` SA with `roles/cloudtasks.enqueuer` scoped to its queues.

### 9.3 Artifact Registry
- New `docker` repo, `asia-southeast1`.
- CD workflow change in app repo (separate ticket): push to `asia-southeast1-docker.pkg.dev/resumai-platform/app/backend` instead of `gcr.io/...`.
- Keep GCR readable during transition.

---

## 10. CI/CD for Terraform itself

`terraform-plan.yml` (on PRs touching `envs/**` or `modules/**`):
- `terraform fmt -check -recursive`
- `terraform init` (per affected env)
- `terraform validate`
- `terraform plan -out=tfplan` and post the plan as a sticky PR comment
- `tflint` (catches deprecated providers, bad variable names)
- `tfsec` or `checkov` (catches obvious misconfig: public buckets, broad IAM)
- Block merge on plan failure or on a destructive plan to prod without a `terraform-allow-destroy` label

`terraform-apply.yml` (on push to `main`):
- Re-plan, **require manual approval** in GitHub environment for `prod`.
- Apply per-env in dependency order (`global` → `staging` → `prod`).
- WIF auth — no SA keys in this repo either.

---

## 11. Phased rollout

| Phase | Scope | Exit criteria |
| --- | --- | --- |
| **P0 — Bootstrap** | Create `resumai-infra` repo, state buckets, providers pinned, WIF pool | `terraform init` succeeds against GCS backend |
| **P1 — Import staging** | Modules + imports for current staging resources (Cloud Run, GCS, secrets, SAs) | `terraform plan` on staging shows zero destructive changes |
| **P1.5 — Import prod** | qa环境完全基于现有infra代码仓库进行自动容器化，上传，部署 |
| **P2 — Import prod** | Same for prod, behind manual approval | `terraform plan` on prod shows zero destructive changes |
| **P3 — WIF cutover** | App repo workflows switch from SA key → WIF | Old SA keys deleted; CD still green |
| **P4 — Cloud SQL + Tasks** | Provision new resources in staging, then prod | Apps can connect; smoke tests green |
| **P5 — Artifact Registry** | New repo, CD push target switched | First image pulled from AR in staging |

Each phase = its own PR(s). P1 and P2 are the highest-risk and get a designated reviewer + a manual `plan` re-check before merge.

---

## 12. Risks & mitigations

| Risk | Mitigation |
| --- | --- |
| Import-then-plan shows destructive diff (Terraform wants to recreate a live service) | Hard rule: never `apply` an import PR with destructive changes. Iterate on the module until plan is clean. |
| State bucket accidentally deleted | Bucket-level "object versioning" + IAM denying `storage.buckets.delete` to everyone except a break-glass SA. |
| Secret values leaked via state | Only secret *resources* in Terraform, never `version` data. Use `lifecycle { ignore_changes = [secret_data] }` defensively. |
| Lock contention during apply | GCS native locking is enough; document `terraform force-unlock` runbook. |
| WIF misconfig locks out CD | Roll out WIF in parallel with existing SA-key auth; only delete keys after a week of green CD. |
| Cost surprise from Cloud SQL HA in prod | Cost-tag everything; staging starts non-HA. Budget alert at $X/month. |
| Drift from console clicks during migration | After P2 ships, revoke `Editor`/`Owner` from human users on prod; force changes through PRs. |

---

## 13. Open questions for review

1. **Single GCP project vs. split** — Stay single now and split later, or bite the bullet now? My recommendation: stay single (ADR captures the deferral).
2. **Region** — Stay `asia-southeast1`? Confirm with stakeholders.
3. **Who owns secret rotation** — IaC creates the secret resource; who rotates `GEMINI_API_KEY` and on what cadence?
4. **Firebase Hosting in scope?** — Currently out of scope; confirm.
5. **Frontend env vars** (`VITE_*`) — Keep in GitHub secrets, or move into Secret Manager and inject at build time?

---

## 14. Acceptance criteria → deliverables

| AC | Deliverable |
| --- | --- |
| Terraform repo & module structure | `resumai-infra` repo with layout from §3 |
| Remote state in GCS | Three state buckets + `backend.tf` per env (§6) |
| Staging and prod configs exist | `envs/staging/`, `envs/prod/` with per-env tfvars (§5) |
| Existing resources imported safely | `imports.tf` for each env; PR shows zero-destructive `plan` (§8) |
| `fmt`, `validate`, `plan` pass | Required CI checks in `terraform-plan.yml` (§10) |

---

## 15. Appendix: tooling versions

- Terraform `~> 1.9`
- `hashicorp/google` provider `~> 5.40`
- `hashicorp/google-beta` provider `~> 5.40` (for resources still beta-only)
- `tflint` `~> 0.51`, `tfsec` `~> 1.28`
- Pin all of the above in `.terraform-version` / `versions.tf`.
