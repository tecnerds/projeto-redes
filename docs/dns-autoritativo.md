# DNS Autoritativo

Descrição

Um servidor DNS autoritativo responde por zonas para as quais é responsável (master). Ele contém os arquivos de zona com registros que são fonte verdadeira para um domínio.

Quando usar

- Quando você hospeda nomes de domínio internos ou públicos e precisa gerenciar os registros A/AAAA/CNAME/SOA/NS.

Configuração básica (BIND9)

1. Defina a zona em `/etc/bind/named.conf.local`:

```text
zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
    allow-transfer { 192.168.1.11; };    # IP do slave (se houver)
    notify yes;
};
```

2. Exemplo de arquivo de zona `/etc/bind/db.empresa.local` (usar serial YYYYMMDDnn):

```text
$TTL 604800
@   IN  SOA dns.empresa.local. admin.empresa.local. (
        2026062101 ; serial
        604800     ; refresh
        86400      ; retry
        2419200    ; expire
        604800 )   ; minimum

@       IN  NS      dns.empresa.local.
dns     IN  A       192.168.1.10
srv01   IN  A       192.168.1.20
web     IN  A       192.168.1.30
```

Verificações e comandos úteis

- Sintaxe geral:

```bash
sudo named-checkconf
```

- Verificar a zona:

```bash
sudo named-checkzone empresa.local /etc/bind/db.empresa.local
```

- Recarregar sem interromper:

```bash
sudo rndc reload empresa.local
```

- Testar consulta autoritativa:

```bash
dig @192.168.1.10 web.empresa.local +short
```

Boas práticas e segurança

- Use serials baseados em data (ex: `YYYYMMDD01`).
- Restrinja transferências de zona (`allow-transfer`) somente a IPs conhecidos.
- Habilite notifies para que slaves recebam atualizações.
- Faça backup do arquivo de zona antes de alterações: `sudo cp /etc/bind/db.empresa.local /etc/bind/db.empresa.local.bak`.
- Monitore logs (`/var/log/syslog` ou configuração personalizada) e use `sudo tcpdump -n -i any port 53` para inspecionar tráfego DNS se necessário.

Próximos passos

- Configurar slave (ver `docs/dns-master-slave.md`).
- Adicionar zona reversa (`docs/dns-reverso.md`).