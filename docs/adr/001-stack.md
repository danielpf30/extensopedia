# ADR 001 — Stack da aplicação

- **Status:** Proposta, aguardando aprovação da equipe e do orientador
- **Data:** outubro de 2026 (atualizada em novembro de 2026)

## Contexto

O Extensopédia conecta demandas de escolas públicas a projetos de extensão
de instituições de ensino superior. Os requisitos RF001 a RF010 pedem
autenticação por perfil, cadastro de escolas, demandas e projetos, filtros
de busca, notificações e relatórios. A equipe é pequena e acadêmica, então a
stack deve ser conhecida, bem documentada e simples de rodar localmente.

## Decisões já estabelecidas

- PostgreSQL executado localmente com Docker.
- Nginx como proxy reverso.
- Docker Compose para orquestração local.

## Resumo das decisões propostas

| Tema | Proposta |
|---|---|
| Backend | Java 21 (LTS) com Spring Boot |
| Frontend | React com TypeScript e Vite |
| ORM | Spring Data JPA (Hibernate) |
| Migrations | Flyway, SQL puro |
| Autenticação | Spring Security, sessão com cookie |
| Testes | JUnit 5, Testcontainers, Vitest |
| Busca por localização | Haversine (sem PostGIS) |
| PostgreSQL | Versão major fixa: 16 |

As decisões abaixo ainda precisam ser confirmadas na reunião de aprovação.

## Decisões propostas

### 1. Backend: Java com Spring Boot

**Decisão:** Java 21 (versão LTS) com Spring Boot, empacotado com Maven.
A versão exata do Spring Boot é fixada no `pom.xml` na criação do projeto.

**Alternativas consideradas:** Node.js com NestJS e Kotlin com Spring.

**Consequências:**

- A equipe já usa Java e Spring, o que reduz a curva de aprendizado.
- Ecossistema maduro para segurança, validação e testes.
- O projeto exige JDK 21 instalado ou uso de container para o build.

### 2. Frontend: React com TypeScript

**Decisão:** React com TypeScript, gerado com Vite, consumindo a API REST do
backend.

**Alternativas consideradas:** páginas renderizadas no servidor (Thymeleaf) e
Angular.

**Consequências:**

- Interface com formulários dinâmicos, como o total do orçamento em tempo
  real (RF009), é simples de construir.
- Exige um segundo projeto (`frontend/`) e um processo de build.
- O Nginx serve os arquivos estáticos e encaminha `/api` ao backend, o que
  mantém tudo na mesma origem.

### 3. ORM: Spring Data JPA

**Decisão:** Spring Data JPA com Hibernate, mapeando o modelo do DER
(`docs/diagramas/der.md`).

**Alternativas consideradas:** JdbcTemplate, jOOQ e MyBatis.

**Consequências:**

- Reduz código repetitivo de CRUD.
- O schema é controlado pelas migrations, não pelo Hibernate: a propriedade
  `spring.jpa.hibernate.ddl-auto` fica em `validate` ou `none`.
- Consultas complexas, como os relatórios do RF010, podem usar consultas
  nativas ou JPQL.

### 4. Migrations: Flyway

**Decisão:** Flyway com migrations em SQL puro, versionadas no repositório.
Os arquivos ficam em `infra/db/migrations` (fora do backend, que ainda não
existe) e podem ser apontados pelo Spring depois. O rollback é feito por
scripts `down` manuais, chamados pelo Makefile.

**Alternativas consideradas:** Liquibase.

**Consequências:**

- SQL puro é fácil de revisar em pull request.
- A edição Community do Flyway não tem `undo` automático, então cada
  migration precisa de um script `down` escrito à mão.
- Se a equipe preferir rollback nativo, a alternativa é o Liquibase, com
  changelogs mais verbosos.

### 5. Autenticação: sessão com cookie

**Decisão:** Spring Security com sessão no servidor e cookie `HttpOnly`,
proteção contra CSRF e senhas com hash seguro (bcrypt ou argon2). O RF001
descreve "iniciar a sessão" após validar as credenciais. A recuperação de
senha usa token temporário de uso único (tabela `tokens_redefinicao_senha`).

**Alternativas consideradas:** JWT em header `Authorization`.

**Consequências:**

- Como o Nginx coloca frontend e API na mesma origem, a sessão com cookie é
  mais simples e segura contra roubo de token no navegador.
- O backend guarda estado de sessão (em memória ou em tabela), o que pesa se
  houver várias instâncias.
- Se surgir um aplicativo móvel ou integração externa, vale reavaliar JWT.

### 6. Testes

**Decisão:**

- Backend: JUnit 5, Mockito e Spring Boot Test.
- Integração com banco: Testcontainers com PostgreSQL, para testar as
  migrations e as constraints do DER.
- Frontend: Vitest e Testing Library.
- Os testes rodam no CI (GitHub Actions).

**Alternativas consideradas:** H2 em memória para testes de banco.

**Consequências:**

- Testcontainers usa o mesmo PostgreSQL de produção, então evita diferenças
  de comportamento que o H2 teria.
- Exige Docker disponível no CI e nas máquinas da equipe.

### 7. Busca por localização: Haversine

**Decisão:** cálculo de distância pela fórmula de Haversine, com latitude e
longitude em colunas numéricas, sem a extensão PostGIS. A decisão depende de
como a localização da escola será guardada (link do Google Maps ou
coordenadas), ponto em aberto do DER.

**Alternativas consideradas:** PostGIS.

**Consequências:**

- Mantém a imagem oficial do PostgreSQL, sem extensões adicionais.
- Suficiente para filtrar por proximidade em poucas milhares de escolas.
- Se o projeto exigir consultas geográficas avançadas, a migração para
  PostGIS é possível, com uma nova migration e troca da imagem do Docker.

### 8. Versão fixa do PostgreSQL

**Decisão:** PostgreSQL 16, com tag de versão fixa no Docker Compose (nunca
`latest`). É a versão que o Compose já usa (`postgres:16-alpine`). A mesma
versão vale para o CI e para os testes.

**Alternativas consideradas:** PostgreSQL 17 e 18.

**Consequências:**

- Ambiente reproduzível entre todas as máquinas da equipe.
- Atualizações de versão major passam a ser decisões explícitas, registradas
  em uma nova ADR.

## Consequências gerais

- Duas aplicações (backend e frontend) atrás de um único Nginx, orquestradas
  pelo Docker Compose.
- O banco é a fonte da verdade do schema: toda mudança passa por migration.
- Decisões em aberto podem gerar novas ADRs numeradas (002, 003, ...).

## Pendências para a reunião de aprovação

- Confirmar ou trocar cada decisão proposta acima.
- Definir quem aprova os projetos (Em análise para Ativo), que afeta o
  modelo de perfis e permissões.
- Decidir como guardar a localização da escola (link do Maps ou
  coordenadas).
