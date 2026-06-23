# IaC AWS - dns1 (Passo a passo)

Este diretório contém a configuração Terraform para criar a VM `dns1` na AWS usando `modules/aws_dns_vm` e o `user_data` (cloud-init) existente.

Resumo rápido
- Módulo: `modules/aws_dns_vm`
- Root module: `iac/aws/dns1`
- Cloud-init usado: `iac/aws/dns1/provision-cloudinit.yml`

## 0) Arquitetura - Princípios de Código Limpo

Esta configuração segue os princípios de **Clean Code** para Infrastructure as Code:

### Organização dos Arquivos

| Arquivo | Responsabilidade | Princípio |
|---------|-----------------|-----------|
| **locals.tf** | Valores computados e reutilizáveis | DRY (Don't Repeat Yourself) |
| **variables.tf** | Definição de inputs com validação | Single Responsibility Principle |
| **main.tf** | Instantiação do módulo | Separation of Concerns |
| **outputs.tf** | Exportação de valores | Expose Only Necessary |
| **provider.tf** | Configuração do provider AWS | |
| **backend.tf** | Configuração de estado remoto | |

### Variáveis Organizadas por Domínio

As variáveis estão agrupadas logicamente por funcionalidade:

- **AWS Configuration**: `aws_region`, `environment_tag`
- **Instance Configuration**: `instance_name`, `compute`, `key_pair_name`, `ami_map`, `ami_default`
- **Networking Configuration**: `networking` (vpc_id, subnet_id, private_ip, assign_eip)
- **Security Configuration**: `security_config` (allowed_ssh_cidrs, dns_allowed_cidrs)
- **DNS Configuration**: `dns_ip`, `srv_ip`, `web_ip`

### Benefícios da Refatoração

✅ **DRY**: Valores computados em `locals.tf` (ex: DNS IP fallback)  
✅ **Validação**: Regras de validação em todas as variáveis  
✅ **Documentação**: Descrições claras e autodocumentadas  
✅ **Manutenibilidade**: Código organizado e fácil de estender  
✅ **Testabilidade**: Valores centralizados facilitam testes  

---

## 1) Pré-requisitos

- Ter `terraform` e `aws` CLI instalados (ver seção abaixo).
- Ter credenciais AWS configuradas (perfil ou variáveis de ambiente).
- Chave privada PEM (ex: `certificados/certificado-movel.pem`) se você quiser usar SSH com key-pair próprio.

## 2) Instalar ferramentas (macOS)

```bash
# Homebrew (se necessário)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)" # ajustar conforme arquitetura

brew update
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install awscli

terraform -version
aws --version
```

## 3) Preparar certificado / key-pair (opcional)

Se já colocou a PEM em `certificados/` (por exemplo `certificado-movel.pem`):

```bash
cd iac/aws/dns1
./import_key.sh          # gera certificados/certificado-movel.pub e mostra comando aws
./import_key.sh --import # importa o key-pair para a conta AWS (requer aws cli configurado)
```

Após importar, defina o nome do key-pair em `TF_VAR_key_pair_name` (ou copie/edite `exemple.env`).

## 4) Configurar backend do Terraform

Edite `backend.tf` e substitua `REPLACE_WITH_BUCKET` e `REPLACE_WITH_DYNAMODB_TABLE` pelos valores reais, ou inicialize o Terraform passando `-backend-config`:

```bash
cd iac/aws/dns1
terraform init -backend-config="bucket=${BUCKET}" \
               -backend-config="key=project-redes/dns1/terraform.tfstate" \
               -backend-config="region=us-east-1" \
               -backend-config="dynamodb_table=terraform-locks" \
               -reconfigure
```

Se preferir estado local, remova/ignore `backend.tf` ou deixe o backend sem configuração.

## 5) Carregar variáveis de ambiente

Copie `exemple.env` para `.env` ou exporte as variáveis necessárias:

```bash
source ./set-env.sh
export TF_VAR_key_pair_name=dns1
export TF_VAR_aws_region=us-east-1
```

### 5.1) Obter `vpc_id` e `subnet_id` (necessário)

O módulo espera que você forneça `TF_VAR_vpc_id` e `TF_VAR_subnet_id` através da variável `networking`. Exemplos de comandos para obter esses IDs usando AWS CLI:

```bash
# VPC default
export VPC_ID=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)

# Subnet (pega a primeira subnet da VPC)
export SUBNET_ID=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=${VPC_ID} --query 'Subnets[0].SubnetId' --output text)

# Verificar
echo "VPC_ID=${VPC_ID} SUBNET_ID=${SUBNET_ID}"

# Exportar como variável Terraform agrupada
export TF_VAR_networking="{vpc_id=\"${VPC_ID}\",subnet_id=\"${SUBNET_ID}\",private_ip=\"10.0.1.10\",assign_eip=true}"
```

Se você preferir usar uma VPC/subnet específicas, substitua os comandos acima pelos IDs desejados e exporte as variáveis manualmente.

### 5.2) Exemplos de Uso com Variáveis Customizadas

#### Exemplo 1: Usar instância t3.small com 16GB

```bash
export TF_VAR_compute='{"instance_type":"t3.small","volume_size":16}'
terraform plan
```

#### Exemplo 2: Networking customizado com EIP

```bash
export TF_VAR_networking='{
  "vpc_id":"vpc-12345678",
  "subnet_id":"subnet-87654321",
  "private_ip":"10.0.1.10",
  "assign_eip":true
}'
terraform plan
```

#### Exemplo 3: Restringir SSH a uma rede específica

```bash
export TF_VAR_security_config='{
  "allowed_ssh_cidrs":["10.0.0.0/8","203.0.113.0/24"],
  "dns_allowed_cidrs":["10.0.0.0/8"]
}'
terraform plan
```

#### Exemplo 4: Usar ambiente de desenvolvimento

```bash
export TF_VAR_environment_tag=dev
export TF_VAR_instance_name=dns-dev
terraform plan
```

#### Exemplo 5: Configurar IPs específicos para registros DNS

```bash
# Se quiser usar IPs diferentes para DNS, SRV e WEB
export TF_VAR_dns_ip="10.0.1.100"
export TF_VAR_srv_ip="10.0.1.101"
export TF_VAR_web_ip="10.0.1.102"
terraform plan
```

### 5.3) Parametrizar `provision-cloudinit.yml` (IPs na zona DNS)

O `provision-cloudinit.yml` foi convertido em template e aceita três variáveis:

- `TF_VAR_dns_ip` — IP a ser usado para o registro `dns.empresa.local` (padrão: `private_ip`).
- `TF_VAR_srv_ip` — IP para `srv01` (padrão: `private_ip`).
- `TF_VAR_web_ip` — IP para `web` (padrão: `private_ip`).

Exemplo (usar o private_ip como padrão):

```bash
export TF_VAR_instance_name=dns1
export TF_VAR_environment_tag=prod
export TF_VAR_key_pair_name=dns1
export TF_VAR_networking='{
  "vpc_id":"vpc-xxxxx",
  "subnet_id":"subnet-yyyyy",
  "private_ip":"10.0.1.10",
  "assign_eip":false
}'

# opcionalmente sobrescrever registros DNS
export TF_VAR_dns_ip=10.0.1.10
export TF_VAR_srv_ip=10.0.1.20
export TF_VAR_web_ip=10.0.1.30

terraform plan -out=tfplan
terraform apply tfplan
```

Se não exportar `TF_VAR_dns_ip`, `TF_VAR_srv_ip` ou `TF_VAR_web_ip`, o sistema usará `networking.private_ip` para todos.

---

## 6) Inicializar, planejar e aplicar

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Se você alterou backend, use `terraform init -reconfigure` na primeira execução.

## 7) Verificar outputs e acesso

Após `apply`, verifique os outputs disponíveis:

```bash
# Novo padrão (recomendado)
terraform output private_ip
terraform output public_ip
terraform output ssh_command
terraform output dns_server_config

# Legacy outputs (deprecated, mantidos para compatibilidade)
terraform output dns1_private_ip
terraform output dns1_public_ip
```

Testar DNS (se o DNS foi configurado publicamente):

```bash
dig @$(terraform output -raw public_ip) empresa.local
```

Testar SSH (usar o PEM que você tem localmente):

```bash
ssh -i ../../certificados/certificado-movel.pem ubuntu@$(terraform output -raw public_ip)
```

Ou usar o comando ssh pronto:

```bash
eval $(terraform output -raw ssh_command)
```

## 8) Validação de Entradas

Todas as variáveis incluem validação. Se você tentar usar valores inválidos, o Terraform irá rejeitar antes de fazer qualquer mudança na infraestrutura:

```bash
# ❌ Isso irá falhar (instance_name com uppercase)
export TF_VAR_instance_name=DNS1
terraform plan  # Error: Invalid value for variable

# ❌ Isso irá falhar (CIDR inválido)
export TF_VAR_security_config='{"allowed_ssh_cidrs":["invalid"],...}'
terraform plan  # Error: All CIDRs must be valid

# ✅ Isso funcionará
export TF_VAR_instance_name=dns1
terraform plan
```

## 9) Limpeza

```bash
terraform destroy
```

## 10) Notas de segurança

- Nunca comite `certificados/*.pem` ou `*.tfstate` no repositório.
- Restrinja `security_config.allowed_ssh_cidrs` para seu IP em produção.
- Em vez de colocar credenciais em arquivos, prefira `aws-vault`, `~/.aws/credentials` ou Secrets Manager.

## 11) Problemas comuns e soluções rápidas

- Erro TLS com CA custom: exporte `AWS_CA_BUNDLE="$PWD/../../certificados/ca-bundle.pem"`.
- Erro `permission denied` ao usar PEM: `chmod 600 certificados/certificado-movel.pem`.
- Falha no backend S3: verifique permissões do bucket e da tabela DynamoDB.
- Erro de validação de variáveis: revise as mensagens de erro do Terraform - elas indicam o formato esperado.

---

## Referência Rápida de Variáveis

### Variáveis Necessárias

```hcl
TF_VAR_key_pair_name = "nome-da-chave"
TF_VAR_networking = {
  vpc_id     = "vpc-xxxxx"
  subnet_id  = "subnet-yyyyy"
  private_ip = "10.0.1.10"
  assign_eip = true/false
}
```

### Variáveis Opcionais com Padrões

```hcl
TF_VAR_aws_region        = "us-east-1"  # padrão
TF_VAR_instance_name     = "dns1"       # padrão
TF_VAR_environment_tag   = "prod"       # padrão: dev, staging, prod
TF_VAR_compute = {
  instance_type = "t3.micro"
  volume_size   = 8
}
TF_VAR_security_config = {
  allowed_ssh_cidrs = ["0.0.0.0/0"]
  dns_allowed_cidrs = ["0.0.0.0/0"]
}
TF_VAR_dns_ip = ""  # padrão: usa private_ip
TF_VAR_srv_ip = ""  # padrão: usa private_ip
TF_VAR_web_ip = ""  # padrão: usa private_ip
```

---


