# PMO Control --- Personas

**Documento:** `personas.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Personas e perfis de uso do produto

------------------------------------------------------------------------

## 1. Objetivo

Este documento define as principais personas do PMO Control, seus
objetivos, responsabilidades, necessidades, dores, decisões, frequência
de uso e expectativas em relação ao produto.

As personas aqui descritas representam **perspectivas de uso**, não
apenas papéis de autorização.

Um mesmo papel técnico pode apresentar comportamentos diferentes
conforme a organização, e uma mesma pessoa pode acumular mais de uma
responsabilidade.

A autorização efetiva continua sendo definida por:

``` text
Tenant
+
Role
+
Scope
+
Permission
+
Data Policy
+
Workflow Rule
```

conforme `/docs/00-foundation/permission-model.md`.

------------------------------------------------------------------------

# 2. Por que separar Persona de Role

`Role` responde:

> **O que este usuário está autorizado a fazer?**

`Persona` responde:

> **O que este usuário precisa alcançar e por que utiliza o produto?**

Exemplo:

``` text
Role: PMO
Persona: Analista de Governança
```

Outro usuário pode possuir:

``` text
Role: PMO
Persona: PMO Lead
```

com necessidades diferentes, apesar de compartilhar parte das
permissões.

------------------------------------------------------------------------

# 3. Personas principais

O PMO Control considera inicialmente oito personas alinhadas aos papéis
padrão:

1.  Platform Administrator
2.  Tenant Administrator
3.  PMO Administrator / PMO Lead
4.  PMO Analyst
5.  Project Manager
6.  Contributor
7.  Executive
8.  Viewer / Stakeholder

As personas centrais para experiência de produto são:

``` text
PMO Analyst
PMO Lead
Project Manager
Executive
```

------------------------------------------------------------------------

# 4. Mapa de centralidade

  Persona                    Centralidade no produto Frequência esperada
  ------------------------ ------------------------- ----------------------
  PMO Analyst                             Muito alta Diária
  PMO Lead / PMO Admin                    Muito alta Diária
  Project Manager                               Alta Diária/Semanal
  Executive                                     Alta Semanal/Comitês
  Contributor                                  Média Conforme assignments
  Tenant Administrator                         Média Eventual
  Viewer / Stakeholder                   Média/Baixa Conforme necessidade
  Platform Administrator            Operacional SaaS Eventual

------------------------------------------------------------------------

# 5. Persona 1 --- PMO Analyst

## Arquétipo

**Nome fictício:** Mariana\
**Função:** Analista/Especialista de PMO\
**Frequência:** diária\
**Contexto:** acompanha diversos projetos simultaneamente.

## Objetivo principal

> **Garantir que os projetos estejam atualizados, identificar exceções e
> levar informações confiáveis para governança e decisão.**

## Responsabilidades

-   acompanhar projetos;
-   cobrar atualizações;
-   monitorar cronogramas;
-   acompanhar Milestones;
-   acompanhar Deliverables;
-   monitorar Risks;
-   monitorar Issues;
-   acompanhar Actions;
-   acompanhar Decisions;
-   identificar dependências;
-   preparar/revisar Status;
-   consolidar informações;
-   preparar fóruns;
-   gerar Reports;
-   acompanhar planos de ação.

## Dores atuais

Mariana frequentemente trabalha com:

``` text
Excel
PowerPoint
E-mail
Teams/Slack
Jira
Project
Documentos
Reuniões
```

As informações estão distribuídas.

Problemas comuns:

-   versões diferentes da mesma informação;
-   atualização atrasada;
-   dificuldade de saber o que mudou;
-   ações esquecidas;
-   riscos sem acompanhamento;
-   decisões pendentes;
-   muito tempo preparando reports;
-   pouca rastreabilidade histórica.

## Pergunta diária

> **"Onde preciso colocar minha atenção hoje?"**

## Perguntas frequentes

-   Quais ações estão vencidas?
-   Quais projetos estão sem Status?
-   Quais riscos se tornaram críticos?
-   O que mudou desde ontem?
-   Quais Milestones vencem esta semana?
-   Quais decisões estão bloqueando projetos?
-   Quem preciso cobrar?
-   Quais projetos pioraram?

## Funcionalidades mais importantes

``` text
My Day
Portfolio
Project Control Center
Milestones
Risks
Issues
Actions
Decisions
Status Update
Reports
PMO Copilot
```

## Valor esperado

Reduzir trabalho de coleta/consolidação e aumentar tempo disponível para
análise e governança.

## Momento de sucesso

Mariana abre o PMO Control pela manhã e, em poucos minutos, sabe:

``` text
What changed
What is late
What is critical
Who needs follow-up
What requires decision
```

------------------------------------------------------------------------

# 6. Persona 2 --- PMO Lead / PMO Admin

## Arquétipo

**Nome fictício:** Ricardo\
**Função:** PMO Lead / Coordenador de Governança\
**Frequência:** diária\
**Contexto:** responsável por padrões, portfólio e qualidade da
governança.

## Objetivo principal

> **Garantir consistência da governança e fornecer uma visão confiável
> do portfólio para liderança.**

## Responsabilidades

-   estruturar Portfolios;
-   governar Projects;
-   definir padrões;
-   acompanhar qualidade dos Status;
-   revisar indicadores;
-   revisar RAG;
-   acompanhar riscos sistêmicos;
-   preparar comitês;
-   monitorar decisões;
-   supervisionar PMOs;
-   garantir disciplina de atualização;
-   acompanhar qualidade de dados;
-   identificar problemas recorrentes.

## Dores atuais

-   cada projeto reporta de maneira diferente;
-   critérios de RAG inconsistentes;
-   reports excessivamente manuais;
-   falta de comparabilidade;
-   baixa confiança nos dados;
-   dificuldade de enxergar tendências;
-   pouca evidência sobre decisões passadas.

## Pergunta diária

> **"Onde a governança do portfólio está falhando ou exigindo
> intervenção?"**

## Perguntas frequentes

-   Quais projetos precisam de intervenção?
-   Quais PMOs/projetos estão com baixa qualidade de dados?
-   Quais riscos aparecem em vários projetos?
-   Quais decisões estão envelhecendo?
-   Onde existem atrasos recorrentes?
-   Qual Portfolio está deteriorando?
-   Quais Status precisam de revisão?

## Funcionalidades mais importantes

``` text
Executive Portfolio
Portfolio
My Day
Project Control Center
Status Update
RAG
Time Machine
Report Builder
Audit
PMO Copilot
Settings
```

## Valor esperado

Padronização, previsibilidade, rastreabilidade e menor dependência de
controles paralelos.

## Momento de sucesso

Ricardo consegue entrar em um comitê sabendo quais são:

-   as exceções;
-   os impactos;
-   as decisões necessárias;
-   as evidências;
-   os responsáveis.

------------------------------------------------------------------------

# 7. Persona 3 --- Project Manager

## Arquétipo

**Nome fictício:** Carlos\
**Função:** Gerente de Projeto\
**Frequência:** diária/semanal\
**Contexto:** responsável pela execução e atualização de um ou mais
projetos.

## Objetivo principal

> **Manter o projeto sob controle e comunicar seu estado sem duplicar
> trabalho.**

## Responsabilidades

-   acompanhar cronograma;
-   atualizar progresso;
-   revisar Forecast;
-   administrar Milestones;
-   administrar Deliverables;
-   registrar Risks;
-   registrar Issues;
-   acompanhar Actions;
-   registrar Dependencies;
-   fornecer Evidence;
-   preparar Status;
-   responder ao PMO.

## Dores atuais

-   atualizar Jira e depois Excel;
-   atualizar Excel e depois PowerPoint;
-   repetir a mesma informação em reuniões;
-   explicar variações várias vezes;
-   falta de clareza sobre o que o PMO espera;
-   Status report burocrático.

## Pergunta principal

> **"Como mantenho o PMO informado sem transformar reporting em um
> segundo trabalho?"**

## Perguntas frequentes

-   O que preciso atualizar antes do Status?
-   Quais Actions estão comigo?
-   Quais Milestones estão ameaçados?
-   O que mudou desde o último Status?
-   Existe algum campo obrigatório faltando?
-   Meu projeto está Green, Amber ou Red? Por quê?

## Funcionalidades mais importantes

``` text
Project Control Center
Schedule
Milestones
Deliverables
Risks
Issues
Actions
Dependencies
Documents
Status Update
```

## Valor esperado

Atualizar a informação na fonte e permitir que o sistema produza
automaticamente as visões de governança.

## Momento de sucesso

Carlos conclui sua atualização semanal sem precisar produzir manualmente
uma apresentação paralela.

------------------------------------------------------------------------

# 8. Persona 4 --- Executive

## Arquétipo

**Nome fictício:** Fernanda\
**Função:** CIO / Head / Diretora\
**Frequência:** semanal, sob demanda e em comitês\
**Contexto:** responsável por decisões, investimentos e resultados de um
conjunto de iniciativas.

## Objetivo principal

> **Entender rapidamente onde existe risco, impacto ou necessidade de
> decisão.**

## Responsabilidades

-   acompanhar portfólio;
-   avaliar investimentos;
-   tomar decisões;
-   remover bloqueios organizacionais;
-   priorizar;
-   avaliar riscos estratégicos;
-   acompanhar compromissos críticos.

## Dores atuais

-   apresentações com informação demais;
-   indicadores sem contexto;
-   divergência entre reports;
-   dificuldade de saber o que realmente exige decisão;
-   Status "verde" que esconde problemas;
-   relatórios desatualizados.

## Pergunta principal

> **"O que preciso saber e decidir agora?"**

## Perguntas frequentes

-   Quais projetos estão em risco?
-   Qual impacto?
-   O que mudou desde o último comitê?
-   Quanto está comprometido?
-   Quais decisões estão comigo?
-   Qual próximo Milestone crítico?
-   O problema está melhorando ou piorando?
-   Qual é a evidência?

## Funcionalidades mais importantes

``` text
Executive Portfolio
Project Dashboard
Decisions
Financial
Time Machine
Reports
PMO Copilot
```

## Preferência de experiência

Fernanda não quer operar detalhes.

A interface deve priorizar:

``` text
Signal > Noise
Exception > Routine
Impact > Activity
Decision > Detail
```

## Momento de sucesso

Em poucos minutos, Fernanda entende os cinco pontos que realmente
precisam de sua atenção.

------------------------------------------------------------------------

# 9. Persona 5 --- Contributor

## Arquétipo

**Nome fictício:** Lucas\
**Função:** membro de equipe / responsável por entrega ou ação\
**Frequência:** conforme assignments

## Objetivo principal

> **Atualizar rapidamente aquilo pelo qual sou responsável.**

## Responsabilidades possíveis

-   atualizar Action;
-   atualizar Deliverable;
-   anexar Evidence;
-   colaborar em Risk;
-   registrar comentário;
-   informar progresso.

## Dores atuais

-   ferramentas complexas para uma atualização simples;
-   solicitações de Status por diferentes canais;
-   falta de clareza sobre prioridade;
-   dificuldade de encontrar o item atribuído.

## Pergunta principal

> **"O que está comigo e o que preciso atualizar?"**

## Funcionalidades mais importantes

``` text
My Assignments / My Day
Actions
Deliverables
Documents / Evidence
Notifications
```

## Valor esperado

Poucos passos, contexto suficiente e nenhuma exposição desnecessária ao
restante do projeto.

------------------------------------------------------------------------

# 10. Persona 6 --- Tenant Administrator

## Arquétipo

**Nome fictício:** Juliana\
**Função:** administradora da organização no PMO Control\
**Frequência:** eventual

## Objetivo principal

> **Configurar o ambiente corporativo com segurança e controle.**

## Responsabilidades

-   usuários;
-   memberships;
-   Roles;
-   Scopes;
-   parâmetros;
-   taxonomias;
-   integrações;
-   configurações;
-   AI/BYOK;
-   políticas permitidas.

## Perguntas frequentes

-   Quem possui acesso?
-   Qual Role este usuário possui?
-   A quais Projects/Portfolios?
-   Qual integração está ativa?
-   Qual provider de IA está configurado?
-   Como revogar acesso?

## Funcionalidades mais importantes

``` text
Settings
Users
Access Management
Integrations
AI Configuration
Audit
```

## Momento de sucesso

Juliana consegue administrar o Tenant sem precisar de intervenção da
equipe da plataforma para operações normais.

------------------------------------------------------------------------

# 11. Persona 7 --- Viewer / Stakeholder

## Arquétipo

**Nome fictício:** André\
**Função:** stakeholder de negócio\
**Frequência:** eventual

## Objetivo principal

> **Consultar o estado das iniciativas relevantes sem operar a
> governança.**

## Necessidades

-   progresso;
-   próximos marcos;
-   Status;
-   riscos autorizados;
-   decisões;
-   documentos autorizados.

## Pergunta principal

> **"Como está a iniciativa que impacta minha área?"**

## Valor esperado

Consulta simples e confiável sem necessidade de solicitar relatório ao
PMO.

------------------------------------------------------------------------

# 12. Persona 8 --- Platform Administrator

## Arquétipo

**Nome fictício:** Sofia\
**Função:** operação da plataforma SaaS\
**Frequência:** conforme necessidade operacional

## Objetivo principal

> **Manter a plataforma saudável e administrar Tenants sem acessar
> indevidamente dados de negócio.**

## Responsabilidades

-   administrar Tenants;
-   planos e limites futuros;
-   acompanhar saúde;
-   suporte técnico;
-   configuração global;
-   operação da plataforma.

## Restrição central

Sofia não recebe acesso automático aos dados operacionais dos clientes.

Support Access excepcional deve ser autorizado e auditado.

------------------------------------------------------------------------

# 13. Persona × objetivo

  Persona           Objetivo predominante
  ----------------- -------------------------------------------------
  PMO Analyst       Governar exceções e manter informação confiável
  PMO Lead          Governar o portfólio e padronizar processos
  Project Manager   Executar e reportar sem duplicação
  Executive         Entender impacto e decidir
  Contributor       Atualizar assignments
  Tenant Admin      Administrar organização e acesso
  Viewer            Consultar
  Platform Admin    Operar SaaS

------------------------------------------------------------------------

# 14. Persona × horizonte

  Persona           Horizonte predominante
  ----------------- ---------------------------
  Contributor       Hoje
  Project Manager   Hoje / semana / milestone
  PMO Analyst       Hoje / semana
  PMO Lead          Semana / mês / portfolio
  Executive         Comitê / mês / estratégia
  Tenant Admin      Configuração / governança
  Viewer            Sob demanda
  Platform Admin    Operação da plataforma

------------------------------------------------------------------------

# 15. Persona × nível de detalhe

``` text
Contributor
    ↓
