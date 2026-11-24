#!/bin/sh
set -e

# ==============================================================================
# Script de Inicialização de Papéis e Permissões do PostgreSQL
# Executado automaticamente pelo docker-entrypoint na criação do volume.
# ==============================================================================

DB_NAME="${POSTGRES_DB:-extensopedia}"
MIGRATION_USER="${DB_MIGRATION_USER:-extensopedia_owner}"
MIGRATION_PASS="${DB_MIGRATION_PASSWORD:-extensopedia_owner_pass}"
APP_USER="${DB_APP_USER:-extensopedia_app}"
APP_PASS="${DB_APP_PASSWORD:-extensopedia_app_pass}"

echo ">> [Extensopedia] Configurando papéis e privilégios no banco '${DB_NAME}'..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 1. Garante que qualquer senha criada utilize criptografia scram-sha-256
    SET password_encryption = 'scram-sha-256';

    -- 2. Criação do papel de Dono / Migrations (DDL + DML)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${MIGRATION_USER}') THEN
            CREATE ROLE "${MIGRATION_USER}" WITH LOGIN PASSWORD '${MIGRATION_PASS}';
            RAISE NOTICE 'Papel % criado com sucesso.', '${MIGRATION_USER}';
        ELSE
            ALTER ROLE "${MIGRATION_USER}" WITH LOGIN PASSWORD '${MIGRATION_PASS}';
            RAISE NOTICE 'Papel % já existe, senha atualizada.', '${MIGRATION_USER}';
        END IF;
    END
    \$\$;

    -- 3. Criação do papel de Aplicação (Somente DML - Menor Privilégio)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${APP_USER}') THEN
            CREATE ROLE "${APP_USER}" WITH LOGIN PASSWORD '${APP_PASS}';
            RAISE NOTICE 'Papel % criado com sucesso.', '${APP_USER}';
        ELSE
            ALTER ROLE "${APP_USER}" WITH LOGIN PASSWORD '${APP_PASS}';
            RAISE NOTICE 'Papel % já existe, senha atualizada.', '${APP_USER}';
        END IF;
    END
    \$\$;

    -- 4. Transfere a propriedade do banco e do schema public para o usuário de migrations
    ALTER DATABASE "${DB_NAME}" OWNER TO "${MIGRATION_USER}";
    ALTER SCHEMA public OWNER TO "${MIGRATION_USER}";

    -- 5. Revoga privilégios públicos no schema public (Princípio do menor privilégio)
    REVOKE CREATE ON SCHEMA public FROM PUBLIC;
    REVOKE ALL ON DATABASE "${DB_NAME}" FROM PUBLIC;

    -- 6. Concede privilégios ao usuário de migrations (DDL total e criação de objetos)
    GRANT CONNECT, TEMPORARY ON DATABASE "${DB_NAME}" TO "${MIGRATION_USER}";
    GRANT ALL PRIVILEGES ON SCHEMA public TO "${MIGRATION_USER}";

    -- 7. Concede privilégios ao usuário de aplicação (apenas DML, sem permissão de DDL)
    GRANT CONNECT ON DATABASE "${DB_NAME}" TO "${APP_USER}";
    GRANT USAGE ON SCHEMA public TO "${APP_USER}";

    -- Concede permissões DML para quaisquer tabelas e sequências já existentes
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "${APP_USER}";
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "${APP_USER}";

    -- 8. Configura privilégios padrão para novos objetos criados pelo migration user
    ALTER DEFAULT PRIVILEGES FOR ROLE "${MIGRATION_USER}" IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${APP_USER}";

    ALTER DEFAULT PRIVILEGES FOR ROLE "${MIGRATION_USER}" IN SCHEMA public
        GRANT USAGE, SELECT ON SEQUENCES TO "${APP_USER}";

    -- Configura privilégios padrão caso o superuser inicial crie objetos
    ALTER DEFAULT PRIVILEGES FOR ROLE "${POSTGRES_USER}" IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${APP_USER}";

    ALTER DEFAULT PRIVILEGES FOR ROLE "${POSTGRES_USER}" IN SCHEMA public
        GRANT USAGE, SELECT ON SEQUENCES TO "${APP_USER}";
EOSQL

echo ">> [Extensopedia] Papéis e privilégios configurados com sucesso."
