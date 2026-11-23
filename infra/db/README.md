# Banco de dados

Scripts, migrações e configurações do PostgreSQL para a plataforma Extensopedia.

## Configuração do PostgreSQL

O PostgreSQL é executado via Docker Compose a partir do arquivo [`../docker-compose.yml`](../docker-compose.yml) com as seguintes características:

- **Imagem:** `postgres:16-alpine` (versão fixada).
- **Porta:** `127.0.0.1:5432` (exposta apenas em localhost).
- **Volume nomeado:** `extensopedia_postgres_data` montado em `/var/lib/postgresql/data`.
- **Healthcheck:** Avaliado via comando `pg_isready`.
- **Rede:** `extensopedia-network`.

## Comandos rápidos

Na raiz do repositório:

- **Subir:** `docker compose -f infra/docker-compose.yml up -d`
- **Verificar integridade:** `docker compose -f infra/docker-compose.yml ps`
- **Logs:** `docker compose -f infra/docker-compose.yml logs -f postgres`
- **Parar:** `docker compose -f infra/docker-compose.yml down`
- **Resetar (apagar dados e recriar):** `docker compose -f infra/docker-compose.yml down -v && docker compose -f infra/docker-compose.yml up -d`

Para mais detalhes e variáveis de ambiente, consulte a documentação de [infraestrutura](../README.md).
