#!/usr/bin/env bash
# Carrega variáveis de ambiente a partir de .env no diretório atual
set -e

ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Arquivo $ENV_FILE não encontrado. Copie .env.example para .env e preencha os valores." >&2
  exit 1
fi

export $(grep -v '^#' .env | xargs)

echo "Variáveis de ambiente carregadas a partir de .env"
echo "PM_API_URL=$PM_API_URL"
echo "TARGET_NODE=$TARGET_NODE"
