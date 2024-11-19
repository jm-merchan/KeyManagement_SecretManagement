# Enable Secret Sync
resource "vault_secrets_sync_config" "global_config" {
  disabled       = false
  queue_capacity = 500000
}


# Create Service Account for Access
resource "google_service_account" "secret_sync" {
  account_id   = "iam-vault-secret-sync"
  display_name = "Vault Service Account"
}

# Role to sync secrets
resource "google_project_iam_custom_role" "secret_sync" {
  role_id     = "vault_secret_sync"
  title       = "vault_secret_sync"
  description = "Custom role for Vault secret sync"
  permissions = [
    # Secret Sync Permissions
    "secretmanager.secrets.create",
    "secretmanager.secrets.get",
    "secretmanager.secrets.delete",
    "secretmanager.versions.add",
    "secretmanager.versions.access",
    # KMSE permissions
    "cloudkms.cryptoKeys.create",
    "cloudkms.cryptoKeys.update",
    "cloudkms.importJobs.create",
    "cloudkms.importJobs.get",
    "cloudkms.cryptoKeyVersions.list",
    "cloudkms.cryptoKeyVersions.destroy",
    "cloudkms.cryptoKeyVersions.update",
    "cloudkms.cryptoKeyVersions.create",
  ]
}

# Map Service account to role
resource "google_project_iam_member" "vault_secret" {
  member  = "serviceAccount:${google_service_account.secret_sync.email}"
  project = var.project_id
  role    = google_project_iam_custom_role.secret_sync.name
}

# Obtain the service account credentials
resource "google_service_account_key" "secret_sync" {
  service_account_id = google_service_account.secret_sync.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Sync Secrets to GCP
resource "vault_secrets_sync_gcp_destination" "gcp" {
  name                 = "gcp-dest"
  project_id           = var.project_id
  credentials          = base64decode(google_service_account_key.secret_sync.private_key)
  secret_name_template = "vault_sync_{{ .SecretBaseName | lowercase }}" # Name of the secret
  custom_tags = {
    "Managed_by" = "HashiCorp Vault"
  }
}

resource "local_file" "service_account_key_file" {
  content  = google_service_account_key.secret_sync.private_key
  filename = "service_account_key.json"
}

output "private_key" {
  value = google_service_account_key.secret_sync.private_key
  sensitive = true
}