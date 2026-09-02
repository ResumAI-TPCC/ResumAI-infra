import {
  to = module.resumes_bucket.google_storage_bucket.this
  id = "prod-resumai-resumes"
}

import {
  to = module.backend.google_cloud_run_service.this
  id = "locations/asia-southeast1/namespaces/resumai-platform/services/prod-service"
}

