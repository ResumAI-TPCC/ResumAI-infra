terraform {
  backend "gcs" {
    bucket = "resumai-infra-tfstate-prod"
    prefix = "envs/prod"
  }
}

