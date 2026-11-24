# Migrations do banco com Flyway rodando em Docker (sem instalar nada além
# do Docker). Incluído pelo Makefile principal com:
#
#   include infra/db/migrations.mk
#
# Alvos: migrate, migrate-info, migrate-down, reset-db
#
# O Flyway conecta como DB_MIGRATION_USER (dono do schema, DDL + DML), nunca
# como admin ou como usuário da aplicação. Valores lidos de infra/.env.

DB_MK_DIR      := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DB_ENV_FILE    ?= $(abspath $(DB_MK_DIR)../.env)
MIGRATIONS_DIR ?= $(DB_MK_DIR)migrations
DOWN_DIR       ?= $(DB_MK_DIR)down
FLYWAY_IMAGE   ?= flyway/flyway:11
DB_NETWORK     ?= extensopedia-network
DB_HOST        ?= postgres
DB_CONTAINER   ?= extensopedia-postgres

# Evita que o Git Bash (Windows) converta caminhos dos argumentos do docker.
export MSYS_NO_PATHCONV := 1

# $(call FLYWAY_RUN,<opções e comando do flyway>)
define FLYWAY_RUN
docker run --rm --network $(DB_NETWORK) --env-file "$(DB_ENV_FILE)" \
  -v "$(MIGRATIONS_DIR):/flyway/sql:ro" \
  --entrypoint sh $(FLYWAY_IMAGE) -c \
  'flyway -url="jdbc:postgresql://$(DB_HOST):5432/$$POSTGRES_DB" -user="$$DB_MIGRATION_USER" -password="$$DB_MIGRATION_PASSWORD" -locations=filesystem:/flyway/sql -connectRetries=5 $(1)'
endef

.PHONY: db-check migrate migrate-info migrate-down reset-db

db-check:
	@test -f "$(DB_ENV_FILE)" || (echo "Arquivo $(DB_ENV_FILE) não encontrado. Rode 'make generate-secrets' ou copie infra/.env.example." && exit 1)
	@docker inspect -f '{{.State.Health.Status}}' $(DB_CONTAINER) 2>/dev/null | grep -q healthy || (echo "Postgres não está saudável. Suba com: docker compose -f infra/docker-compose.yml up -d" && exit 1)

# Aplica as migrations pendentes.
migrate: db-check
	@$(call FLYWAY_RUN,migrate)

# Mostra o estado das migrations (aplicadas e pendentes).
migrate-info: db-check
	@$(call FLYWAY_RUN,info)

# Reverte a última migration aplicada (usa infra/db/down/D<NNN>__*.sql).
migrate-down: db-check
	@DOWN_DIR="$(DOWN_DIR)" POSTGRES_CONTAINER="$(DB_CONTAINER)" bash "$(DB_MK_DIR)migrate-down.sh"

# Reverte todas as migrations (na ordem inversa) e aplica tudo de novo.
# Não usa "flyway clean" para não apagar extensões e papéis criados pelo
# script de inicialização do cluster.
reset-db: db-check
	@echo "Revertendo todas as migrations e aplicando de novo..."
	@DOWN_DIR="$(DOWN_DIR)" POSTGRES_CONTAINER="$(DB_CONTAINER)" bash "$(DB_MK_DIR)migrate-down.sh" --all
	@$(call FLYWAY_RUN,migrate)
