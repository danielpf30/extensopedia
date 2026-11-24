# Convenções de migrations

O schema do banco é versionado como código. Toda mudança passa por uma
migration revisada em pull request. Decisão registrada na
[ADR 001](../adr/001-stack.md).

## Ferramenta

- **Flyway** (imagem oficial `flyway/flyway`), executado em Docker pelo
  Makefile. Não é preciso instalar o Flyway nem o Java para rodar.
- O Flyway conecta com o usuário **dono** do banco (`DB_MIGRATION_USER`).
  Nunca use o administrador (`POSTGRES_USER`) nem o usuário da aplicação
  (`DB_APP_USER`, só DML).
- As credenciais vêm de `infra/.env` (veja `infra/.env.example`).

## Onde ficam os arquivos

| Pasta | Conteúdo |
|---|---|
| `infra/db/migrations/` | Migrations `V<NNN>__descricao.sql` |
| `infra/db/down/` | Scripts de rollback `D<NNN>__descricao.sql` |
| `infra/db/migrate-down.sh` | Executa o rollback da última migration |
| `infra/db/migrations.mk` | Alvos do Makefile |

As migrations ficam fora de `backend/` porque o projeto Spring ainda não
existe. Quando existir, o Flyway do Spring pode apontar para essa pasta
(`spring.flyway.locations=filesystem:../infra/db/migrations`).

## Nomes

- Migration: `V<NNN>__<descricao_em_snake_case>.sql`, com três dígitos e
  dois sublinhados. Exemplo: `V002__dominio_localidades_usuarios.sql`.
- Rollback: `D<NNN>__<descricao_em_snake_case>.sql`, com o **mesmo número**
  da migration. Exemplo: `D002__dominio_localidades_usuarios.sql`.
- Use só números inteiros como versão (001, 002, 003...). Não use versões
  como `1.1`, porque o rollback depende do número inteiro.
- Descrição em português, sem acento, dizendo o que a migration faz.

## Ordem

- A numeração é sequencial e global: cada migration nova usa o próximo
  número livre.
- **Nunca edite uma migration que já foi mesclada.** Para corrigir algo,
  crie uma migration nova.
- Se duas branches usarem o mesmo número, quem mesclar depois renumera os
  seus arquivos (a migration e o rollback) antes do merge.
- Uma migration por assunto, seguindo as issues da Sprint 2:

| Migration | Conteúdo | Issue |
|---|---|---|
| V001 | Baseline vazia | #20 |
| V002 | Domínio, localidades e usuários | #21 |
| V003 | Escolas, demandas e anexos | #22 |
| V004 | Projetos, cronograma, orçamento e candidaturas | #23 |
| V005 | Interação, feedback, notificações, configurações e auditoria | #24 |

Os números acima são uma sugestão e podem mudar se a equipe dividir o
trabalho de outra forma.

## Conteúdo das migrations

- SQL puro, um assunto por arquivo, com comentário no topo explicando o
  objetivo.
- Constraints, índices e chaves estrangeiras com nomes explícitos, por
  exemplo `chk_escolas_inep` e `fk_demandas_escola`.
- Dados de teste e de domínio ficam nas issues de seeds (#25), não nas
  migrations de estrutura.
- O Flyway roda cada arquivo em uma transação. Evite comandos que não
  podem rodar dentro de transação (como `CREATE INDEX CONCURRENTLY`).

## Rollback

O Flyway Community não tem `undo` automático. Por isso:

- **Toda migration tem um script `down` correspondente**, escrito à mão e
  revisado junto com ela.
- `make migrate-down` reverte **somente a última** migration aplicada: roda
  o script `D<NNN>` e remove a linha correspondente de
  `flyway_schema_history`, na mesma transação.
- `make reset-db` reverte todas as migrations, na ordem inversa, e aplica
  tudo de novo. Não usa `flyway clean`, para não apagar extensões e papéis
  criados pela inicialização do cluster.
- O rollback desfaz a **estrutura**, não recupera dados apagados por um
  `DROP`. Use apenas em ambiente local.
- Em ambiente compartilhado, uma migration já aplicada não é revertida:
  cria-se uma migration nova que corrige o problema.

## Como usar

Com o Postgres do Docker Compose rodando e `infra/.env` criado:

| Comando | O que faz |
|---|---|
| `make migrate` | Aplica as migrations pendentes |
| `make migrate-info` | Mostra o que foi aplicado e o que falta |
| `make migrate-down` | Reverte a última migration |
| `make reset-db` | Reverte tudo e aplica de novo |

O Makefile principal precisa conter a linha
`include infra/db/migrations.mk`.

No Windows, o `make` e o `bash` do **Git Bash** (ou do WSL) são necessários.
O `migrate-down.sh` usa `bash`.

## Checklist de pull request

- [ ] O arquivo `V<NNN>` tem o `D<NNN>` correspondente.
- [ ] `make reset-db` roda do zero sem erro.
- [ ] `make migrate-down` seguido de `make migrate` funciona.
- [ ] Nenhuma migration já mesclada foi editada.
- [ ] A numeração não conflita com outras branches abertas.

## Problemas comuns

- **`permission denied for schema public`:** o usuário dono não tem
  permissão de criar objetos. Confira os scripts de `infra/db/init`.
- **`Postgres não está saudável`:** suba o banco com
  `docker compose -f infra/docker-compose.yml up -d` e aguarde o healthcheck.
- **`Arquivo infra/.env não encontrado`:** rode `make generate-secrets` ou
  copie `infra/.env.example` para `infra/.env`.
