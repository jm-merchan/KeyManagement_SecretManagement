#!/usr/bin/env bash

export instance_id="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/id -H Metadata-Flavor:Google)"

export local_ipv4="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip -H Metadata-Flavor:Google)"

# install package

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y vault jq 

# Install Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install


echo "Configuring system time"
timedatectl set-timezone UTC

sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault Agent"
Documentation="https://developer.hashicorp.com/vault/docs"
ConditionFileNotEmpty="/etc/vault.d/vault.hcl"

[Service]
User=vault
Group=vault
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=vault agent -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

# Create a template to render Secrets
cat << EOF > /tmp/customer.tmpl
{{ with secret "database/creds/readonly" }}postgresql://{{ .Data.username }}:{{ .Data.password }}@postgres:5432/wizard{{ end }}
EOF

# Vault Agent Configuration
sudo cat << EOF > /etc/vault.d/vault.hcl
pid_file = "/tmp/pidfile"
vault {
   address = "${VAULT_ADDR}"
   tls_skip_verify = true
}

template {
   source = "/tmp/customer.tmpl"
   destination = "/tmp/customer.txt"
}

auto_auth {
   method {
      type = "gcp"
      config = {
         role = "${ROLE}"
         type = "iam"
         service_account="${SA}"
      }
   }
   sink "file" {
      type= "file"
      config = {
            path = "/tmp/vault-token-via-agent"
            mode = 0644
      }
   }
}
EOF


# Start Vault Agent
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault