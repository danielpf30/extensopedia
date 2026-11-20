# Dicionário de dados — Extensopédia

> Rascunho da issue #19. Diagrama em [der.md](der.md). Coluna **Nulo?**: `N` = obrigatório (`NOT NULL`), `S` = opcional.
> Todas as tabelas (exceto domínio e `configuracoes`) têm `criado_em timestamptz NOT NULL DEFAULT now()` e `atualizado_em timestamptz NOT NULL DEFAULT now()`.

## 1. Tabelas de domínio

Formato comum: `id smallint PK identity`, `codigo varchar(40) UNIQUE NOT NULL`, `nome varchar(80) NOT NULL`, `ativo boolean NOT NULL DEFAULT true`.

| Tabela | Valores iniciais | Origem |
|---|---|---|
| `perfis` | GESTOR_ESCOLAR, DOCENTE_IES, ADMINISTRADOR | RF001, RF010 (visitante não tem conta) |
| `status_demanda` | Pendente, Em andamento, Concluída | RF006, RF008 |
| `status_projeto` | Rascunho, Em análise, Ativo, Concluído, Rejeitado | RF009 + issue #19 |
| `prioridades` | a definir (ex.: Baixa, Média, Alta) | RF006 |
| `areas_tematicas` | a definir | RF003, RF006, RF009 |
| `tipos_atividade` | a definir | RF006 |
| `tipos_escola` | a definir | RF005 |
| `dependencias_administrativas` | Federal, Estadual, Municipal (confirmar) | RF005 |
| `tipos_notificacao` | a definir (ex.: demanda assumida, candidatura recebida) | RF007, RF008 |

`subareas`: igual ao formato comum, mais `area_id smallint NOT NULL FK → areas_tematicas`. `UNIQUE (area_id, codigo)`.

## 2. Localidades

### estados
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | smallint | N | PK |
| sigla | char(2) | N | UF. `UNIQUE` |
| nome | varchar(60) | N | Nome do estado |

### cidades
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | int | N | PK |
| estado_id | smallint | N | FK → estados |
| nome | varchar(120) | N | Nome da cidade |
| codigo_ibge | char(7) | S | `UNIQUE` quando preenchido |

`UNIQUE (estado_id, nome)`.

## 3. Usuários e autenticação (RF001, RF010)

### usuarios
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| nome | varchar(150) | N | Nome completo |
| email | varchar(254) | N | E-mail institucional. `UNIQUE` em `lower(email)` |
| senha_hash | varchar(255) | N | Hash seguro (bcrypt/argon2). Nunca a senha |
| perfil_id | smallint | N | FK → perfis |
| curso | varchar(150) | S | Curso do docente (RF009) |
| lattes_url | varchar(255) | S | Currículo Lattes (RF009) |
| suspenso | boolean | N | `DEFAULT false`. Se `true`, bloqueia login (RF010) |
| criado_em / atualizado_em | timestamptz | N | Auditoria básica |

### tokens_redefinicao_senha
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| usuario_id | bigint | N | FK → usuarios. `ON DELETE CASCADE` |
| token_hash | varchar(128) | N | Hash do token enviado por e-mail. `UNIQUE` |
| expira_em | timestamptz | N | Validade do token |
| usado_em | timestamptz | S | Preenchido quando o token é consumido |

## 4. Escolas (RF005)

### escolas
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| nome | varchar(200) | N | Nome da escola |
| inep | char(8) | N | Código INEP. `UNIQUE`, `CHECK (inep ~ '^[0-9]{8}$')` |
| endereco | varchar(255) | N | Logradouro, número, bairro |
| cidade_id | int | N | FK → cidades (estado vem da cidade) |
| url_google_maps | varchar(500) | S | Localização no Google Maps |
| tipo_escola_id | smallint | N | FK → tipos_escola |
| dependencia_id | smallint | N | FK → dependencias_administrativas |
| numero_alunos | int | N | `CHECK (numero_alunos >= 0)` |
| site | varchar(255) | S | Site opcional |
| contato_email | varchar(254) | N | Contato institucional |
| contato_telefone | varchar(20) | S | Contato institucional |
| cadastrada_por | bigint | S | FK → usuarios (quem cadastrou) |

## 5. Demandas (RF006, RF008)

