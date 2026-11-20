# 2. Requisitos funcionais

Os requisitos funcionais são modelados como casos de uso. Cada bloco registra
propósito, atores, prioridade, entradas, pré-condições, saídas, pós-condições e
fluxos de eventos.

## Navegação pública

### RF001 — Navegar pelo cabeçalho principal e autenticação

- **Ator:** visitante, gestor escolar ou docente IES.
- **Prioridade:** Essencial.
- **Interface:** cabeçalho global, modal de login e tela de cadastro.
- **Entradas:** links Página Inicial, Sobre, Contato, Entrar e Cadastre-se;
  nome, e-mail institucional, perfil, senha e confirmação; e-mail para
  recuperação.
- **Pré-condição:** aplicação acessível pelo navegador.
- **Saídas:** navegação para a seção escolhida, conta criada, sessão iniciada ou
  e-mail com link de redefinição.
- **Pós-condição:** rota solicitada exibida ou usuário autenticado em sua área.

#### RF001 — Fluxo principal

1. O usuário visualiza o cabeçalho e seleciona uma opção.
2. O logotipo ou Página Inicial direciona para a home.
3. Sobre exibe as informações institucionais.
4. Contato exibe canais de atendimento e suporte.
5. Entrar exibe o modal de autenticação.
6. O usuário informa e-mail e senha.
7. O sistema valida as credenciais com hash seguro, inicia a sessão e direciona
   ao painel do perfil.
8. O botão Entrar é substituído pelo identificador do usuário, com atalhos para
   perfil e logout.

#### RF001 — Fluxos alternativos e exceções

- **Autocadastro:** o usuário escolhe Cadastre-se, informa nome, e-mail
  institucional, perfil e senha; o sistema valida a unicidade, grava a conta e
  autentica automaticamente.
- **Recuperação de senha:** o usuário escolhe Esqueci minha senha, informa o
  e-mail e recebe token temporário com link seguro.
- **Credenciais inválidas:** o sistema recusa o acesso, mantém o modal aberto e
  exibe “E-mail ou senha inválidos. Verifique os dados informados.”.

### RF002 — Visualizar banner de boas-vindas

- **Ator:** visitante, gestor escolar ou docente IES.
- **Prioridade:** Importante.
- **Interface:** banner institucional da página inicial.
- **Entrada:** acesso à URL base.
- **Pré-condição:** nenhuma.
- **Saída:** título e síntese sobre curricularização e qualificação docente.
- **Pós-condição:** usuário contextualizado sobre o objetivo da plataforma.

#### RF002 — Fluxo principal

Ao acessar a página inicial, o sistema renderiza o banner
com a mensagem de boas-vindas e o texto descritivo. O caso de uso é encerrado.

### RF003 — Pesquisar projetos de extensão disponíveis

- **Ator:** gestor escolar ou visitante.
- **Prioridade:** Essencial.
- **Interface:** caixa de busca e página de listagem de projetos.
- **Entradas:** palavra-chave, área e localização, todos opcionais.
- **Pré-condição:** existência de projetos cadastrados.
- **Saída:** lista com título, resumo, área e datas.
- **Pós-condição:** resultados filtrados apresentados.

#### RF003 — Fluxo principal

1. O usuário informa um ou mais filtros.
2. Aciona pesquisar.
3. O sistema valida as entradas e consulta o banco.
4. O sistema direciona à listagem correspondente.

#### RF003 — Fluxos alternativo e de exceção

- **Busca sem filtros:** o sistema lista todos os projetos disponíveis, ordenados
  por data de publicação.
- **Nenhum resultado:** exibe “Nenhum projeto encontrado para os filtros
  informados” e sugere redefinir a busca.

### RF004 — Visualizar vitrine de destaques

- **Ator:** gestor escolar ou visitante.
- **Prioridade:** Importante.
- **Interface:** cards de destaque na página inicial.
- **Entrada:** carregamento da home ou clique em um card.
- **Pré-condição:** projetos ativos marcados como destaque.
- **Saída:** grade com imagem, título e resumo.
- **Pós-condição:** clique direciona aos detalhes do projeto.