Task / Item

Project Manager
    ↓
Project

PMO Analyst
    ↓
Project + Exceptions

PMO Lead
    ↓
Portfolio + Governance

Executive
    ↓
Impact + Decision
```

A UI deve refletir essa diferença.

------------------------------------------------------------------------

# 16. Persona × perguntas

## Contributor

> O que preciso fazer?

## Project Manager

> Como está meu projeto e o que preciso atualizar?

## PMO Analyst

> Onde preciso agir?

## PMO Lead

> Onde a governança precisa de intervenção?

## Executive

> O que preciso saber e decidir?

Essa progressão deve orientar dashboards, navegação e Copilot.

------------------------------------------------------------------------

# 17. Jobs to Be Done --- PMO Analyst

### JTBD-01

Quando começo meu dia, quero visualizar exceções consolidadas para
priorizar meu trabalho sem abrir projeto por projeto.

### JTBD-02

Quando uma reunião de Status começa, quero acessar os dados atuais do
projeto para atualizar diretamente a fonte correta.

### JTBD-03

Quando preparo um comitê, quero saber o que mudou desde a última
publicação para focar apenas no que é relevante.

### JTBD-04

Quando um item está atrasado, quero identificar owner, impacto e
contexto para realizar follow-up.

------------------------------------------------------------------------

# 18. Jobs to Be Done --- PMO Lead

### JTBD-05

Quando reviso o Portfolio, quero identificar rapidamente projetos
deteriorando para direcionar intervenção.

### JTBD-06

Quando recebo um Status, quero saber se os dados estão completos e
coerentes antes da publicação.

### JTBD-07

Quando preparo liderança, quero consolidar os principais riscos,
decisões e próximos marcos sem reconstruir informação manualmente.

------------------------------------------------------------------------

# 19. Jobs to Be Done --- Project Manager

### JTBD-08

Quando atualizo meu projeto, quero registrar progresso uma única vez
para evitar controles duplicados.

### JTBD-09

Antes do fechamento do Status, quero saber exatamente quais informações
estão faltando.

### JTBD-10

Quando meu Forecast muda, quero registrar a nova previsão sem apagar a
Baseline original.

------------------------------------------------------------------------

# 20. Jobs to Be Done --- Executive

### JTBD-11

Quando entro em um comitê, quero ver apenas as exceções relevantes para
decidir rapidamente.

### JTBD-12

Quando um projeto está Red, quero entender a causa e o impacto sem
navegar por dezenas de telas.

### JTBD-13

Quando uma decisão depende de mim, quero receber contexto, impacto da
não decisão e evidências.

### JTBD-14

Quando questiono uma tendência, quero comparar o estado atual com Status
anteriores.

------------------------------------------------------------------------

# 21. Jobs to Be Done --- Contributor

### JTBD-15

Quando uma Action é atribuída a mim, quero entender claramente o que
preciso entregar e até quando.

### JTBD-16

Quando concluo uma entrega, quero registrar progresso/evidência
rapidamente.

------------------------------------------------------------------------

# 22. Jobs to Be Done --- Tenant Admin

### JTBD-17

Quando uma pessoa entra ou muda de responsabilidade, quero ajustar seu
acesso com segurança.

### JTBD-18

Quando configuro IA, quero associar credenciais e políticas somente ao
meu Tenant.

------------------------------------------------------------------------

# 23. Contextos de uso

## Operação diária

Principalmente:

``` text
PMO Analyst
Project Manager
Contributor
```

## Fechamento de Status

Principalmente:

``` text
Project Manager
PMO Analyst
PMO Lead
```

## Comitê

Principalmente:

``` text
PMO Lead
PMO Analyst
Executive
```

## Administração

Principalmente:

``` text
Tenant Admin
Platform Admin
```

------------------------------------------------------------------------

# 24. Necessidade de informação por persona

## PMO Analyst

Precisa de informação detalhada + priorização.

## PMO Lead

Precisa de agregação + qualidade + exceções.

## Project Manager

Precisa de execução + obrigações de reporting.

## Executive

Precisa de síntese + impacto + decisão.

## Contributor

Precisa apenas do contexto necessário à sua responsabilidade.

------------------------------------------------------------------------

# 25. Necessidade de IA por persona

## PMO Analyst

Alta.

Casos:

-   resumo;
-   mudança;
-   priorização;
-   preparação de reunião;
-   follow-up;
-   análise de risco.

## PMO Lead

Alta.

Casos:

-   padrões;
-   deterioração;
-   portfolio insights;
-   resumo executivo;
-   preparação de comitê.

## Project Manager

Média/Alta.

Casos:

-   preparar Status;
-   resumir mudanças;
-   identificar inconsistências;
-   sugerir riscos.

## Executive

Média.

Casos:

-   perguntas executivas;
-   explicação;
-   comparação;
-   cenários futuros.

## Contributor

Baixa/Média.

Casos:

-   contexto;
-   resumo de assignment;
-   apoio pontual.

------------------------------------------------------------------------

# 26. Expectativa de velocidade

## PMO Analyst

Alta frequência → baixa tolerância a fricção.

## Project Manager

Atualizações recorrentes → formulários devem ser eficientes.

## Executive

Baixa frequência, alto impacto → informação deve ser imediatamente
compreensível.

## Contributor

Interação simples → poucos passos.

------------------------------------------------------------------------

# 27. Expectativa de densidade visual

``` text
Contributor       → baixa
Project Manager   → média
PMO Analyst       → média/alta
PMO Lead          → média/alta
Executive         → baixa/média
```

O Executive View deve reduzir densidade apesar de trabalhar com dados
agregados.

------------------------------------------------------------------------

# 28. Necessidades de confiança

Todas as personas precisam confiar nos dados, mas por razões diferentes.

### Project Manager

> "O sistema representou corretamente o que informei?"

### PMO

> "A informação está atualizada e validada?"

### Executive

> "Posso tomar uma decisão com base nisso?"

### Tenant Admin

> "Somente pessoas autorizadas conseguem acessar?"

------------------------------------------------------------------------

# 29. Fricções que o produto deve evitar

## PMO

-   abrir projeto por projeto;
-   copiar dados para apresentação;
-   recalcular KPI manualmente;
-   procurar owner;
-   comparar planilhas.

## Project Manager

-   preencher a mesma informação em vários lugares;
-   Status report separado da execução;
-   campos sem propósito claro.

## Executive

-   excesso de gráficos;
-   detalhes operacionais sem impacto;
-   RAG sem explicação;
-   apresentações inconsistentes.

## Contributor

-   navegar pelo projeto inteiro para atualizar uma Action.

------------------------------------------------------------------------

# 30. Anti-persona --- Usuário que quer apenas Task Management

Uma equipe que busca somente:

-   backlog;
-   sprint;
-   story;
-   task board;
-   desenvolvimento ágil;

pode ser melhor atendida por ferramentas especializadas.

PMO Control pode integrar essas fontes, mas não deve tentar substituir
todo o ecossistema de execução.

------------------------------------------------------------------------

# 31. Anti-persona --- Usuário que busca ERP financeiro

O módulo Financial existe para governança de projetos.

Não é objetivo inicial cobrir:

-   contabilidade;
-   fiscal;
-   contas a pagar;
-   faturamento;
-   folha.

------------------------------------------------------------------------

# 32. Anti-persona --- Usuário que busca BI genérico

PMO Control possui dashboards e Reports, mas seu diferencial está no
domínio operacional e governança.

Não deve competir como ferramenta universal de BI.

------------------------------------------------------------------------

# 33. Permissões e personas

Persona não concede acesso.

Exemplo:

``` text
Persona: Executive
```

não é suficiente para acessar qualquer Portfolio.

O acesso continua dependendo de:

``` text
Tenant
Role
Scope
Permission
Data Policy
Workflow Rule
```

------------------------------------------------------------------------

# 34. Personas acumuladas

Uma pessoa pode exercer múltiplas funções.

Exemplo:

``` text
Small Organization

