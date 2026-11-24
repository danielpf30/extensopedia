# Extensopedia

Plataforma web para conectar demandas de escolas públicas a projetos de
extensão e capacitação de instituições de ensino superior (IES).

## Escopo

O MVP contempla navegação pública, demandas escolares, projetos para escolas,
atendimento por IES, gestão de projetos e administração.

## Estrutura

```text
docs/       Requisitos, decisões, processo e diagramas
infra/      Docker, Nginx e banco de dados
backend/    API e regras de negócio
frontend/   Aplicação web
scripts/    Automação e manutenção
```

## Documentação

- [Índice da documentação](docs/README.md)
- [Requisitos](docs/requisitos/README.md)
- [Glossário e personas](docs/glossario.md)
- [Matriz de rastreabilidade](docs/rastreabilidade.md)
- [Diagramas](docs/diagramas/README.md)
- [Infraestrutura](infra/README.md)

## Como contribuir

Abra uma issue antes de iniciar uma mudança relevante e envie um pull request
com descrição, testes/validações aplicáveis e revisão de documentação.

## Roadmap

O planejamento é acompanhado no [GitHub
Project](https://github.com/users/danielpf30/projects/1). A Sprint 1 organiza
repositório e documentação; as milestones seguintes tratarão da infraestrutura,
backend, frontend, autenticação e implantação.

## Como subir o ambiente

### Configuração de variáveis e segredos

Antes de iniciar os serviços pela primeira vez, gere o arquivo de variáveis de ambiente com senhas fortes criptograficamente:

```bash
make generate-secrets
# ou:
python scripts/generate-passwords.py --env-file infra/.env
```

### Banco de dados (PostgreSQL)

Para iniciar o banco de dados localmente via Docker Compose:

```bash
docker compose -f infra/docker-compose.yml up -d
# ou usando o Makefile:
make db-up
```

Para verificar o status e integridade (*healthcheck*):

```bash
docker compose -f infra/docker-compose.yml ps
# ou:
make db-status
```

Para parar o banco de dados:

```bash
docker compose -f infra/docker-compose.yml down
# ou:
make db-down
```

Para resetar o banco de dados (apagando os volumes persistidos e recriando):

```bash
docker compose -f infra/docker-compose.yml down -v && docker compose -f infra/docker-compose.yml up -d
# ou:
make db-reset
```

Instruções detalhadas e opções de customização estão descritas em [infra/README.md](infra/README.md).