#### RF004 — Fluxo principal

1. O usuário chega à seção Destaques de Projetos.
2. O sistema exibe cards com imagem, título e área temática.
3. O usuário seleciona um card.
4. O sistema abre os detalhes completos.

**Exceção:** se não houver destaques, a seção é ocultada ou exibe os projetos
mais recentes.

## Demandas escolares

### RF005 — Selecionar ou cadastrar escola pública

- **Ator:** gestor escolar.
- **Prioridade:** Essencial.
- **Interface:** seleção e cadastro de escolas.
- **Entradas:** nome ou código INEP; ou nome, INEP de 8 dígitos, endereço,
  localização Google Maps, tipo, dependência administrativa, número de alunos,
  site opcional e contato institucional.
- **Pré-condição:** gestor acessando o cadastro de demandas.
- **Saída:** escola selecionada e formulário de demanda liberado.
- **Pós-condição:** nova escola persistida quando cadastrada.

#### RF005 — Fluxo principal

1. O gestor acessa o cadastro de demandas.
2. O sistema solicita a escola.
3. O gestor pesquisa por nome ou INEP.
4. Seleciona uma instituição.
5. O sistema carrega os dados e libera a demanda.

#### RF005 — Fluxos alternativo e de exceção

- **Escola não cadastrada:** o gestor escolhe Cadastrar Nova Escola, preenche os
  dados, salva e é direcionado à demanda já vinculada.
- **INEP duplicado:** o sistema bloqueia o cadastro e informa “Código INEP já
  registrado. Selecione a escola pela lista de busca”.

### RF006 — Cadastrar demanda escolar

- **Ator:** gestor escolar.
- **Prioridade:** Essencial.
- **Interface:** formulário de demandas.
- **Entradas:** descrição, área, tipo de atividade, recursos, localização,
  público-alvo, quantidade, prioridade, data limite opcional, anexos e contato.
- **Pré-condição:** escola identificada.
- **Saída:** confirmação e identificador da demanda.
- **Pós-condição:** demanda persistida com status `Pendente` e vinculada à escola.

#### RF006 — Fluxo principal

1. O formulário exibe a escola selecionada.
2. O gestor informa descrição, área e formato.
3. Define público, quantidade e recursos.
4. Define prioridade e, opcionalmente, prazo.
5. Anexa documentos, imagens ou vídeos.
6. Confirma o contato e envia.
7. O sistema valida, armazena anexos, grava a demanda e confirma o recebimento.

**Exceção RF006:** se descrição, área ou outro campo essencial estiver ausente, o
envio é bloqueado e os campos pendentes são destacados.

## Projetos para escolas

### RF007 — Consultar e candidatar-se a projetos de extensão

- **Ator:** gestor escolar.
- **Prioridade:** Essencial.
- **Interface:** projetos disponíveis e ficha detalhada.
- **Entradas:** filtros de área, estado/cidade e status; seleção de projeto;
  botão Tenho Interesse / Inscrever Escola.
- **Pré-condição:** projeto ativo cadastrado.
- **Saída:** listagem, detalhes completos e confirmação de interesse.
- **Pós-condição:** candidatura vinculada ao projeto e notificação enviada ao
  coordenador da IES.

#### RF007 — Fluxo principal

1. O gestor acessa Projetos Disponíveis.
2. O sistema lista iniciativas ativas com títulos, resumos, áreas e períodos.
3. O gestor filtra por área ou localização.
4. O sistema atualiza a listagem.
5. O gestor abre objetivos, metodologia e docentes.
6. Seleciona Tenho Interesse / Inscrever Escola.
7. O sistema vincula a escola e notifica o coordenador.

#### RF007 — Fluxos alternativo e de exceção

- **Consulta sem inscrição:** o gestor retorna à listagem; nenhum registro é
  criado e os filtros são preservados.
