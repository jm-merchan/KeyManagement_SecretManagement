output "ldap_config" {
    value = "kubectl exec -i -t -n openldap $(kubectl get pods --selector=app=openldap -n openldap -o json | jq -r '.items[0].metadata.name') -- ldapadd -h 127.0.0.1 -p 389 -w ${var.auth0_password} -cxD 'cn=admin,dc=learn,dc=example' -f /openldap/config.ldif"
}