### demandas
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK. É o "identificador da demanda" exibido ao gestor |
| escola_id | bigint | N | FK → escolas |
| criado_por | bigint | N | FK → usuarios (gestor) |
| titulo | varchar(200) | N | Título exibido no painel (RF008) |
| descricao | text | N | Descrição da demanda |
| area_id | smallint | N | FK → areas_tematicas |
| tipo_atividade_id | smallint | N | FK → tipos_atividade |
| recursos | text | S | Recursos disponíveis/necessários |
| cidade_id | int | S | FK → cidades. Local de execução, se diferente da escola |
| publico_alvo | varchar(200) | N | Ex.: alunos do 9º ano |
| quantidade_publico | int | N | `CHECK (quantidade_publico > 0)` |
| prioridade_id | smallint | N | FK → prioridades |
| data_limite | date | S | Prazo opcional |
| contato_nome | varchar(150) | N | Contato da demanda |
| contato_email | varchar(254) | N | Contato da demanda |
| contato_telefone | varchar(20) | S | Contato da demanda |
| status_id | smallint | N | FK → status_demanda. Inicia em **Pendente** |
| assumida_por | bigint | S | FK → usuarios (docente que clicou em Assumir Demanda) |
| assumida_em | timestamptz | S | Data de início do atendimento |
| concluida_em | timestamptz | S | Data de conclusão (alimenta relatórios, RF010) |

Regras: `CHECK (status em Pendente → assumida_por IS NULL)`; `concluida_em >= assumida_em`.

### anexos_demanda
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| demanda_id | bigint | N | FK → demandas. `ON DELETE CASCADE` |
| nome_arquivo | varchar(255) | N | Nome original |
| tipo_mime | varchar(100) | N | Documento, imagem ou vídeo |
| tamanho_bytes | bigint | N | `CHECK (tamanho_bytes > 0)` |
| caminho | varchar(500) | N | Caminho no armazenamento (arquivo fora do banco) |

### mensagens (interação, RF008)
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| demanda_id | bigint | N | FK → demandas |
| autor_id | bigint | N | FK → usuarios |
| conteudo | text | N | Texto da resposta |
| criado_em | timestamptz | N | Data de envio |

### reunioes (agendamento, RF008)
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| demanda_id | bigint | N | FK → demandas |
| organizador_id | bigint | N | FK → usuarios (docente) |
| inicio_em | timestamptz | N | Início |
| fim_em | timestamptz | S | `CHECK (fim_em IS NULL OR fim_em >= inicio_em)` |
| local_ou_link | varchar(500) | S | Sala ou link da reunião |
| observacoes | text | S | Pauta/observações |

## 6. Projetos (RF003, RF004, RF009)

### projetos
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| proponente_id | bigint | N | FK → usuarios (docente IES). Nome, curso, e-mail e Lattes vêm de `usuarios` |
| titulo | varchar(200) | N | Título |
| resumo | text | N | Resumo exibido na listagem (RF003) |
| carga_horaria | int | N | Horas. `CHECK (carga_horaria > 0)` |
| vagas | int | N | `CHECK (vagas >= 0)` |
| possui_vinculo_curricular | boolean | N | Se há vínculo com disciplina |
| disciplina | varchar(150) | S | `CHECK (NOT possui_vinculo_curricular OR disciplina IS NOT NULL)` |
| area_id | smallint | N | FK → areas_tematicas |
| subarea_id | smallint | S | FK → subareas |
| justificativa | text | N | Texto pedagógico |
| objetivos | text | N | Texto pedagógico |
| metodologia | text | S | Exibida na ficha (RF007) |
| recursos | text | S | Recursos do projeto |
| data_inicio | date | S | Período do projeto |
| data_fim | date | S | `CHECK (data_fim >= data_inicio)` |
| status_id | smallint | N | FK → status_projeto. Inicia em **Rascunho** |
| destaque | boolean | N | `DEFAULT false`. Vitrine (RF004) |
| imagem_url | varchar(500) | S | Imagem do card (RF004) |
| publicado_em | timestamptz | S | Preenchido ao virar Ativo |

