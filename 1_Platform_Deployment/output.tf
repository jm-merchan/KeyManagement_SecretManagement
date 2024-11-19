# Outputs for cluster1
output "cluster_primary_fqdn_8200" {
  value = module.vault-primary.fqdn_8200
}

output "cluster_primary_init_remote" {
  value = module.vault-primary.init_remote
}

output "cluster_primary_fqdn_8201" {
  value = module.vault-primary.fqdn_8201
}

output "cluster_primary_fqdn_kmip" {
  value = module.vault-primary.fqdn_kmip
}

output "cluster_primary_read_vault_token" {
  value = module.vault-primary.read_vault_token
}

output "kubernetes_cluster_primary" {
  value     = module.vault-primary.kubernetes_cluster
  sensitive = true
}

output "configure_kubectl_cluster_primary" {
  value = module.vault-primary.configure_kubectl
}

# --------------------------------------

# Outputs for cluster-pr
output "cluster_pr_fqdn_8200" {
  value = module.vault-pr.fqdn_8200
}

output "cluster_pr_init_remote" {
  value = module.vault-pr.init_remote
}

output "cluster_pr_fqdn_kmip" {
  value = module.vault-pr.fqdn_kmip
}

output "cluster_pr_fqdn_8201" {
  value = module.vault-pr.fqdn_8201
}

output "cluster_pr_read_vault_token" {
  value = module.vault-pr.read_vault_token
}

output "kubernetes_cluster_pr" {
  value     = module.vault-pr.kubernetes_cluster
  sensitive = true
}

output "configure_kubectl_cluster_pr" {
  value = module.vault-pr.configure_kubectl
}

# --------------------------------------

# Outputs for cluster-dr
output "cluster_dr_fqdn_8200" {
  value = module.vault-dr.fqdn_8200
}

output "cluster_dr_init_remote" {
  value = module.vault-dr.init_remote
}

output "cluster_dr_fqdn_kmip" {
  value = module.vault-dr.fqdn_kmip
}

output "cluster_dr_fqdn_8201" {
  value = module.vault-dr.fqdn_8201
}

output "cluster_dr_read_vault_token" {
  value = module.vault-dr.read_vault_token
}

output "kubernetes_cluster_dr" {
  value     = module.vault-dr.kubernetes_cluster
  sensitive = true
}

output "configure_kubectl_cluster_dr" {
  value = module.vault-dr.configure_kubectl
}