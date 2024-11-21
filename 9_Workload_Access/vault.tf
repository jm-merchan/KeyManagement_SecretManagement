# Create Service Account for Access
resource "google_service_account" "vault_auth_sa" {
  account_id   = "vault-auth-sa"
  display_name = "Vault Service Account for Auth Method"
}

# Role to sync secrets
resource "google_project_iam_custom_role" "vault_auth_sa" {
  role_id     = "vault_auth_sa_role"
  title       = "vault_auth_sa_role"
  description = "Custom role for Vault GCP Auth method"
  permissions = [
    # https://developer.hashicorp.com/vault/docs/auth/gcp#required-gcp-permissions
    "iam.serviceAccounts.get",
    "iam.serviceAccountKeys.get",
    "compute.instances.get",
    "compute.instanceGroups.list",
    "resourcemanager.projects.get",
  ]
}

# Map Service account to role
resource "google_project_iam_member" "vault_auth" {
  member  = "serviceAccount:${google_service_account.vault_auth_sa.email}"
  project = var.project_id
  role    = google_project_iam_custom_role.vault_auth_sa.name
}

# Obtain the service account credentials
resource "google_service_account_key" "vault_auth_sa" {
  service_account_id = google_service_account.vault_auth_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Create Auth Mount Point
resource "vault_gcp_auth_backend" "gcp" {
  credentials = base64decode(google_service_account_key.vault_auth_sa.private_key)
}

# Create Role to associate SA with Policy
resource "vault_gcp_auth_backend_role" "gcp" {
  backend                = vault_gcp_auth_backend.gcp.path
  role                   = var.gcp_auth_role_name
  type                   = "iam"
  token_ttl              = 300
  token_max_ttl          = 600
  token_policies         = ["devk8s"]
  bound_service_accounts = [google_service_account.main.email]
}


# Create Certificate that will be passed to application

resource "vault_pki_secret_backend_cert" "app" {
  backend     = "pki_int"
  name        = "example-dot-com"
  common_name = "gcpvm.test.com"
}

# This time using TLS Auth Method
resource "vault_auth_backend" "cert" {
  path = "cert"
  type = "cert"
}

resource "vault_cert_auth_backend_role" "cert" {
  name           = "Cert_Auth_GCP_VM"
  certificate    = vault_pki_secret_backend_cert.app.issuing_ca
  backend        = vault_auth_backend.cert.path
  token_ttl      = 3600
  token_max_ttl  = 7200
  token_policies = ["devk8s"]
}