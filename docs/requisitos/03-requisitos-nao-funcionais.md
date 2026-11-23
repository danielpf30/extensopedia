# 3. Requisitos não funcionais

## Usabilidade

### NF001 — Design responsivo e multiplataforma

- **Descrição:** a interface deve adaptar-se a desktops, tablets e smartphones,
  mantendo navegação completa e legibilidade.
- **Prioridade:** Essencial.
- **Casos associados:** RF001–RF010.

### NF002 — Facilidade de preenchimento e automação de cálculos

- **Descrição:** o formulário de projetos deve calcular em tempo real o total
  por item e o total geral do orçamento, prevenindo inconsistências aritméticas.
- **Prioridade:** Importante.
- **Casos associados:** RF009.

### NF003 — Integração com mapeamento visual de escolas

- **Descrição:** o cadastro e a visualização das escolas devem integrar mapa
  georreferenciado do Google Maps para apoiar a avaliação logística.
- **Prioridade:** Importante.
- **Casos associados:** RF005 e RF008.

## Confiabilidade

### NF004 — Disponibilidade operacional

- **Descrição:** a plataforma deve manter disponibilidade mínima de 99,5% nos
  dias úteis, reduzindo paradas durante o período letivo e prazos acadêmicos.
- **Prioridade:** Essencial.

### NF005 — Integridade e validação de dados institucionais

- **Descrição:** validar unicidade e formato de 8 dígitos do código INEP, e
  formatos válidos para e-mails institucionais e URLs Lattes, bloqueando
  registros inconsistentes ou duplicados.
- **Prioridade:** Essencial.
- **Casos associados:** RF005 e RF009.

### NF006 — Persistência segura e tratamento de anexos

- **Descrição:** aceitar PDF, DOCX, PNG, JPG e MP4, com limite por arquivo;
  rejeitar arquivos corrompidos ou incompletos sem perder os dados textuais.
- **Prioridade:** Importante.
- **Casos associados:** RF006.

## Desempenho

### NF007 — Tempo de resposta para pesquisas e filtros

- **Descrição:** buscas públicas, catálogo de projetos e painel de demandas
  devem exibir resultados em até 2 segundos em condições normais de conexão.
- **Prioridade:** Essencial.
- **Casos associados:** RF003, RF007 e RF008.

### NF008 — Geração e exportação de relatórios de impacto

- **Descrição:** compilar e exportar métricas de demandas, projetos e
  participantes em até 5 segundos para bases de médio porte.
- **Prioridade:** Importante.
- **Casos associados:** RF010.

### NF009 — Suporte a acessos simultâneos

- **Descrição:** backend e banco devem suportar pelo menos 150 usuários
  concorrentes sem degradação perceptível no tempo de resposta.
- **Prioridade:** Importante.

## Segurança

### NF010 — Controle de acesso e autenticação

- **Descrição:** senhas devem ser armazenadas com hash criptográfico
  unidirecional e salt, usando bcrypt, Argon2 ou PBKDF2, sem texto plano.
- **Prioridade:** Essencial.
- **Casos associados:** RF001, RF008, RF009 e RF010.

### NF011 — Proteção de dados e privacidade (LGPD)

- **Descrição:** dados de contato pessoal e profissional devem ser armazenados
  e transmitidos por conexões criptografadas, como HTTPS, em conformidade com a
  LGPD.
- **Prioridade:** Essencial.
- **Casos associados:** RF005, RF006, RF009 e RF010.