User:
PMO Lead
+
Tenant Admin
```

Outro exemplo:

``` text
Project Sponsor

Executive
+
Decision Maker
```

A experiência deve funcionar sem pressupor que cada pessoa tenha apenas
um papel organizacional.

------------------------------------------------------------------------

# 35. Persona primária por tela

  Tela                     Persona primária
  ------------------------ ---------------------------
  Login                    Todas
  My Day                   PMO Analyst
  Executive Portfolio      Executive / PMO Lead
  Portfolio                PMO Lead / PMO Analyst
  Project Control Center   PM / PMO
  Schedule                 PM / PMO
  Milestones               PM / PMO
  Deliverables             PM / PMO
  Risks                    PM / PMO
  Issues                   PM / PMO
  Actions                  PMO / PM / Contributor
  Decisions                Executive / PMO / PM
  Financial                PMO Lead / PM / Executive
  Team                     PM / PMO
  Resources                PMO / PMO Lead
  Documents                PM / PMO
  Status Update            PM / PMO
  Time Machine             PMO / Executive
  Report Builder           PMO
  PMO Copilot              PMO / PM / Executive
  Settings                 Tenant Admin

------------------------------------------------------------------------

# 36. Persona primária não significa exclusividade

A definição de persona primária serve para orientar UX.

Exemplo:

`Risks` pode ser usado por:

-   PM;
-   PMO;
-   PMO Lead;
-   Executive;
-   Contributor autorizado.

Porém, o desenho operacional deve priorizar quem trabalha diretamente
com o risco.

------------------------------------------------------------------------

# 37. Executive Mode

O produto deve considerar experiência executiva distinta.

Características:

-   menos controles;
-   menos edição;
-   mais síntese;
-   mais impacto;
-   mais tendência;
-   decisões pendentes em destaque;
-   drill-down opcional.

------------------------------------------------------------------------

# 38. PMO Mode

Características:

-   alta capacidade de filtragem;
-   exceções;
-   follow-up;
-   contexto;
-   edição;
-   múltiplos projetos;
-   ações rápidas;
-   histórico;
-   relatórios.

------------------------------------------------------------------------

# 39. Project Manager Mode

Características:

-   foco no Project;
-   progresso;
-   Forecast;
-   próximos Milestones;
-   Risks/Issues;
-   Actions;
-   Status readiness;
-   evidências.

------------------------------------------------------------------------

# 40. Contributor Mode

Características:

-   assignments;
-   due dates;
-   atualização rápida;
-   anexos;
-   contexto mínimo necessário.

------------------------------------------------------------------------

# 41. Necessidade de notificações

## PMO

-   Status atrasado;
-   Action vencida;
-   Risk crítico;
-   Issue crítico;
-   Decision pendente;
-   Milestone ameaçado.

## Project Manager

-   prazo;
-   Status a preparar;
-   Action;
-   Risk review;
-   milestone.

## Executive

Somente eventos relevantes:

-   decisão atribuída;
-   escalonamento crítico;
-   evento executivo configurado.

## Contributor

-   assignment;
-   due date;
-   comentário/solicitação relevante.

------------------------------------------------------------------------

# 42. Critério de sucesso por persona

## PMO Analyst

Menor tempo de consolidação e maior capacidade de atuar em exceções.

## PMO Lead

Maior consistência e confiabilidade da governança.

## Project Manager

Menos reporting duplicado.

## Executive

Menor tempo para compreender e decidir.

## Contributor

Menor esforço para manter assignments atualizados.

## Tenant Admin

Administração segura sem dependência operacional do fornecedor.

------------------------------------------------------------------------

# 43. Métricas candidatas por persona

Essas métricas serão formalizadas em `success-metrics.md`.

### PMO

-   tempo para preparar Status;
-   tempo para preparar comitê;
-   percentual de projetos atualizados;
-   ações vencidas;
-   decisões pendentes.

### Project Manager

-   tempo de atualização;
-   completude do Status;
-   atraso de atualização.

### Executive

-   tempo até decisão;
-   decisões vencidas;
-   decisões com contexto/evidência suficiente.

### Tenant Admin

-   tempo para provisionar/revogar acesso;
-   incidentes de autorização.

------------------------------------------------------------------------

# 44. Persona prioritária no MVP

Prioridade sugerida:

``` text
1. PMO Analyst
2. Project Manager
3. PMO Lead
4. Executive
5. Contributor
6. Tenant Admin
7. Viewer
8. Platform Admin
```

Isso representa prioridade de experiência de produto, não importância de
segurança.

Multi-tenancy e administração continuam sendo requisitos fundamentais
desde o início.

------------------------------------------------------------------------

# 45. Regra para novas funcionalidades

Toda nova feature deve declarar pelo menos:

``` text
Primary Persona
Secondary Personas
Problem
Job to Be Done
Expected Outcome
```

Uma feature sem persona/problema claro deve ser questionada antes de
entrar no roadmap.

------------------------------------------------------------------------

# 46. Relação com User Journeys

Este documento identifica **quem** utiliza o PMO Control.

`user-journeys.md` definirá **como essas personas percorrem os
principais fluxos ponta a ponta**.

Exemplo:

``` text
Project Manager updates project
        ↓
