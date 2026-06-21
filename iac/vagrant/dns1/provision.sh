#!/usr/bin/env bash
set -eux

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils

# Copia arquivo de zona se existir no repositório (permite personalização local)
if [ -f /vagrant_data/etc/bind/db.empresa.local ]; then
  cp /vagrant_data/etc/bind/db.empresa.local /etc/bind/db.empresa.local
else
  cat > /etc/bind/db.empresa.local <<'EOF'
$TTL 604800
@   IN  SOA dns.empresa.local. admin.empresa.local. (
  2026062101 ; serial
  604800
  86400
  2419200
  604800 )

@       IN  NS      dns.empresa.local.

dns     IN  A       192.168.56.10
srv01   IN  A       192.168.56.20
web     IN  A       192.168.56.30
EOF
fi

# Adiciona a zona ao named.conf.local se não estiver presente
if ! grep -q 'zone "empresa.local"' /etc/bind/named.conf.local 2>/dev/null; then
  cat >> /etc/bind/named.conf.local <<'EOF'
zone "empresa.local" {
  type master;
  file "/etc/bind/db.empresa.local";
};
EOF
fi

# Ajusta permissões e reinicia serviço
chown root:bind /etc/bind/db.empresa.local || true
systemctl restart bind9 || service bind9 restart || true

# Verificação básica
named-checkconf || true
named-checkzone empresa.local /etc/bind/db.empresa.local || true

echo "Provisionamento concluído. Use 'vagrant ssh' para acessar a VM."