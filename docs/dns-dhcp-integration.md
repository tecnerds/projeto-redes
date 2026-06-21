# Integração DNS + DHCP

Objetivo

Integrar o servidor DHCP (ISC DHCP) com o servidor DNS (BIND) para atualizações dinâmicas (DDNS): quando uma máquina recebe um lease, o DHCP atualiza o registro DNS (A/PTR).

Configuração básica (dhcpd + BIND)

1. Habilite `ddns-update-style` em `/etc/dhcp/dhcpd.conf` e declare a zona e a chave TSIG:

```text
ddns-update-style interim;

key "dhcp-ddns-key" {
    algorithm hmac-sha256;
    secret "INSIRA_BASE64_DO_TSIG_AQUI";
}

zone "empresa.local" {
    primary 192.168.1.10;
    key dhcp-ddns-key;
}

zone "1.168.192.in-addr.arpa" {
    primary 192.168.1.10;
    key dhcp-ddns-key;
}
```

2. No BIND, declare a `key` correspondente e permita updates da chave:

```text
key "dhcp-ddns-key" {
    algorithm hmac-sha256;
    secret "MESMO_SECRET_DO_DHCP";
};

zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
    allow-update { key dhcp-ddns-key; };
};
```

Gerar e proteger a chave

- Gere uma chave segura e proteja o arquivo que a contém. Distribua a chave apenas entre o DHCP e o BIND.

Testes

- Teste manual usando `nsupdate` com a chave para aplicar um registro e verificar em seguida com `dig`.

```bash
nsupdate -k /path/to/keyfile
> server 192.168.1.10
> zone empresa.local
> update add teste 3600 A 192.168.1.99
> send
```

- Verifique PTR:

```bash
dig @192.168.1.10 teste.empresa.local +short
```

Boas práticas e segurança

- Proteja a chave TSIG e registre-a em arquivos com permissões restritas.
- Configure `allow-update` estritamente para a chave do DHCP.
- Habilite logs para os componentes DHCP/DNS para auditoria.

Observações

- Em redes gerenciadas por NetworkManager/Cloud-init, o cliente também pode tentar atualizar DNS; defina políticas claras para evitar conflitos.
- Considere `update-static-leases on;` se quiser que leases estáticos também gerem DDNS consistently.