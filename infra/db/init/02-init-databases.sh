#!/bin/sh
set -e

DB_NAME="${POSTGRES_DB:-extensopedia}"
TEST_DB="${POSTGRES_TEST_DB:-extensopedia_test}"
MIGRATION_USER="${DB_MIGRATION_USER:-extensopedia_owner}"
APP_USER="${DB_APP_USER:-extensopedia_app}"

echo ">> [Extensopedia] Configurando bancos e extensoes..."

if ! psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres \
    --tuples-only --no-align --command \
    "SELECT 1 FROM pg_database WHERE datname = '$TEST_DB'" | grep -q '^1$'; then
    createdb --username "$POSTGRES_USER" --encoding=UTF8 \
        --owner="$MIGRATION_USER" --template=template0 "$TEST_DB"
fi

for database in "$DB_NAME" "$TEST_DB"; do
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$database" <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS citext;
        CREATE EXTENSION IF NOT EXISTS unaccent;
        CREATE EXTENSION IF NOT EXISTS pg_trgm;
        CREATE EXTENSION IF NOT EXISTS pgcrypto;

        CREATE COLLATION IF NOT EXISTS "pt_BR"
            (provider = icu, locale = 'pt-BR');

        ALTER DATABASE "$database" SET timezone TO 'UTC';

        ALTER SCHEMA public OWNER TO "$MIGRATION_USER";
        REVOKE CREATE ON SCHEMA public FROM PUBLIC;
        REVOKE ALL ON DATABASE "$database" FROM PUBLIC;

        GRANT CONNECT, TEMPORARY ON DATABASE "$database" TO "$MIGRATION_USER";
        GRANT ALL PRIVILEGES ON SCHEMA public TO "$MIGRATION_USER";

        GRANT CONNECT ON DATABASE "$database" TO "$APP_USER";
        GRANT USAGE ON SCHEMA public TO "$APP_USER";
        GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "$APP_USER";
        GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "$APP_USER";

        ALTER DEFAULT PRIVILEGES FOR ROLE "$MIGRATION_USER" IN SCHEMA public
            GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "$APP_USER";
        ALTER DEFAULT PRIVILEGES FOR ROLE "$MIGRATION_USER" IN SCHEMA public
            GRANT USAGE, SELECT ON SEQUENCES TO "$APP_USER";
EOSQL
done

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB_NAME" <<-'EOSQL'
    DO $$
    BEGIN
        IF unaccent('Ação') <> 'Acao' THEN
            RAISE EXCEPTION 'A extensao unaccent nao remove os acentos corretamente';
        END IF;
    END
    $$;

    SELECT bool_or(extname = 'citext') AS citext_presente
         , bool_or(extname = 'unaccent') AS unaccent_presente
         , bool_or(extname = 'pg_trgm') AS pg_trgm_presente
         , bool_or(extname = 'pgcrypto') AS pgcrypto_presente
    FROM pg_extension;
EOSQL

echo ">> [Extensopedia] Bancos, extensoes e colacao configurados com sucesso."
