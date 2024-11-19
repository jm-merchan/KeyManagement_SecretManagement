
resource "auth0_client" "vault" {
  name        = "vault"
  description = "Vault Authentication"
  app_type    = "regular_web"
  callbacks = [
    "${data.terraform_remote_state.local_backend.outputs.cluster_primary_fqdn_8200}/ui/vault/auth/oidc/oidc/callback",
    "${data.terraform_remote_state.local_backend.outputs.cluster_pr_fqdn_8200}/ui/vault/auth/oidc/oidc/callback",
    "${data.terraform_remote_state.local_backend.outputs.cluster_dr_fqdn_8200}/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]

  oidc_conformant = true

  jwt_configuration {
    alg = "RS256"
  }
}


resource "auth0_user" "admin" {
  connection_name = "Username-Password-Authentication"
  name            = "Vault Admin"
  email           = "peter@vaultproject.io"
  email_verified  = true
  password        = var.auth0_password
  app_metadata    = "{\"roles\": {\"group1\":\"admin\"}}"
}

resource "auth0_user" "security" {
  connection_name = "Username-Password-Authentication"
  name            = "Security User"
  email           = "test.security@vaultproject.io"
  email_verified  = true
  password        = var.auth0_password
  app_metadata    = "{\"roles\": {\"group1\":\"security\"}}"
}

resource "auth0_user" "audit" {
  connection_name = "Username-Password-Authentication"
  name            = "Audit User"
  email           = "alice@vaultproject.io"
  email_verified  = true
  password        = var.auth0_password
  app_metadata    = "{\"roles\": {\"group1\":\"audit\"}}"
}

resource "auth0_user" "namespace_admin" {
  connection_name = "Username-Password-Authentication"
  name            = "ns1 Admin"
  email           = "ns1admin@vaultproject.io"
  email_verified  = true
  password        = var.auth0_password
  app_metadata    = "{\"roles\": {\"group1\": \"ns1\"}}"
}

# An Auth0 Client loaded using its ID.
data "auth0_client" "vault" {
  client_id = auth0_client.vault.client_id
}

data "auth0_tenant" "tenant" {}


resource "auth0_action" "user_role" {
  name   = "Set user role"
  code   = <<-EOT
          exports.onExecutePostLogin = async (event, api) => {
          if (event.authorization) {
            event.user.app_metadata = event.user.app_metadata || {};
            api.idToken.setCustomClaim("https://example.com/roles",event.user.app_metadata.roles.group1);
            api.idToken.setCustomClaim("https://example.com/email",event.user.email);
            }
          };
    EOT
  deploy = true

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

resource "auth0_trigger_action" "post_login_alert_action" {
  trigger   = "post-login"
  action_id = auth0_action.user_role.id
}