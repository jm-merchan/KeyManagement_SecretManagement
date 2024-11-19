

# Service Account for Vault Secret engine
resource "google_service_account" "gcp_engine" {
  account_id   = "iam-vault-gcp-engine"
  display_name = "Vault Service Account for Engine"
}

# Role to Create SAs
resource "google_project_iam_custom_role" "gcp_engine" {
  role_id     = "vault_gcp_engine"
  title       = "vault_gcp_engine"
  description = "Custom role for Vault secret gcp_engine"
  permissions = [
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.update",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccounts.getAccessToken",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy"
  ]
}
# Map Service account to role
resource "google_project_iam_member" "boundary_secret" {
  member  = "serviceAccount:${google_service_account.gcp_engine.email}"
  project = var.project_id
  role    = google_project_iam_custom_role.gcp_engine.name
}

# Obtain the service account credentials
resource "google_service_account_key" "gcp_engine" {
  service_account_id = google_service_account.gcp_engine.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "vault_gcp_secret_backend" "gcp" {
  path = "gcp"
  credentials = base64decode(google_service_account_key.gcp_engine.private_key)
}

resource "vault_gcp_secret_roleset" "roleset" {
  backend      = vault_gcp_secret_backend.gcp.path
  roleset      = "project_viewer"
  secret_type  = "access_token"
  project      = var.project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"

    roles = [
      "roles/viewer",
    ]
  }
}