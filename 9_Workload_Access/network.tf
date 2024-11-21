# Create a global VPC
resource "google_compute_network" "global_vpc" {
  name                    = "vpc-test"
  auto_create_subnetworks = false # Disable default subnets
}

# Create subnets in a given region
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet"
  ip_cidr_range = "10.253.253.0/24"
  region        = var.region
  network       = google_compute_network.global_vpc.id
}

# Create a Cloud Router
resource "google_compute_router" "custom_router" {
  name    = "custom-router"
  region  = var.region
  network = google_compute_network.global_vpc.self_link
}

# Configure Cloud NAT on the Cloud Router
resource "google_compute_router_nat" "custom_nat" {
  name   = "custom-nat"
  router = google_compute_router.custom_router.name
  region = google_compute_router.custom_router.region

  nat_ip_allocate_option             = "AUTO_ONLY"                     # Google will automatically allocate IPs for NAT
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" # Allow all internal VMs to use this NAT for outbound traffic
}

# Allow SSH from my IP to Vault Public IPs
resource "google_compute_firewall" "ssh" {
  name                    = "${var.region}-ssh"
  network                 = google_compute_network.global_vpc.id
  description             = "The firewall which allows the ingress of SSH traffic to Vault instances"
  direction               = "INGRESS"
  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = [google_service_account.main.email]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}


# Rule to allow all outbound traffic 
resource "google_compute_firewall" "allow_vault_outbound" {
  name        = "${var.region}-allow-outbound"
  network     = google_compute_network.global_vpc.id
  description = "Rule to allow all outbound traffic"
  allow {
    protocol = "tcp"
  }
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"] # Allow from any IP (internet)
}