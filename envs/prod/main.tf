locals {
  common_labels = {
    app       = "resumai"
    env       = var.env
    managedby = "terraform"
  }
}

