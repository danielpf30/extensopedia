# 1. Introdução e descrição geral

## 1.1 Objetivo

O Extensopedia é uma plataforma web destinada a intermediar a comunicação e a
colaboração entre escolas públicas de educação básica e instituições de ensino
superior (IES). A plataforma viabiliza a curricularização da extensão
universitária e fomenta projetos voltados prioritariamente ao desenvolvimento e
à qualificação contínua do corpo docente do ensino fundamental e médio.

Este documento formaliza os requisitos necessários ao projeto, implementação,
testes e homologação do sistema.

## 1.2 Escopo

A versão consolidada contempla:

- cadastro institucional de escolas públicas, incluindo código INEP, localização
  e dados administrativos;
- controle de perfis de escola, IES e administrador;
- registro e divulgação de demandas escolares, com área temática, formato,
  público-alvo, prioridade, prazo e anexos;
- vitrine e busca pública de projetos por área, localização e palavras-chave;
- painel da IES para visualizar, filtrar e atender demandas;
- submissão de projetos com vínculo curricular, cronograma e orçamento com
  totalizadores automáticos;
- administração de usuários, parâmetros globais, métricas e relatórios.

O MVP pode utilizar interações simplificadas e triagem manual por e-mail, mas
esta especificação registra a arquitetura completa de produção para
implementação modular em sprints.

## 1.3 Sistemas relacionados

- **Google Maps API:** geolocalização das escolas e mapa interativo, consumido
  por API REST ou SDK JavaScript em HTTPS.
- **Servidor SMTP/e-mail:** notificações transacionais, avisos de demandas,
  respostas e agendamentos, com SMTP seguro (TLS/SSL).
- **Plataforma Lattes (CNPq):** consulta e vinculação externa dos currículos dos
  docentes proponentes e colaboradores.

## 1.4 Usuários

### Gestores e educadores da educação básica

Diretores, coordenadores pedagógicos e professores de escolas públicas de
ensino fundamental e médio. Cadastram a escola, publicam demandas e manifestam
interesse em projetos ofertados pelas IES.

### Professores e coordenadores de extensão da IES

Professores, pesquisadores e coordenadores de programas de extensão. Consultam
carências escolares, submetem propostas completas e interagem com as escolas
para planejar atividades.

### Administrador

Responsável por contas, permissões, consistência das instituições, moderação,
segurança, configurações globais e relatórios de impacto.

## 1.5 Convenções de identificação e prioridade

Cada requisito é identificado pelo nome da subseção e pelo seu código, como
`[Navegação Pública.RF001]` ou `[Confiabilidade.NF005]`.

- **Essencial:** sem ele o sistema não entra em funcionamento.
- **Importante:** sem ele o sistema funciona de forma insatisfatória.
- **Desejável:** pode ser deixado para versões posteriores.
