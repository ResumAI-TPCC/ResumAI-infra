terraform {
  backend "gcs" {
    bucket = "resumai-infra-tfstate-global"
    prefix = "global"
  }
}

