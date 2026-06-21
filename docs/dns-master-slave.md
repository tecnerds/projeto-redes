# DNS Master / Slave (Master-Slave)

Visão geral

Um arranjo master/slave permite redundância: o master é a origem dos arquivos de zona; slaves obtêm cópias via transferência (AXFR/IXFR) e servem consultas autoritativas.

Configuração do Master

Em `/etc/bind/named.conf.local` no master:

```text
zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
    allow-transfer { 192.168.1.11; };   # IP(s) dos slaves
    notify yes;
};
```

(Opcional) Proteja transferências com TSIG:

```text
key "transfer-key" {
    algorithm hmac-sha256;
    secret "INSIRA_BASE64_DO_TSIG_AQUI";
};

zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
    allow-transfer { key transfer-key; };
    also-notify { 192.168.1.11; };
};
```

Configuração do Slave

No slave, defina a zona como `type slave` e aponte para o master:

```text
zone "empresa.local" {
    type slave;
    file "/var/cache/bind/db.empresa.local";
    masters { 192.168.1.10; };   # IP do master
};
```

Testes e verificação

- Forçar uma transferência (no slave):

```bash
sudo rndc reload
# ou testar com dig AXFR
dig @192.168.1.10 empresa.local AXFR
```

- Verificar permissões e logs em `/var/log/syslog`.

Boas práticas

- Use `notify yes` no master e `also-notify` se houver firewalls/NAT.
- Restringir `allow-transfer` apenas aos IPs/keys de slaves.
- Monitore diferenças entre master/slave e automatize alertas para falhas de transferência.
- Certifique-se de que horários (NTP) estejam sincronizados entre servidores.

Observações sobre TSIG

- Gere chaves TSIG com ferramenta adequada e distribua apenas a chave necessária entre master e slave.
- TSIG evita transferências de zona não autorizadas.

Problemas comuns

- Permissões em `/var/cache/bind` impedindo gravação do slave.
- Firewalls bloqueando portas TCP/53 (AXFR usa TCP).
- Serial não incrementado no master (slave não detecta mudança).