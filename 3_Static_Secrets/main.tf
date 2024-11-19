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