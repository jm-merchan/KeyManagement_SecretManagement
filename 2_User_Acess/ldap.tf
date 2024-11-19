# Create OpenLDAP namespace
resource "kubernetes_namespace" "openldap" {
  metadata {
    name = "openldap"
  }
}

# Secret for admin database
resource "kubernetes_secret" "ldap" {
  metadata {
    name = "ldap"
    namespace = kubernetes_namespace.openldap.metadata[0].name
  }

  data = {
    "LDAP_ADMIN_PASSWORD" = "${var.auth0_password}"
  }

}


# Deployment for LDAP Server
resource "kubernetes_deployment" "ldap" {
  timeouts {
    create = "1m"
  }
  metadata {
    name = "openldap"
    namespace = kubernetes_namespace.openldap.metadata[0].name
    labels = {
      app = "openldap"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "openldap"
      }
    }

    template {
      metadata {
        labels = {
          app     = "openldap"
          service = "openldap"
        }
      }

      spec {
        volume {
          name = "openldap"

          config_map {
            name = "openldap"
          }
        }
        
        container {
          image = "osixia/openldap:1.5.0"
          name  = "openldap"

          volume_mount {
            name       = "openldap"
            mount_path = "/openldap"
            read_only  = false
          }

          env {
            name  = "LDAP_ORGANISATION"
            value = "learn"
          }

          env {
            name  = "LDAP_DOMAIN"
            value = "learn.example"
          }

          env_from {           
            secret_ref {
              name = kubernetes_secret.ldap.metadata[0].name
            }
          }

          port {
            name = "tcp-ldap"
            container_port = 389
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "openldap" {
  metadata {
    name = "openldap"
    namespace = kubernetes_namespace.openldap.metadata[0].name
    labels = {
      app = "openldap"
    }
  }

  spec {
    type = "LoadBalancer"
    selector = {
      app = "openldap"
    }

    port {
      name        = "tcp-ldap"
      port        = 389
      target_port = 389
    }
  }
}

resource "kubernetes_service" "openldap-internal" {
  metadata {
    name = "openldap-internal"
    namespace = kubernetes_namespace.openldap.metadata[0].name
    labels = {
      app = "openldap"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "openldap"
    }

    port {
      name        = "tcp-ldap"
      port        = 389
      target_port = 389
    }
  }
}


resource "kubernetes_config_map" "openldap" {
  metadata {
    name = "openldap"
    namespace = kubernetes_namespace.openldap.metadata[0].name
  }

  data = {
    "config.ldif" = <<EOF
dn: ou=groups,dc=learn,dc=example
objectClass: organizationalunit
objectClass: top
ou: groups
description: groups of users

dn: ou=users,dc=learn,dc=example
objectClass: organizationalunit
objectClass: top
ou: users
description: users

dn: cn=audit,ou=groups,dc=learn,dc=example
objectClass: groupofnames
objectClass: top
description: testing group for audit
cn: audit
member: cn=alice,ou=users,dc=learn,dc=example

dn: cn=alice,ou=users,dc=learn,dc=example
objectClass: person
objectClass: top
sn: alice
memberOf: cn=audit,ou=groups,dc=learn,dc=example
userPassword: ${var.auth0_password}

dn: cn=admin,ou=groups,dc=learn,dc=example
objectClass: groupofnames
objectClass: top
description: testing group for admin
cn: admin
member: cn=peter,ou=users,dc=learn,dc=example

dn: cn=peter,ou=users,dc=learn,dc=example
objectClass: person
objectClass: top
sn: peter
memberOf: cn=admin,ou=groups,dc=learn,dc=example
userPassword: ${var.auth0_password}

dn: cn=serviceaccount,ou=users,dc=learn,dc=example
objectClass: person
objectClass: top
sn: serviceaccount
memberOf: cn=audit,ou=groups,dc=learn,dc=example
userPassword: ${var.auth0_password}

EOF

  }
}