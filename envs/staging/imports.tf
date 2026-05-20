import {
  to = module.backend_runtime_sa.google_service_account.this
  id = "projects/resumai-platform/serviceAccounts/resumai-backend@resumai-platform.iam.gserviceaccount.com"
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
  to = module.gemini_api_key_secret.google_secret_manager_secret.this
  id = "projects/resumai-platform/secrets/gemini-api-key"
}

import {
  to = module.gemini_api_key_secret.google_secret_manager_secret_iam_member.this["cloud_run_secret_accessor"]
  id = "projects/resumai-platform/secrets/gemini-api-key roles/secretmanager.secretAccessor serviceAccount:367288272676-compute@developer.gserviceaccount.com"
}

import {
  to = module.backend.google_cloud_run_service.this
  id = "locations/asia-southeast1/namespaces/resumai-platform/services/test-service"
}
