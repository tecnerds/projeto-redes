# projeto-redes

[![CI](https://github.com/tecnerds/projeto-redes/actions/workflows/ci.yml/badge.svg)](https://github.com/tecnerds/projeto-redes/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Repositório de documentação e exemplos para laboratório de DNS (BIND9) e integração com DHCP.

Conteúdo principal

  - `docs/dns-autoritativo.md`
  - `docs/dns-cache.md`
  - `docs/dns-master-slave.md`
  - `docs/dns-reverso.md`
  - `docs/dns-dhcp-integration.md`

Pré-requisitos


Fluxo rápido (já inicializado localmente)

1. Verifique o estado local:

```bash
git clone https://github.com/tecnerds/projeto-redes.git
```

```bash
cd projeto-redes
git status
```


Licença
Este projeto é licenciado sob a GNU General Public License v3.0.
Veja o texto completo em [LICENSE](LICENSE).

SPDX: GPL-3.0-only

Licença

Aviso sobre IaC Proxmox

Se for usar o IaC Proxmox, carregue variáveis sensíveis localmente seguindo o exemplo em `iac/proxmox/dns1/.env.example` e use `iac/proxmox/dns1/set-env.sh` para exportá-las no shell antes de executar o Terraform. Não versionar o arquivo `.env` com segredos.