PMO reviews
        ↓
Status published
        ↓
Snapshot generated
        ↓
Executive consumes
        ↓
Decision created
        ↓
Action assigned
```

------------------------------------------------------------------------

# 47. Relação com Permission Model

Personas orientam experiência.

Permission Model controla acesso.

Nunca implementar autorização diretamente com base em persona descrita
neste documento.

------------------------------------------------------------------------

# 48. Relação com PMO Copilot

O Copilot deve adaptar profundidade e forma da resposta ao contexto de
uso.

Exemplo:

### PMO Analyst

> Mostre os projetos sem Status e os riscos críticos.

### Executive

> Resuma os três projetos que mais exigem minha atenção e quais decisões
> dependem de mim.

Mesmo domínio, experiências diferentes.

------------------------------------------------------------------------

# 49. Invariantes

1.  Persona não substitui Role.
2.  Role não representa sozinho necessidade do usuário.
3.  PMO Analyst é persona operacional central.
4.  Executive precisa de síntese, não réplica da operação.
5.  Project Manager deve evitar reporting duplicado.
6.  Contributor deve ter interação simples e restrita.
7.  Tenant Admin administra o Tenant sem acesso automático irrestrito ao
    negócio.
8.  Platform Admin não recebe acesso automático aos dados dos clientes.
9.  Copilot respeita autorização independentemente da persona.
10. Features devem possuir persona e problema claros.

------------------------------------------------------------------------

# 50. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/00-foundation/glossary.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`

------------------------------------------------------------------------

# 51. Status

**Documento:** Personas\
**Status:** Under Review\
**Responsabilidade:** definir os principais perfis de uso, objetivos,
dores, Jobs to Be Done e expectativas que orientarão as jornadas e
experiências do PMO Control.
