import {
  to = module.backend_runtime_sa.google_service_account.this
  id = "projects/resumai-platform/serviceAccounts/resumai-backend@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = module.cloud_run_runtime_sa.google_service_account.this
  id = "projects/resumai-platform/serviceAccounts/cloud-run-staging-runtime@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = google_service_account_iam_member.deploy_staging_runtime_user
  id = "projects/resumai-platform/serviceAccounts/cloud-run-staging-runtime@resumai-platform.iam.gserviceaccount.com roles/iam.serviceAccountUser serviceAccount:deploy-staging@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = module.github_actions_sa.google_service_account.this
  id = "projects/resumai-platform/serviceAccounts/github-actions-sa@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = module.resumes_bucket.google_storage_bucket.this
  id = "resumai-platform-resumes"
}

import {
  to = module.resumes_bucket.google_storage_bucket_iam_member.this["backend_object_creator"]
  id = "resumai-platform-resumes roles/storage.objectCreator serviceAccount:resumai-backend@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = module.resumes_bucket.google_storage_bucket_iam_member.this["backend_object_viewer"]
  id = "resumai-platform-resumes roles/storage.objectViewer serviceAccount:resumai-backend@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = module.resumes_bucket.google_storage_bucket_iam_member.this["cloud_run_object_admin"]
  id = "resumai-platform-resumes roles/storage.objectAdmin serviceAccount:cloud-run-staging-runtime@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = module.gemini_api_key_secret.google_secret_manager_secret.this
  id = "projects/resumai-platform/secrets/gemini-api-key"
}

import {
  to = module.gemini_api_key_secret.google_secret_manager_secret_iam_member.this["cloud_run_secret_accessor"]
  id = "projects/resumai-platform/secrets/gemini-api-key roles/secretmanager.secretAccessor serviceAccount:cloud-run-staging-runtime@resumai-platform.iam.gserviceaccount.com"
}

import {
  to = module.backend.google_cloud_run_service.this
  id = "locations/asia-southeast1/namespaces/resumai-platform/services/test-service"
}
