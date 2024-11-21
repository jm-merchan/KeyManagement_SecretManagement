output "cert_command" {
  value = "VAULT_ADDR=${data.terraform_remote_state.local_backend.outputs.cluster_primary_fqdn_8200} vault login -method=cert -client-cert=vault-cert.pem -client-key=vault-key.pem"
}