### projeto_colaboradores
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| projeto_id | bigint | N | FK → projetos. `ON DELETE CASCADE` |
| usuario_id | bigint | S | FK → usuarios, se o colaborador tiver conta |
| nome | varchar(150) | N | Nome do colaborador |
| email | varchar(254) | S | E-mail |

`UNIQUE (projeto_id, usuario_id)` quando `usuario_id` não é nulo.

### cronograma_atividades
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| projeto_id | bigint | N | FK → projetos. `ON DELETE CASCADE` |
| descricao | varchar(300) | N | Atividade |
| data_inicio | date | N | Início |
| data_fim | date | N | `CHECK (data_fim >= data_inicio)` (RF009: cronologia inválida) |

### itens_orcamento
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| projeto_id | bigint | N | FK → projetos. `ON DELETE CASCADE` |
| descricao | varchar(300) | N | Item |
| quantidade | int | N | `CHECK (quantidade > 0)` |
| valor_unitario | numeric(12,2) | N | `CHECK (valor_unitario >= 0)` |
| valor_total | numeric(12,2) | N | Coluna gerada: `quantidade * valor_unitario` |
| finalidade | varchar(300) | N | Para que serve |
| fonte | varchar(150) | N | Fonte do recurso |

O total geral do projeto é calculado com `SUM(valor_total)` (não é armazenado).

## 7. Candidaturas (RF007)

### candidaturas
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| projeto_id | bigint | N | FK → projetos |
| escola_id | bigint | N | FK → escolas |
| criado_por | bigint | N | FK → usuarios (gestor) |
| criado_em | timestamptz | N | Data da inscrição |

`UNIQUE (escola_id, projeto_id)`.

## 8. Apoio, relatórios e administração (RF008, RF010)

### feedbacks
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| demanda_id | bigint | S | FK → demandas |
| projeto_id | bigint | S | FK → projetos |
| autor_id | bigint | N | FK → usuarios |
| nota | smallint | S | `CHECK (nota BETWEEN 1 AND 5)` |
| comentario | text | S | Texto livre |

`CHECK (num_nonnulls(demanda_id, projeto_id) = 1)`. **A confirmar com a equipe.**

### notificacoes
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| usuario_id | bigint | N | FK → usuarios (destinatário) |
| tipo_id | smallint | N | FK → tipos_notificacao |
| titulo | varchar(150) | N | Título |
| mensagem | text | N | Corpo |
| demanda_id | bigint | S | FK → demandas (contexto) |
| projeto_id | bigint | S | FK → projetos (contexto) |
| lida_em | timestamptz | S | Nulo = não lida |

### configuracoes
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| chave | varchar(80) | N | PK. Ex.: `politica_privacidade`, `termos_uso` |
| valor | text | N | Conteúdo/valor |
| atualizado_por | bigint | S | FK → usuarios (administrador) |
| atualizado_em | timestamptz | N | Data da alteração |

### audit_log
| Coluna | Tipo | Nulo? | Descrição / regra |
|---|---|---|---|
| id | bigint | N | PK |
| usuario_id | bigint | S | FK → usuarios (nulo = ação do sistema) |
| acao | varchar(50) | N | Ex.: INSERT, UPDATE, SUSPENDER_USUARIO |
| entidade | varchar(80) | N | Nome da tabela afetada |
| entidade_id | bigint | S | Id do registro afetado |
| dados_anteriores | jsonb | S | Estado antes |
| dados_novos | jsonb | S | Estado depois |
| criado_em | timestamptz | N | Data/hora da ação |

Tabela somente de inserção: sem `UPDATE` nem `DELETE`.

## 9. Rastreabilidade RF → tabelas

| RF | Tabelas principais |
|---|---|
| RF001 | usuarios, perfis, tokens_redefinicao_senha |
| RF003, RF004 | projetos, areas_tematicas, cidades, estados |
| RF005 | escolas, cidades, estados, tipos_escola, dependencias_administrativas |
| RF006 | demandas, anexos_demanda, status_demanda, prioridades, tipos_atividade |
| RF007 | candidaturas, projetos, notificacoes |
| RF008 | demandas, mensagens, reunioes, notificacoes, status_demanda |
| RF009 | projetos, projeto_colaboradores, cronograma_atividades, itens_orcamento, status_projeto |
| RF010 | usuarios, perfis, configuracoes, audit_log, notificacoes |
