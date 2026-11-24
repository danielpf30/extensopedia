.PHONY: help docs-lint docs-links generate-secrets db-up db-down db-status db-logs db-reset

help:
	@echo "Alvos disponíveis:"
	@echo "  make docs-lint         Valida Markdown localmente (requer markdownlint-cli2)"
	@echo "  make docs-links        Verifica links locais da documentação"
	@echo "  make generate-secrets  Gera senhas seguras e cria o arquivo infra/.env"
	@echo "  make db-up             Inicia o serviço do PostgreSQL com Docker Compose"
	@echo "  make db-down           Para os serviços do Docker Compose"
	@echo "  make db-status         Exibe o status e healthcheck do banco de dados"
	@echo "  make db-logs           Exibe os logs do PostgreSQL em tempo real"
	@echo "  make db-reset          Remove o volume persistido e recria o banco do zero"

docs-lint:
	markdownlint-cli2 "**/*.md"

docs-links:
	@echo "A verificação de links é executada pelo workflow de documentação."

generate-secrets:
	python scripts/generate-passwords.py --env-file infra/.env

db-up:
	docker compose -f infra/docker-compose.yml up -d

db-down:
	docker compose -f infra/docker-compose.yml down

db-status:
	docker compose -f infra/docker-compose.yml ps

db-logs:
	docker compose -f infra/docker-compose.yml logs -f postgres

db-reset:
	docker compose -f infra/docker-compose.yml down -v
	docker compose -f infra/docker-compose.yml up -d

include infra/db/migrations.mk
