terraform {
  backend "gcs" {
    bucket = "resumai-infra-tfstate-staging"
    prefix = "envs/staging"
  }
}

