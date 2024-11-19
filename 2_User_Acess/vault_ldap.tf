resource "vault_ldap_auth_backend" "ldap" {
  path         = "ldap"
  binddn       = "cn=admin,dc=learn,dc=example"
  bindpass     = var.auth0_password
  url          = "ldap://${kubernetes_service.openldap.status[0].load_balancer[0].ingress[0].ip}:389"
  userdn       = "ou=users,dc=learn,dc=example"
  userattr     = "cn"
  userfilter   = "({{.UserAttr}}={{.Username}})"
  groupdn      = "dc=learn,dc=example"
  groupfilter  = "(&(objectClass=person)(cn={{.Username}}))"
  groupattr    = "memberOf"
  insecure_tls = true
}

resource "vault_ldap_auth_backend_group" "admin" {
    groupname = "admin"
    policies  = ["admin"]
    backend   = vault_ldap_auth_backend.ldap.path
}

resource "vault_ldap_auth_backend_group" "audit" {
    groupname = "audit"
    policies  = ["audit"]
    backend   = vault_ldap_auth_backend.ldap.path
}


resource "vault_identity_entity" "peter" {
  name      = "peter"
  policies  = ["admin"]
  metadata  = {
    user = "peter"
  }
}

resource "vault_identity_entity_alias" "peter_oidc" {
  name            = "peter@vaultproject.io"
  mount_accessor  = vault_jwt_auth_backend.oidc.accessor
  canonical_id    = vault_identity_entity.peter.id
}

resource "vault_identity_entity_alias" "peter_ldap" {
  name            = "peter"
  mount_accessor  = vault_ldap_auth_backend.ldap.accessor
  canonical_id    = vault_identity_entity.peter.id
}

resource "vault_identity_entity" "alice" {
  name      = "alice"
  policies  = ["audit"]
  metadata  = {
    user = "alice"
  }
}

resource "vault_identity_entity_alias" "alice_oidc" {
  name            = "alice@vaultproject.io"
  mount_accessor  = vault_jwt_auth_backend.oidc.accessor
  canonical_id    = vault_identity_entity.alice.id
}

resource "vault_identity_entity_alias" "alice_ldap" {
  name            = "alice"
  mount_accessor  = vault_ldap_auth_backend.ldap.accessor
  canonical_id    = vault_identity_entity.alice.id
}