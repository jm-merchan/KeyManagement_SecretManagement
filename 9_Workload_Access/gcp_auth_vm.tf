# Basic VM
# https://cloud.google.com/docs/terraform/create-vm-instance

# Data source to fetch the latest Debian image from Google Cloud
data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

data "google_compute_zones" "available" {
  region = var.region
}


# Service Account for host, we will use it for firewall rules
resource "google_service_account" "main" {
  account_id   = "vm-sa-gcp"
  display_name = "SA for VMs"
}

# Mapping the SA to SA Token Creator
resource "google_project_iam_member" "gcp_instance_sa" {
  member  = "serviceAccount:${google_service_account.main.email}"
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
}

locals {
  target_data = templatefile("${path.module}/templates/install_vault_agent_gcp_auth.sh.tpl",
    {
      VAULT_ADDR = data.terraform_remote_state.local_backend.outputs.cluster_primary_fqdn_8200
      ROLE       = var.gcp_auth_role_name
      SA         = google_service_account.main.email
    }
  )
}

resource "google_compute_instance" "default" {
  name         = "vm-gcp-auth-method"
  machine_type = var.machine_type
  zone         = data.google_compute_zones.available.names[0]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }

  network_interface {
    network    = google_compute_network.global_vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    # access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = google_service_account.main.email
  }

  metadata_startup_script = local.target_data

  lifecycle {
    ignore_changes = [
      metadata_startup_script
    ]
  }
}
