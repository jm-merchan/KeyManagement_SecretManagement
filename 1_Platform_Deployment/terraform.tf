
terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.26.0"
    }
  }
}

provider "acme" {
  server_url = local.acme_prod
}

module "vault-primary" {
  source               = "jm-merchan/vaultgke/google"
  version              = "0.0.3"
  email                = var.email
  project_id           = var.project_id
  dns_zone_name_ext    = var.dns_zone_name_ext
  cluster-name         = "vault-primary"
  vault_version        = var.vault_version
  vault_enterprise     = var.vault_enterprise
  region               = "europe-southwest1"
  kmip_enable          = true
  vpc_name             = "vpc1"
  acme_prod            = true
  gke_autopilot_enable = true
  vault_license        = var.vault_license
  node_count           = 5
  location             = "global"
  storage_location     = "EU"
  create_vpc           = true
  expose               = "External"
}


module "vault-pr" {
  source               = "jm-merchan/vaultgke/google"
  version              = "0.0.3"
  email                = var.email
  project_id           = var.project_id
  dns_zone_name_ext    = var.dns_zone_name_ext
  cluster-name         = "vault-pr"
  vault_version        = var.vault_version
  vault_enterprise     = var.vault_enterprise
  region               = "europe-north1"
  kmip_enable          = true
  vpc_name             = "vpc2"
  acme_prod            = true
  gke_autopilot_enable = true
  vault_license        = var.vault_license
  node_count           = 5
  location             = "global"
  storage_location     = "EU"
  create_vpc           = true
  expose               = "External"
}

module "vault-dr" {
  source               = "jm-merchan/vaultgke/google"
  version              = "0.0.3"
  email                = var.email
  project_id           = var.project_id
  dns_zone_name_ext    = var.dns_zone_name_ext
  cluster-name         = "vault-dr"
  vault_version        = var.vault_version
  vault_enterprise     = var.vault_enterprise
  region               = "us-east1"
  kmip_enable          = true
  vpc_name             = "vpc2"
  acme_prod            = true
  gke_autopilot_enable = true
  vault_license        = var.vault_license
  node_count           = 5
  location             = "global"
  storage_location     = "EU"
  create_vpc           = true
  expose               = "External"
}
