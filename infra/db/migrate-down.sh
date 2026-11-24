#!/usr/bin/env bash
# Reverte a última migration aplicada pelo Flyway (ou todas, com --all).
#
# O Flyway Community não tem "undo", então cada migration V<NNN>__*.sql
# precisa de um script D<NNN>__*.sql em infra/db/down. O script de rollback e
# a remoção da linha em flyway_schema_history rodam na mesma transação.
#
# Uso: bash infra/db/migrate-down.sh [--all]
set -euo pipefail

# Evita que o Git Bash (Windows) converta caminhos dos argumentos do docker.
export MSYS_NO_PATHCONV=1

CONTAINER="${POSTGRES_CONTAINER:-extensopedia-postgres}"
DOWN_DIR="${DOWN_DIR:-$(cd "$(dirname "$0")" && pwd)/down}"

# Executa o psql dentro do container como usuário dono (DB_MIGRATION_USER).
# As variáveis vêm do ambiente do container, definidas pelo docker-compose.
psql_owner() {
  docker exec -i "$CONTAINER" sh -c \
    'PGPASSWORD="$DB_MIGRATION_PASSWORD" psql -X -q -v ON_ERROR_STOP=1 -U "$DB_MIGRATION_USER" -d "$POSTGRES_DB" "$@"' \
    sh "$@"
}

latest_version() {
  local exists
  exists=$(psql_owner -tA -c \
    "SELECT to_regclass('public.flyway_schema_history') IS NOT NULL" </dev/null)
  if [ "$exists" != "t" ]; then
    return 0
  fi
  psql_owner -tA -c \
    "SELECT version FROM flyway_schema_history
      WHERE success AND version IS NOT NULL
      ORDER BY installed_rank DESC LIMIT 1" </dev/null
}

# Retorna 1 quando não há nenhuma migration aplicada.
down_one() {
  local version padded file
  version=$(latest_version)
  if [ -z "$version" ]; then
    echo "Nenhuma migration aplicada."
    return 1
  fi

  padded=$(printf '%03d' "$((10#$version))")
  file=$(ls "$DOWN_DIR"/D"$padded"__*.sql 2>/dev/null | head -n 1 || true)
  if [ -z "$file" ]; then
    echo "Erro: script D${padded}__*.sql não encontrado em $DOWN_DIR" >&2
    exit 1
  fi

  echo "Revertendo V${padded} com $(basename "$file")"
  {
    cat "$file"
    printf "\nDELETE FROM flyway_schema_history WHERE version = '%s';\n" "$version"
  } | psql_owner --single-transaction
  return 0
}

if [ "${1:-}" = "--all" ]; then
  while down_one; do :; done
else
  down_one || true
fi
