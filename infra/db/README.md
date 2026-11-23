# Banco de dados

Scripts, migrações e configurações do PostgreSQL para a plataforma Extensopedia.

## Configuração do PostgreSQL

O PostgreSQL é executado via Docker Compose a partir do arquivo [`../docker-compose.yml`](../docker-compose.yml) com as seguintes características:

- **Imagem:** `postgres:16-alpine` (versão fixada).
- **Porta:** `127.0.0.1:5432` (exposta apenas em localhost).
- **Criptografia de senhas:** `scram-sha-256` (NF010, NF011).
- **Papéis e privilégio mínimo:** Inicializados pelo script [`init/01-init-roles.sh`](init/01-init-roles.sh).
- **Volume nomeado:** `extensopedia_postgres_data` montado em `/var/lib/postgresql/data`.
- **Healthcheck:** Avaliado via comando `pg_isready`.
- **Rede:** `extensopedia-network`.
- **Bancos:** `extensopedia` para desenvolvimento e `extensopedia_test` para testes.
- **Encoding:** UTF-8.
- **Timezone:** UTC no PostgreSQL; o fuso horario exibido pela aplicacao deve ser `America/Fortaleza`.
- **Collation:** colacao brasileira `pt_BR` baseada em ICU, alem do locale UTF-8 do cluster.
- **Extensoes:** `citext`, `unaccent`, `pg_trgm` e `pgcrypto`.

## Papéis do Banco

- **Admin (`POSTGRES_USER`):** Gerenciamento do container.
- **Migrations (`DB_MIGRATION_USER`):** Dono do banco e do schema `public`, com permissão DDL para criar/alterar tabelas.
- **Aplicação (`DB_APP_USER`):** Permissões estritamente DML (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) e `USAGE` em sequences. Bloqueado para DDL.

## Validacao dos bancos

Após recriar o volume, conecte-se ao banco principal ou de testes e execute:

```sql
SELECT extname
FROM pg_extension
WHERE extname IN ('citext', 'unaccent', 'pg_trgm', 'pgcrypto')
ORDER BY extname;

SELECT unaccent('Ação') AS sem_acento;

SELECT 'Extensopedia'::citext = 'extensopedia'::citext AS sem_diferenca_de_caixa;
```

## Comandos rápidos

Na raiz do repositório:

- **Gerar senhas seguras:** `make generate-secrets`
- **Subir:** `make db-up` (ou `docker compose -f infra/docker-compose.yml up -d`)
- **Verificar integridade:** `make db-status` (ou `docker compose -f infra/docker-compose.yml ps`)
- **Logs:** `make db-logs` (ou `docker compose -f infra/docker-compose.yml logs -f postgres`)
- **Parar:** `make db-down` (ou `docker compose -f infra/docker-compose.yml down`)
- **Resetar (apagar dados e recriar):** `make db-reset` (ou `docker compose -f infra/docker-compose.yml down -v && docker compose -f infra/docker-compose.yml up -d`)

Para mais detalhes, variáveis de ambiente e validação de privilégios, consulte a documentação de [infraestrutura](../README.md).
