# Infraestrutura

Configurações de execução local e publicação dos serviços da plataforma Extensopedia.

## Orquestração Local com Docker Compose

O ambiente de desenvolvimento local utiliza o Docker Compose para provisionar os serviços necessários de maneira padronizada e isolada.

### Serviços disponíveis

- **PostgreSQL (`postgres:16-alpine`)**:
  - Imagem em versão fixada (`postgres:16-alpine`).
  - Porta mapeada exclusivamente em loopback (`127.0.0.1:5432:5432`).
  - Persistência com volume nomeado (`extensopedia_postgres_data`).
  - Rede dedicada bridge (`extensopedia-network`).
  - Política de reinicialização (`restart: unless-stopped`).
  - Verificação de integridade (*healthcheck*) utilizando `pg_isready`.

## Variáveis de Ambiente

As variáveis possuem valores padrão definidos no `docker-compose.yml`. Caso deseje customizar credenciais ou portas, copie o arquivo de exemplo e crie seu `.env` dentro da pasta `infra/`:

```bash
cp infra/.env.example infra/.env
```

| Variável | Valor Padrão | Descrição |
|---|---|---|
| `POSTGRES_USER` | `extensopedia` | Usuário do banco de dados |
| `POSTGRES_PASSWORD` | `extensopedia` | Senha do banco de dados |
| `POSTGRES_DB` | `extensopedia` | Nome do banco padrão |
| `POSTGRES_PORT` | `5432` | Porta local no host (ligada a `127.0.0.1`) |

## Comandos do Banco de Dados

Os comandos a seguir podem ser executados a partir da raiz do projeto (com `-f infra/docker-compose.yml`) ou entrando na pasta `infra/`:

### 1. Subir o banco de dados

Para iniciar o container do PostgreSQL em segundo plano:

```bash
docker compose -f infra/docker-compose.yml up -d
```

### 2. Verificar status e integridade (*healthcheck*)

Para verificar se o container está em execução e saudável (*healthy*):

```bash
docker compose -f infra/docker-compose.yml ps
```

### 3. Visualizar logs

Para acompanhar os logs do serviço em tempo real:

```bash
docker compose -f infra/docker-compose.yml logs -f postgres
```

### 4. Conectar ao PostgreSQL via terminal (CLI)

Para abrir um console interativo `psql` diretamente no container:

```bash
docker compose -f infra/docker-compose.yml exec postgres psql -U extensopedia -d extensopedia
```

### 5. Parar o banco de dados

Para pausar/parar a execução mantendo os containers e os dados preservados:

```bash
# Apenas parar os containers
docker compose -f infra/docker-compose.yml stop

# Ou parar e remover containers/redes (dados no volume são mantidos)
docker compose -f infra/docker-compose.yml down
```

### 6. Resetar o banco de dados

Para remover todos os containers e apagar o volume persistido (limpeza completa para recriação do zero):

```bash
# Remove containers, rede e o volume de dados (-v)
docker compose -f infra/docker-compose.yml down -v

# Recria e sobe o banco zerado
docker compose -f infra/docker-compose.yml up -d
```

> **Atenção:** O comando `down -v` apagará permanentemente todos os registros salvos no volume local do PostgreSQL.