- **Nenhum resultado:** o sistema informa a ausência e sugere redefinir os
  critérios.

## Atendimento IES

### RF008 — Gerenciar e atender demandas escolares

- **Ator:** docente IES ou coordenador de extensão.
- **Prioridade:** Essencial.
- **Interface:** painel de demandas, ficha detalhada e modal de interação.
- **Entradas:** filtros por área, atividade, público, localização, prioridade e
  período; demanda; resposta; agendamento; colaboradores; botão Assumir
  Demanda.
- **Pré-condição:** docente autenticado e demandas cadastradas.
- **Saída:** lista paginada, detalhes, anexos e confirmação da ação.
- **Pós-condição:** ciclo atualizado e gestor notificado.

#### RF008 — Fluxo principal

1. O docente acessa o Painel de Demandas.
2. O sistema lista carências com título, instituição, prioridade e status.
3. O docente aplica filtros avançados.
4. Abre o detalhamento, incluindo descrição, público, quantidade e anexos.
5. Seleciona Assumir Demanda.
6. O sistema altera o estado para `Em andamento` e notifica a escola.

**Fluxo alternativo RF008:** após a execução, o docente marca a demanda como
`Concluída`; o sistema atualiza o registro e a inclui nos relatórios de impacto.

## Gestão de projetos IES

### RF009 — Formular proposta de projeto de extensão

- **Ator:** docente IES.
- **Prioridade:** Essencial.
- **Interface:** formulário de projetos.
- **Entradas:** proponente, curso, e-mail, Lattes e colaboradores; título, carga
  horária, vagas, vínculo curricular, área e subárea; justificativa, objetivos e
  recursos; atividades e datas; itens de orçamento com descrição, quantidade,
  valor, finalidade e fonte.
- **Pré-condição:** docente autenticado com perfil IES.
- **Saída:** total por item, total geral em tempo real e confirmação.
- **Pós-condição:** proposta persistida para análise ou publicação.

#### RF009 — Fluxo principal

1. O docente abre Gerenciamento de Projetos e escolhe Novo Projeto.
2. Informa dados institucionais e adiciona colaboradores.
3. Define título, carga horária e vagas.
4. Informa se há vínculo curricular e, se sim, a disciplina.
5. Seleciona área, subárea e preenche textos pedagógicos.
6. Adiciona atividades com descrição e início/fim.
7. Adiciona itens de orçamento.
8. O sistema calcula quantidade vezes valor unitário e soma o total.
9. O docente salva a proposta.
10. O sistema grava como `Submetida/Em Análise` ou `Aguardando Aprovação
    Institucional`, antes da publicação como `Ativo`.

#### RF009 — Fluxos alternativo e de exceção

- **Sem vínculo curricular:** ao selecionar Não, o campo de disciplina é
  ocultado e deixa de ser obrigatório.
- **Cronologia inválida:** se o fim preceder o início, a linha não é inserida e
  o sistema alerta a inconsistência temporal.

## Administração

### RF010 — Administrar o sistema e extrair métricas de impacto

- **Ator:** administrador.
- **Prioridade:** Essencial.
- **Interface:** gestão de usuários, dashboard e parâmetros globais.
- **Entradas:** papéis e suspensão de usuários; período de relatório; políticas
  de privacidade e termos.
- **Pré-condição:** administrador autenticado.
- **Saída:** usuários atualizados, dashboards e relatórios para download.
- **Pós-condição:** permissões e diretrizes persistidas.

#### RF010 — Fluxo principal

1. O administrador acessa o módulo administrativo.
2. Consulta cadastros, gerencia permissões e modera contas.
3. Consulta escolas, demandas recebidas/atendidas e projetos realizados.
4. Exporta o relatório consolidado de impacto social.
5. Revisa notificações e políticas globais.
6. Salva configurações; o sistema atualiza as regras.

**Exceção RF010:** ao suspender uma conta inconsistente, o sistema bloqueia sua
autenticação até a regularização cadastral.
