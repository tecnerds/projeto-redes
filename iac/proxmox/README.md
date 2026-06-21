IaC para Proxmox — VM `dns1`

Este diretório contém um exemplo Terraform para criar uma VM no Proxmox e provisioná-la via cloud-init para instalar o BIND9.

Pré-requisitos

- Terraform (> 1.0)
- Proxmox com API access token (preferível) ou usuário/password
- Template cloud-init disponível no Proxmox (ex: Debian/Ubuntu cloud image) com nome definido em `variables.tf` como `template`.

Como usar (exemplo rápido)

1. Copie `terraform.tfvars` com valores do seu ambiente, por exemplo:

```hcl
pm_api_url = "https://proxmox.example.com:8006/api2/json"
pm_api_token_id = "terraform@pve!token"
pm_api_token_secret = "REPLACE_ME"
target_node = "pve"
template = "debian-cloud-template"
storage = "local-lvm"
bridge = "vmbr0"
name = "dns1"
ip = "192.168.1.10"
gateway = "192.168.1.1"
```

2. Inicialize e aplique:

```bash
cd iac/proxmox/dns1
terraform init
terraform apply
```

Observações

- O `user_data` usa o arquivo `provision-cloudinit.yml` para instalar `bind9` e adicionar uma zona de exemplo.
- Ajuste `ip`, `network`, `template` e storage conforme seu ambiente Proxmox.
- Dependendo da versão do provider Proxmox, o atributo `user_data` pode não ser suportado; nesse caso use `cicustom`/snippets no storage ou adapte conforme a documentação do provider.

Uso de variáveis de ambiente

Para evitar expor segredos em arquivos de configuração, use o arquivo `.env` no diretório `iac/proxmox/dns1`.

1. Copie o exemplo e preencha os valores:

```bash
cd iac/proxmox/dns1
cp .env.example .env
# edite .env e preencha PM_API_TOKEN_SECRET e demais valores
```

2. Carregue as variáveis no shell antes de rodar o Terraform:

```bash
source set-env.sh
```

3. Em seguida rode o Terraform:

```bash
terraform init
terraform apply
```

Observação: não versionar o arquivo `.env` com segredos — ele já está listado em `.gitignore`.
