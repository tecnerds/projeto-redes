#!/usr/bin/env bash
set -euo pipefail

# Carrega variáveis de ambiente para facilitar execuções locais
export TF_VAR_aws_region="${TF_VAR_aws_region:-us-east-1}"
export TF_VAR_key_pair_name="${TF_VAR_key_pair_name:-your-key-name}"
export TF_VAR_instance_name="${TF_VAR_instance_name:-dns1}"
export TF_VAR_environment_tag="${TF_VAR_environment_tag:-prod}"

echo "Variáveis TF carregadas:"
echo "  TF_VAR_aws_region=${TF_VAR_aws_region}"
echo "  TF_VAR_key_pair_name=${TF_VAR_key_pair_name}"
echo "  TF_VAR_instance_name=${TF_VAR_instance_name}"
echo "  TF_VAR_environment_tag=${TF_VAR_environment_tag}"

echo
echo "Execute: terraform init && terraform plan"

echo
echo "Se você adicionou uma chave PEM em ../../certificados/ (por exemplo certificado-movel.pem), use o helper para gerar a chave pública e importar para AWS:" 
echo "  cd $(pwd) && ./import_key.sh"
echo "Para importar automaticamente na AWS (executará 'aws ec2 import-key-pair'), execute:"
echo "  ./import_key.sh --import my-key-name"

echo
echo "Exemplos de uso com variáveis customizadas:"
echo
echo "1. Usar instância t3.small com 16GB:"
echo '   terraform plan -var="compute={instance_type=\"t3.small\",volume_size=16}"'
echo
echo "2. Configurar networking customizado:"
echo '   terraform plan -var="networking={vpc_id=\"vpc-xxxxx\",subnet_id=\"subnet-xxxxx\",private_ip=\"10.0.1.10\",assign_eip=true}"'
echo
echo "3. Restringir SSH a uma rede específica:"
echo '   terraform plan -var="security_config={allowed_ssh_cidrs=[\"10.0.0.0/8\"],dns_allowed_cidrs=[\"10.0.0.0/8\"]}"'
echo
echo "4. Usar ambiente dev:"
echo '   export TF_VAR_environment_tag=dev && terraform plan'

