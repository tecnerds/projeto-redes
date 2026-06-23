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

Hooks locais

 - **Descrição:** o repositório inclui hooks Git locais em `.githooks/` para rodar linters e verificações antes de commits e pushes.
 - **Arquivos:** `.githooks/pre-commit` e `.githooks/pre-push`.
 - **Habilitar (uma vez por máquina):**

```bash
chmod +x .githooks/pre-commit .githooks/pre-push
git config core.hooksPath .githooks
```

 - **Dependências (instale localmente):**
   - `shellcheck` — validar scripts shell
   - `markdownlint-cli` (npm) ou `markdownlint` — validar Markdown
   - `yamllint` — validar YAML
   - `terraform` — verificar `terraform fmt` para os módulos

 - **Comportamento:** os hooks são estritos — irão falhar o commit/push se as ferramentas necessárias não estiverem instaladas ou se os linters encontrarem erros.

 - **Sugestão rápida (macOS com Homebrew):**

```bash
brew install shellcheck yamllint terraform
npm install -g markdownlint-cli
```

