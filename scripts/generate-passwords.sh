#!/usr/bin/env sh
# Script de geração de senhas seguras (POSIX sh)
set -e

ENV_FILE="${1:-infra/.env}"
TEMPLATE_FILE="infra/.env.example"

# Se python3 estiver disponível, utiliza o script python especializado
if command -v python3 >/dev/null 2>&1; then
    exec python3 scripts/generate-passwords.py --env-file "$ENV_FILE" --force
elif command -v python >/dev/null 2>&1; then
    exec python scripts/generate-passwords.py --env-file "$ENV_FILE" --force
fi

# Fallback com openssl caso python não esteja disponível
generate_pwd() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32 | tr -dc 'A-Za-z0-9_-' | head -c 32
    else
        LC_ALL=C tr -dc 'A-Za-z0-9_-' </dev/urandom | head -c 32
    fi
}

ADMIN_PASS=$(generate_pwd)
MIGRATION_PASS=$(generate_pwd)
APP_PASS=$(generate_pwd)

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "ERRO: Template $TEMPLATE_FILE não encontrado." >&2
    exit 1
fi

sed -e "s/^POSTGRES_PASSWORD=.*$/POSTGRES_PASSWORD=$ADMIN_PASS/" \
    -e "s/^DB_MIGRATION_PASSWORD=.*$/DB_MIGRATION_PASSWORD=$MIGRATION_PASS/" \
    -e "s/^DB_APP_PASSWORD=.*$/DB_APP_PASSWORD=$APP_PASS/" \
    "$TEMPLATE_FILE" > "$ENV_FILE"

echo "SUCESSO: Arquivo '$ENV_FILE' gerado com senhas seguras."
