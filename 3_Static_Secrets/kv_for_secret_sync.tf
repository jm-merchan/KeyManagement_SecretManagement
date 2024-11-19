resource "vault_mount" "kvv2" {
  path        = "staticv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "secret1" {
  mount               = vault_mount.kvv2.path
  name                = "secret1"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap",
      foo = "bar"
    }
  )
  custom_metadata {
    max_versions = 5
    data = {
      org  = "secret1@example.com",
      type = "json"
    }
  }
}

resource "vault_secrets_sync_association" "secret1" {
  name        = vault_secrets_sync_gcp_destination.gcp.name
  type        = vault_secrets_sync_gcp_destination.gcp.type
  mount       = vault_mount.kvv2.path
  secret_name = vault_kv_secret_v2.secret1.name
}

resource "vault_kv_secret_v2" "secret2" {
  mount               = vault_mount.kvv2.path
  name                = "secret2"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      secret2 = "cuidado",
      data    = "peligro"
    }
  )
  custom_metadata {
    max_versions = 10
    data = {
      org  = "secret2@example.com",
      type = "json"
    }
  }
}

resource "vault_secrets_sync_association" "secret2" {
  name        = vault_secrets_sync_gcp_destination.gcp.name
  type        = vault_secrets_sync_gcp_destination.gcp.type
  mount       = vault_mount.kvv2.path
  secret_name = vault_kv_secret_v2.secret2.name
}


resource "vault_kv_secret_v2" "secret3" {
  mount               = vault_mount.kvv2.path
  name                = "secret3"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      cert = file("~/.ssh/id_hashi.pub"),
    }
  )
  custom_metadata {
    max_versions = 10
    data = {
      org  = "secret3@example.com",
      type = "certificate"
    }
  }
}

resource "vault_secrets_sync_association" "secret3" {
  name        = vault_secrets_sync_gcp_destination.gcp.name
  type        = vault_secrets_sync_gcp_destination.gcp.type
  mount       = vault_mount.kvv2.path
  secret_name = vault_kv_secret_v2.secret3.name
}