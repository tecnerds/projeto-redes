Se você quis dizer **servidor DNS no Debian**, a forma mais tradicional é utilizando o **BIND9**, que é o servidor DNS mais usado em ambientes Linux.

## 1. Instalar o BIND9

```bash
sudo apt update
sudo apt install bind9 bind9utils bind9-doc -y
```

Verifique se o serviço está ativo:

```bash
sudo systemctl status bind9
```

---

## 2. Entender a estrutura básica

Os principais arquivos ficam em:

```text
/etc/bind/
├── named.conf
├── named.conf.options
├── named.conf.local
├── db.seudominio.com
```

* `named.conf.options` → configurações globais.
* `named.conf.local` → definição das zonas DNS.
* `db.seudominio.com` → registros DNS do domínio.

---

## 3. Configurar uma zona DNS

Edite:

```bash
sudo nano /etc/bind/named.conf.local
```

Adicione:

```bash
zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
};
```

---

## 4. Criar o arquivo da zona

Copie o modelo:

```bash
sudo cp /etc/bind/db.local /etc/bind/db.empresa.local
```

Edite:

```bash
sudo nano /etc/bind/db.empresa.local
```

Exemplo:

```text
$TTL    604800
@       IN      SOA     dns.empresa.local. admin.empresa.local. (
                        2026062101 ; serial (YYYYMMDDnn)
                        604800
                        86400
                        2419200
                        604800 )

@       IN      NS      dns.empresa.local.

dns     IN      A       192.168.1.10
srv01   IN      A       192.168.1.20
web     IN      A       192.168.1.30
```

Nesse exemplo:

| Nome                | IP           |
| ------------------- | ------------ |
| dns.empresa.local   | 192.168.1.10 |
| srv01.empresa.local | 192.168.1.20 |
| web.empresa.local   | 192.168.1.30 |

---

## 5. Validar a configuração

Verifique a sintaxe:

```bash
sudo named-checkconf
```

Verifique a zona:

```bash
sudo named-checkzone empresa.local /etc/bind/db.empresa.local
```

Resultado esperado:

```text
OK
```

---

## 6. Reiniciar o serviço

```bash
sudo systemctl restart bind9
```

Verifique:

```bash
sudo systemctl status bind9
```

---

## 7. Configurar um cliente para usar o DNS

No Debian cliente:

```bash
sudo nano /etc/resolv.conf
```

Adicione:

```text
nameserver 192.168.1.10
```

---

## 8. Testar

Instale as ferramentas DNS:

```bash
sudo apt install dnsutils -y
```

Teste:

```bash
nslookup web.empresa.local
```

ou

```bash
dig web.empresa.local
```

---

## Laboratório para aprender na prática

Como você está estudando redes e DNS, recomendo montar 3 VMs Debian:

```text
VM1 - DNS Server (BIND9)
IP: 192.168.1.10

VM2 - Cliente
IP: 192.168.1.20

VM3 - Cliente
IP: 192.168.1.30
```

Fluxo:

```text
Cliente → Consulta DNS → Servidor DNS
        ← Resposta com IP
```

Depois evolua para estes tópicos detalhados (docs):

- [DNS Autoritativo](docs/dns-autoritativo.md)
- [DNS Cache (resolver em cache)](docs/dns-cache.md)
- [DNS Master/Slave (replicação)](docs/dns-master-slave.md)
- [DNS Reverso (IP → Nome)](docs/dns-reverso.md)
- [Integração DNS + DHCP (DDNS)](docs/dns-dhcp-integration.md)

Essas etapas refletem uma progressão prática para ambientes reais e ajudam a entender os aspectos operacionais e de segurança da resolução de nomes.

## Exemplo: `named.conf.options`

No arquivo `/etc/bind/named.conf.options` inclua opções globais, encaminhadores e restrições básicas:

```text
options {
    directory "/var/cache/bind";

    recursion yes;                // permitir resolução recursiva para clientes autorizados
    allow-query { 192.168.1.0/24; }; // restringir consultas à rede interna
    allow-recursion { 192.168.1.0/24; };

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    forward first; // ou "forward only" conforme sua política
    dnssec-validation auto;
};
```

## Zona reversa

Não esqueça de adicionar a zona reversa em `named.conf.local`, por exemplo para `192.168.1.0/24`:

```text
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.1";
};
```

E criar o arquivo de zona reversa com entradas PTR (veja `docs/dns-reverso.md` para exemplo).

## Segurança e firewall

- Restrinja transferências de zona com `allow-transfer { ip_do_slave; };` e prefira TSIG para autorizar transferências.
- Abra as portas DNS no firewall:

```bash
sudo ufw allow 53/udp
sudo ufw allow 53/tcp
```

- Não exponha recursão para a Internet: configure `allow-recursion` apenas para sua(s) rede(s).

## Clientes modernos

Em muitas distribuições o `/etc/resolv.conf` é gerido por `systemd-resolved`, NetworkManager ou cloud-init. Em clientes gerenciados prefira configurar via:

- `systemd-resolved` (ex: `systemd-resolve --set-dns=192.168.1.10 --interface=eth0`),
- ou ajustar a configuração do NetworkManager para apontar o DNS.

Editar `/etc/resolv.conf` manualmente pode ser sobrescrito; verifique o gerenciador de rede do sistema.

## Testes avançados e depuração

- Teste autoritatividade e cache:

```bash
dig @192.168.1.10 web.empresa.local +short
dig @192.168.1.10 -x 192.168.1.30 +short
dig @192.168.1.10 empresa.local AXFR   # testar AXFR (se permitido)
```

- Verifique transferências e notificações com `rndc` e logs em `/var/log/syslog`.
- Capturar tráfego DNS (quando necessário):

```bash
sudo tcpdump -n -i any port 53
```

## Recursos adicionais

Consulte os documentos gerados em `docs/` para guias detalhados e exemplos práticos:

- [docs/dns-autoritativo.md](docs/dns-autoritativo.md)
- [docs/dns-cache.md](docs/dns-cache.md)
- [docs/dns-master-slave.md](docs/dns-master-slave.md)
- [docs/dns-reverso.md](docs/dns-reverso.md)
- [docs/dns-dhcp-integration.md](docs/dns-dhcp-integration.md)
