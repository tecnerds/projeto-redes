#!/usr/bin/env bash
set -euo pipefail

# Script helper para derivar a chave pública a partir de um PEM privado
# e mostrar o comando para importar como EC2 key-pair.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CERT_DIR="$REPO_ROOT/certificados"
KEY_BASENAME="certificado-movel"
KEY_FILE="$CERT_DIR/${KEY_BASENAME}.pem"
PUB_FILE="$CERT_DIR/${KEY_BASENAME}.pub"
KEY_NAME="${1:-$KEY_BASENAME}"
DO_IMPORT=false

if [ "${1:-}" = "--import" ]; then
  DO_IMPORT=true
fi

if [ ! -f "$KEY_FILE" ]; then
  echo "Arquivo de chave privada não encontrado: $KEY_FILE"
  exit 1
fi

chmod 600 "$KEY_FILE"

if [ ! -f "$PUB_FILE" ]; then
  echo "Gerando chave pública a partir de $KEY_FILE -> $PUB_FILE"
  ssh-keygen -y -f "$KEY_FILE" > "$PUB_FILE"
  chmod 644 "$PUB_FILE"
fi

echo "Key pair public key: $PUB_FILE"

if [ "$DO_IMPORT" = true ]; then
  echo "Importando para AWS como key-name: $KEY_NAME"
  aws ec2 import-key-pair --key-name "$KEY_NAME" --public-key-material file://"$PUB_FILE"
  echo "Import concluído. Ajuste TF_VAR_key_pair_name se necessário."
else
  echo "Para importar o key-pair na AWS execute (ou copie e cole):"
  echo "  aws ec2 import-key-pair --key-name $KEY_NAME --public-key-material file://$PUB_FILE"
  echo "Para executar automaticamente este script e importar passe --import como primeiro argumento. Ex: ./import_key.sh --import my-key-name"
fi
