# DNS Cache (Resolver em cache)

Descrição

Um servidor DNS cache (resolver recursivo) responde a consultas recursivas, armazenando respostas em cache para acelerar resoluções subsequentes.

Quando usar

- Melhorar latência de resolução para clientes internos.
- Reduzir consultas para resolvers externos.

Configuração básica (BIND9)

Edite `/etc/bind/named.conf.options` e habilite recursão e encaminhadores:

```text
options {
    directory "/var/cache/bind";

    recursion yes;                 // permitir resolução recursiva
    allow-query { any; };          // restringir a sua rede preferencialmente

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    forward only;                  // ou "forward first" conforme estratégia
};
```

Segurança

- Não deixe recursão aberta para a Internet; restrinja `allow-query`/`allow-recursion` à sua faixa de IP (ex.: `192.168.1.0/24`).
- Considere rate-limiting com `rate-limit` nas opções do BIND.

Comandos úteis

- Testar resolução via cache local:

```bash
dig @127.0.0.1 example.com +short
```

- Limpar cache:

```bash
sudo rndc flush
```

- Ver estatísticas de cache (se ativadas) ou logs para entender miss/hit.

Notas operacionais

- Encaminhadores públicos (ex.: Google, Cloudflare) são úteis, mas para ambientes corporativos prefira resolvers internos da sua organização.
- Ajuste TTLs e políticas de forward para equilibrar latência vs. consistência de dados.
- Pode-se combinar resolver recursivo com autoritativo no mesmo servidor, mas avalie carga e segurança.