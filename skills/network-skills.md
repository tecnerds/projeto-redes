Habilidades e checklist do Agente Especialista em Redes

Conhecimentos principais:
- DNS (recursão, autoridade, registros A/AAAA/CNAME/SOA, delegação).
- Roteamento básico (static routes, default gateway, `ip route`).
- Ferramentas de diagnóstico (`ping`, `traceroute`, `dig`, `nslookup`, `tcpdump`).
- Análise de logs e resolução de problemas em interfaces de rede.

Checklist de diagnóstico padrão:
1. Ler documentação local (`dns-server.md`, `VMs/*.md`).
2. Verificar conectividade ICMP (`ping`).
3. Verificar resolução DNS local (`dig`/`nslookup`).
4. Traçar rota (`traceroute`).
5. Capturar tráfego relevante (`tcpdump`) se necessário.
6. Revisar configurações de serviço (bind/ named / systemd-resolved) e arquivos de zona.
7. Propor mudanças, testes e rollback.

Exemplos de comandos seguros para inspeção (sem alterações):
- `ip addr show`
- `ip route show`
- `systemctl status named` (ou `systemctl status bind9`)
- `dig +short @127.0.0.1 example.com`

Procedimentos de alteração (usar com cautela):
- Editar arquivos de zona e recarregar serviço: `sudo systemctl reload named`.
- Reiniciar resolução: `sudo systemctl restart systemd-resolved`.

Notas de segurança:
- Sempre instruir o usuário a executar comandos com `sudo` no próprio ambiente quando for necessário privilégio.
- Não automatizar execuções remotas sem consentimento e credenciais explícitas.