terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.11.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

provider "vault" {

}

# Remote Backend to obtain Vault Address
data "terraform_remote_state" "local_backend" {
  backend = "local"

  config = {
    path = "../1_Platform_Deployment/terraform.tfstate"
  }
}