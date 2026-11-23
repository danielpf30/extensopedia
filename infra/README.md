# Infraestrutura

Configurações de execução local e publicação dos serviços da plataforma Extensopedia.

## Orquestração Local com Docker Compose

O ambiente de desenvolvimento local utiliza o Docker Compose para provisionar os serviços necessários de maneira padronizada e isolada.

### Serviços disponíveis

- **PostgreSQL (`postgres:16-alpine`)**:
  - Imagem em versão fixada (`postgres:16-alpine`).
  - Porta mapeada exclusivamente em loopback (`127.0.0.1:5432:5432`).
  - Autenticação e hash de senhas configurados com `scram-sha-256` (NF010, NF011).
  - Inicialização automática de papéis com privilégio mínimo (`infra/db/init/01-init-roles.sh`).
  - Persistência com volume nomeado (`extensopedia_postgres_data`).
  - Rede dedicada bridge (`extensopedia-network`).
  - Política de reinicialização (`restart: unless-stopped`).
  - Verificação de integridade (*healthcheck*) utilizando `pg_isready`.

## Variáveis de Ambiente e Segredos

O repositório não armazena nenhuma credencial ou segredo em texto plano (NF010, NF011). O arquivo `infra/.env` é estritamente ignorado pelo `.gitignore`.

### 1. Gerando senhas seguras automaticamente

Para inicializar seu ambiente com senhas fortes de alta entropia geradas criptograficamente:

```bash
# Via Makefile na raiz:
make generate-secrets

# Ou diretamente via script Python:
python scripts/generate-passwords.py --env-file infra/.env
```

O comando copia a estrutura de `infra/.env.example` para `infra/.env` e substitui os marcadores por senhas seguras (32 caracteres).

### 2. Tabela de variáveis

| Variável | Papel / Função | Privilégios | Descrição |
|---|---|---|---|
| `POSTGRES_PORT` | Rede | — | Porta no host (`127.0.0.1`) |
| `POSTGRES_DB` | Banco | — | Nome do banco de dados |
| `POSTGRES_USER` | Admin / Superuser | `SUPERUSER` | Conta administrativa do container |
| `POSTGRES_PASSWORD` | Admin / Superuser | — | Senha administrativa |
| `DB_MIGRATION_USER` | Dono / Migrations | DDL + DML | Dono do banco e schema `public` |
| `DB_MIGRATION_PASSWORD` | Dono / Migrations | — | Senha para ferramentas de migração |
| `DB_APP_USER` | Aplicação | DML apenas | Acesso do backend em runtime |
| `DB_APP_PASSWORD` | Aplicação | — | Senha para conexão da aplicação |

## Papéis do Banco de Dados e Princípio do Menor Privilégio

O PostgreSQL é inicializado com separação clara de responsabilidades:

1. **Dono / Migrations (`extensopedia_owner`)**:
   - Proprietário do banco de dados e do schema `public`.
   - Permissão exclusiva para executar DDL (`CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`, `CREATE INDEX`).
   - Usado exclusivamente por ferramentas de migração de schema (Flyway, Liquibase, Prisma, etc.).

2. **Aplicação (`extensopedia_app`)**:
   - Usuário restrito utilizado pelo backend em tempo de execução.
   - Permissão apenas para DML (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) e `USAGE` em sequences.
   - Bloqueado contra criação, alteração ou exclusão de tabelas e objetos de schema (`REVOKE CREATE ON SCHEMA public FROM PUBLIC`).

## Comandos do Banco de Dados

Os comandos a seguir podem ser executados a partir da raiz do projeto (com `-f infra/docker-compose.yml` ou `make`) ou entrando na pasta `infra/`:

### 1. Subir o banco de dados

Para iniciar o container do PostgreSQL em segundo plano:

```bash
docker compose -f infra/docker-compose.yml up -d
# ou:
make db-up
```

### 2. Verificar status e integridade (*healthcheck*)

Para verificar se o container está em execução e saudável (*healthy*):

```bash
docker compose -f infra/docker-compose.yml ps
# ou:
make db-status
```

### 3. Visualizar logs

Para acompanhar os logs do serviço em tempo real:

```bash
docker compose -f infra/docker-compose.yml logs -f postgres
# ou:
make db-logs
```

### 4. Conectar ao PostgreSQL via terminal (CLI)

Para testar como usuário administrador:

```bash
docker compose -f infra/docker-compose.yml exec postgres psql -U extensopedia_admin -d extensopedia
```

Para testar como usuário de migrations:

```bash
docker compose -f infra/docker-compose.yml exec postgres psql -U extensopedia_owner -d extensopedia
```

Para testar como usuário da aplicação (validando menor privilégio):

```bash
docker compose -f infra/docker-compose.yml exec postgres psql -U extensopedia_app -d extensopedia
```

### 5. Validar o princípio do menor privilégio

Conecte-se com o usuário de aplicação e tente criar uma tabela:

```sql
CREATE TABLE teste (id INT);
-- Retorno esperado: ERROR: permission denied for schema public
```

Conecte-se com o usuário de migrations e crie a tabela:

```sql
CREATE TABLE teste (id SERIAL PRIMARY KEY, nome TEXT);
-- Criação bem-sucedida.
```

Conecte-se novamente com o usuário de aplicação e teste o acesso DML:

```sql
INSERT INTO teste (nome) VALUES ('exemplo');
SELECT * FROM teste;
-- Inserção e consulta bem-sucedidas.

ALTER TABLE teste ADD COLUMN descricao TEXT;
-- Retorno esperado: ERROR: must be owner of table teste
```

### 6. Parar o banco de dados

Para pausar/parar a execução mantendo os containers e os dados preservados:

```bash
docker compose -f infra/docker-compose.yml down
# ou:
make db-down
```

### 7. Resetar o banco de dados

Para remover todos os containers e apagar o volume persistido (limpeza completa para recriação do zero com novo init):

```bash
docker compose -f infra/docker-compose.yml down -v && docker compose -f infra/docker-compose.yml up -d
# ou:
make db-reset
```

> **Atenção:** O comando `down -v` apagará permanentemente todos os registros salvos no volume local do PostgreSQL.
