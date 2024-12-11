
locals {
  pki_data = templatefile("${path.module}/templates/install_vault_agent_cert_auth.sh.tpl",
    {
      VAULT_ADDR = data.terraform_remote_state.local_backend.outputs.cluster_primary_fqdn_8200
      ROLE       = vault_cert_auth_backend_role.cert.name
      CERT       = vault_pki_secret_backend_cert.app.certificate
      KEY        = vault_pki_secret_backend_cert.app.private_key
    }
  )
}

resource "google_compute_instance" "pki" {
  name         = "vm-cert-auth-method"
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

  metadata_startup_script = local.pki_data

  lifecycle {
    ignore_changes = [
      metadata_startup_script
    ]
  }
}
