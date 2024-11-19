terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "1.7.3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

# Remote Backend to obtain VPC details 
data "terraform_remote_state" "local_backend" {
  backend = "local"

  config = {
    path = "../1_Platform_Deployment/terraform.tfstate"
  }
}

provider "vault" {
}

provider "kubernetes" {

  host                   = data.terraform_remote_state.local_backend.outputs.kubernetes_cluster_primary["host"]
  token                  = data.terraform_remote_state.local_backend.outputs.kubernetes_cluster_primary["token"]
  cluster_ca_certificate = data.terraform_remote_state.local_backend.outputs.kubernetes_cluster_primary["cluster_ca_certificate"]

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}