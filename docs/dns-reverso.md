# DNS Reverso (IP → Nome)

Descrição

Zonas reversas permitem resolver endereços IP para nomes (PTR). São importantes para logs, autenticação de e-mail e alguns serviços que exigem resolução reversa válida.

Nome da zona reversa

Para a rede `192.168.1.0/24`, a zona reversa é `1.168.192.in-addr.arpa`.

Exemplo de entrada em `/etc/bind/named.conf.local`:

```text
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.1";
};
```

Exemplo de arquivo de zona reversa `/etc/bind/db.192.168.1`:

```text
$TTL 604800
@   IN  SOA dns.empresa.local. admin.empresa.local. (
        2026062101 ; serial
        604800
        86400
        2419200
        604800 )

@       IN  NS      dns.empresa.local.
10      IN  PTR     dns.empresa.local.
20      IN  PTR     srv01.empresa.local.
30      IN  PTR     web.empresa.local.
```

Testes

- Resolver o PTR:

```bash
dig -x 192.168.1.10 @192.168.1.10 +short
```

Observações

- Para blocos maiores (ex.: /16) use `in-addr.arpa` correspondente ou delegação via RFC2317.
- Em ambientes IPv6 a zona reversa usa `ip6.arpa` e delegação nibble-wise.
- Muitos provedores de Internet controlam a zona reversa pública de IPs públicos; para IPs públicos você pode solicitar ao provedor a delegação ou apontar o PTR via painel do provedor.

Boas práticas

- Mantenha entradas PTR consistentes com registros A (reverse mappings devem apontar para nomes que resolvem para o mesmo IP).
- Atualize o serial quando alterar PTRs.