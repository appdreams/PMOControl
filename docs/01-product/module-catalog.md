# PMO Control --- Module Catalog

**Documento:** `module-catalog.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Catálogo funcional de módulos

------------------------------------------------------------------------

## 1. Objetivo

Este documento estabelece o catálogo oficial dos módulos do PMO Control.

Para cada módulo, registra de forma padronizada:

-   propósito;
-   personas principais;
-   responsabilidades;
-   principais entradas;
-   principais saídas;
-   entidades relacionadas;
-   dependências;
-   regras essenciais;
-   Specification associada;
-   referências visuais quando existentes.

O catálogo não substitui as Specifications. Ele define a
responsabilidade funcional de cada módulo e ajuda a evitar sobreposição,
duplicação e lacunas.

------------------------------------------------------------------------

# 2. Princípios de modularização

## 2.1 Um módulo deve possuir responsabilidade clara

Evitar módulos genéricos que concentrem regras de vários domínios.

## 2.2 Tela não é automaticamente módulo

`Executive Portfolio`, por exemplo, é uma experiência/projeção
construída sobre capacidades existentes.

## 2.3 Módulo não precisa possuir tela

`RAG Engine` e `Snapshots` são exemplos.

## 2.4 Entidades operacionais permanecem fontes

Dashboards, Reports e My Day não devem criar versões independentes dos
mesmos fatos.

## 2.5 Dependências devem ser explícitas

Um módulo pode consumir outro, mas isso deve ser conhecido para orientar
Specs, arquitetura e testes.

------------------------------------------------------------------------

# 3. Classificação dos módulos

``` text
A. Platform & Access
B. Portfolio & Project
C. Execution Governance
D. Status & History
E. Management & Knowledge
F. Intelligence & Reporting
G. Cross-cutting
```

------------------------------------------------------------------------

# 4. Módulo 001 --- Authentication

**Spec:** `/docs/04-specs/001-authentication/`

**Propósito:** autenticar usuários e estabelecer sessão segura.

**Personas:** todas.

**Responsabilidades:**

-   login;
-   logout;
-   convite/ativação;
-   recuperação de acesso;
-   gerenciamento de sessão;
-   revogação;
-   futura extensão para MFA/SSO.

**Entradas:**

-   credenciais;
-   invitation token;
-   recovery token;
-   contexto de autenticação.

**Saídas:**

-   identidade autenticada;
-   sessão;
-   eventos de segurança.

**Dependências:**

``` text
Multi-tenancy
RBAC
Audit
Notifications
```

**Regras essenciais:**

-   autenticação não implica autorização;
-   sessão revogada não deve continuar concedendo acesso;
-   eventos sensíveis devem ser auditáveis;
-   mensagens não devem expor detalhes desnecessários de segurança.

**UX:** `05-ux/screens/login/login-main-reference.png`

------------------------------------------------------------------------

# 5. Módulo 002 --- Multi-tenancy

**Spec:** `/docs/04-specs/002-multi-tenancy/`

**Propósito:** isolar organizações e estabelecer o contexto de Tenant.

**Personas:** Tenant Admin, Platform Admin e transversalmente todos os
usuários.

**Responsabilidades:**

-   Tenant;
-   Membership;
-   isolamento;
-   contexto ativo;
-   associação segura de dados;
-   configurações por organização.

**Entradas:**

-   usuário;
-   Membership;
-   Tenant;
-   contexto de requisição.

**Saídas:**

-   contexto tenant-scoped;
-   fronteira de dados.

**Dependências:**

``` text
Authentication
RBAC
Audit
```

**Regras essenciais:**

-   deny cross-tenant by default;
-   `tenant_id` do cliente não é autoridade;
-   toda consulta tenant-scoped deve preservar isolamento;
-   testes cross-tenant são obrigatórios.

------------------------------------------------------------------------

# 6. Módulo 003 --- RBAC

**Spec:** `/docs/04-specs/003-rbac/`

**Propósito:** controlar o que cada usuário pode fazer e em qual escopo.

**Personas:** Tenant Admin, PMO Admin e todos como sujeitos de
autorização.

**Responsabilidades:**

-   Roles;
-   Scopes;
-   Permissions;
-   Data Policies;
-   Workflow Rules;
-   grants;
-   revocations;
-   segregation of duties.

**Modelo:**

``` text
Effective Access =
Tenant + Role + Scope + Permission + Data Policy + Workflow Rule
```

**Saídas:**

-   allow;
-   deny;
-   obligations/restrictions quando aplicável.

**Dependências:**

``` text
Authentication
Multi-tenancy
Audit
```

**Regra:** frontend hiding nunca substitui autorização no backend.

------------------------------------------------------------------------

# 7. Módulo 004 --- Portfolios

**Spec:** `/docs/04-specs/004-portfolios/`

**Propósito:** organizar e governar conjuntos de Projects.

**Personas:** PMO Lead, PMO Analyst, Executive.

**Responsabilidades:**

-   criar Portfolio;
-   associar Projects;
-   ownership;
-   filtros;
-   consolidação;
-   saúde;
-   priorização;
-   navegação cross-project.

**Entradas:**

-   Projects;
-   Status;
-   RAG;
-   Risks;
-   Milestones;
-   Financial;
-   Decisions.

**Saídas:**

-   visão consolidada;
-   exceções;
-   indicadores;
-   contexto executivo.

**UX:**

-   `05-ux/screens/portfolio/portfolio-main-reference.png`
-   `05-ux/screens/executive-portfolio/executive-portfolio-main-reference.png`

------------------------------------------------------------------------

# 8. Módulo 005 --- Projects

**Spec:** `/docs/04-specs/005-projects/`

**Propósito:** representar e governar a unidade central de execução.

**Personas:** PM, PMO, PMO Lead.

**Responsabilidades:**

-   criar/configurar Project;
-   Portfolio association;
-   lifecycle;
-   ownership;
-   datas principais;
-   Baseline/Forecast em conjunto com capacidades relacionadas;
-   arquivamento.

**Estados conceituais:**

``` text
planning
execution
paused
completed
cancelled
```

**Entidades relacionadas:**

Todos os principais domínios operacionais do projeto.

**Regra:** Project não deve se tornar uma tabela gigante contendo todas
as informações do domínio.

------------------------------------------------------------------------

# 9. Módulo 006 --- Project Control Center

**Spec:** `/docs/04-specs/006-project-control-center/`

**Propósito:** oferecer visão operacional integrada de um Project.

**Personas:** PM e PMO.

**Tipo:** composição.

**Responsabilidades:**

-   overview;
-   navegação;
-   KPIs;
-   atalhos;
-   exceções;
-   acesso aos módulos do Project.

**Entradas:** dados dos módulos do projeto.

**Saídas:** visão consolidada operacional.

**Regra:** não é fonte paralela de dados.

**UX:** referências em `05-ux/screens/project-control-center/`.

------------------------------------------------------------------------

# 10. Módulo 007 --- Milestones

**Spec:** `/docs/04-specs/007-milestones/`

**Propósito:** governar marcos relevantes do Project.

**Personas:** PM, PMO e Executive em leitura.

**Responsabilidades:**

-   criação;
-   owner;
-   criticidade;
-   Baseline date;
-   Forecast date;
-   Actual date;
-   status;
-   ameaça;
-   relações com Deliverables/Dependencies.

**Saídas:**

-   upcoming milestones;
-   delayed milestones;
-   threatened milestones;
-   timeline.

**UX:** `05-ux/screens/milestones/`.

------------------------------------------------------------------------

# 11. Módulo 008 --- Deliverables

**Spec:** `/docs/04-specs/008-deliverables/`

**Propósito:** controlar entregas concretas do Project.

**Personas:** PM, PMO, Contributor.

**Responsabilidades:**

-   criação;
-   owner;
-   prazo;
-   progresso;
-   conclusão;
-   Evidence;
-   relação com Milestone.

**Saídas:**

-   progresso de entregas;
-   atrasos;
-   completude;
-   impacto em Milestones/Status.

**UX:** `05-ux/screens/deliverables/deliverables-main-reference.png`

------------------------------------------------------------------------

# 12. Módulo 009 --- Risks

**Spec:** `/docs/04-specs/009-risks/`

**Propósito:** governar eventos incertos que podem afetar objetivos.

**Personas:** PM, PMO, PMO Lead.

**Responsabilidades:**

-   identificação;
-   probability;
-   impact;
-   classification;
-   owner;
-   mitigation/response;
-   monitoring;
-   escalation;
-   closure;
-   materialization.

**Saídas:**

-   risk exposure;
-   critical risks;
-   trends;
-   possible RAG impact.

**Regra:** Risk não deve ser tratado como Issue.

**UX:** `05-ux/screens/risks/risks-main-reference.png`

------------------------------------------------------------------------

# 13. Módulo 010 --- Issues

**Spec:** `/docs/04-specs/010-issues/`

**Propósito:** governar problemas que já existem.

**Personas:** PM, PMO, PMO Lead.

**Responsabilidades:**

-   registro;
-   severity;
-   impact;
-   owner;
-   resolution plan;
-   escalation;
-   closure;
-   link com Risk materializado.

**Saídas:**

-   blocking issues;
-   aging;
-   critical issues;
-   resolution status.

**UX:** `05-ux/screens/issues/issues-main-reference.png`

------------------------------------------------------------------------

# 14. Módulo 011 --- Actions

**Spec:** `/docs/04-specs/011-actions/`

**Propósito:** controlar compromissos de execução decorrentes da
governança.

**Personas:** PMO, PM, Contributor.

**Responsabilidades:**

-   criação;
-   owner;
-   due date;
-   status;
-   follow-up;
-   overdue detection;
-   completion;
-   origem.

**Possíveis origens:**

``` text
Risk
Issue
Decision
Meeting
Status
Milestone
Manual
```

**Saídas:**

-   overdue;
-   due soon;
-   completed;
-   owner workload.

**UX:** `05-ux/screens/actions/actions-main-reference.png`

------------------------------------------------------------------------

# 15. Módulo 012 --- Decisions

**Spec:** `/docs/04-specs/012-decisions/`

**Propósito:** transformar decisões de governança em registros
estruturados e rastreáveis.

**Personas:** Executive, PMO, PM.

**Responsabilidades:**

-   request;
-   context;
-   options;
-   impact;
-   impact of no decision;
-   deadline;
-   evidence;
-   decision maker;
-   approve/reject/defer;
-   comments;
-   Actions derivadas.

**Saídas:**

-   pending decisions;
-   decided items;
-   decision aging;
-   downstream Actions.

**UX:** `05-ux/screens/decisions/decisions-main-reference.png`

------------------------------------------------------------------------

# 16. Módulo 013 --- Dependencies

**Spec:** `/docs/04-specs/013-dependencies/`

**Propósito:** explicitar dependências que podem afetar execução.

**Personas:** PM, PMO.

**Responsabilidades:**

-   source/target;
-   type;
-   owner;
-   expected date;
-   status;
-   impact;
-   escalation.

**Relacionamentos possíveis:**

-   Project ↔ Project;
-   Milestone ↔ Deliverable;
-   Deliverable ↔ Deliverable;
-   outros definidos pela Spec.

**Saídas:** dependências críticas e ameaçadas.

------------------------------------------------------------------------

# 17. Módulo 014 --- Status Update

**Spec:** `/docs/04-specs/014-status-update/`

**Propósito:** realizar checkpoint periódico de governança do Project.

**Personas:** PM, PMO, PMO Lead.

**Responsabilidades:**

-   criar Draft;
-   carregar estado atual;
-   comparar com última publicação;
-   revisar cinco etapas;
-   validar;
-   submeter;
-   revisar;
-   publicar.

**Entradas:** entidades operacionais.

**Saídas:**

-   Status publicado;
-   Snapshot;
-   indicadores consolidados;
-   atualização de projeções.

**UX:** `05-ux/screens/status-update/`.

------------------------------------------------------------------------

# 18. Módulo 015 --- RAG Engine

**Spec:** `/docs/04-specs/015-rag-engine/`

**Propósito:** calcular/recomendar e explicar a saúde do Project.

**Personas:** PMO, PMO Lead, PM e Executive em consumo.

**Tipo:** capability sem necessidade de tela própria.

**Responsabilidades:**

-   regras;
-   thresholds;
-   calculation;
-   explanation;
-   override;
-   justification;
-   calculated/effective RAG.

**Saídas:**

``` text
green
amber
red
```

**Regra:** override requer autorização e auditabilidade.

------------------------------------------------------------------------

# 19. Módulo 016 --- Snapshots

**Spec:** `/docs/04-specs/016-snapshots/`

**Propósito:** preservar o estado publicado do Project em um ponto no
tempo.

**Personas:** indiretas; PMO e Executive consomem o resultado.

**Responsabilidades:**

-   criação na publicação;
-   imutabilidade;
-   versionamento temporal;
-   consulta;
-   comparação.

**Consumidores:**

``` text
Time Machine
Dashboards
Reports
Copilot
Historical Analysis
```

------------------------------------------------------------------------

# 20. Módulo 017 --- My Day

**Spec:** `/docs/04-specs/017-my-day/`

**Propósito:** transformar múltiplos projetos em uma fila priorizada de
atenção.

**Persona principal:** PMO Analyst.

**Tipo:** projeção.

**Responsabilidades:**

-   overdue Actions;
-   critical Risks;
-   critical Issues;
-   missing Status;
-   pending Decisions;
-   upcoming Milestones;
-   Dependencies;
-   Resource conflicts.

**Entradas:** múltiplas entidades.

**Saída:** prioridades operacionais.

**UX:** `05-ux/screens/my-day/my-day-main-reference.png`

------------------------------------------------------------------------

# 21. Módulo 018 --- Project Dashboard

**Spec:** `/docs/04-specs/018-project-dashboard/`

**Propósito:** apresentar visão gerencial/executiva de um Project.

**Personas:** PMO, PM, Executive.

**Tipo:** projeção.

**Responsabilidades:**

-   health;
-   progress;
-   schedule;
-   financial;
-   milestones;
-   risks;
-   issues;
-   actions;
-   decisions;
-   trends.

**Regra:** dados vêm das fontes operacionais e/ou Snapshot conforme
contexto.

------------------------------------------------------------------------

# 22. Módulo 019 --- Portfolio Dashboard

**Spec:** `/docs/04-specs/019-portfolio-dashboard/`

**Propósito:** consolidar visão executiva e gerencial do Portfolio.

**Personas:** PMO Lead, Executive, PMO.

**Tipo:** projeção.

**Responsabilidades:**

-   health distribution;
-   critical Projects;
-   trends;
-   investments;
-   Risks;
-   Milestones;
-   Decisions;
-   exceptions.

**UX:** relacionada a Portfolio e Executive Portfolio.

------------------------------------------------------------------------

# 23. Módulo 020 --- Financial

**Spec:** `/docs/04-specs/020-financial/`

**Propósito:** fornecer governança financeira do Project.

**Personas:** PM, PMO, PMO Lead, Executive autorizado.

**Responsabilidades:**

-   Budget;
-   Actual;
-   Forecast;
-   Variance;
-   trend;
-   thresholds;
-   consolidation.

**Regra:** não é ERP financeiro.

**Segurança:** requer permissões/Data Policies específicas.

**UX:** `05-ux/screens/financial/financial-main-reference.png`

------------------------------------------------------------------------

# 24. Módulo 021 --- Resources

**Spec:** `/docs/04-specs/021-resources/`

**Propósito:** acompanhar recursos, capacidade e alocação relacionadas a
Projects.

**Personas:** PMO, PMO Lead, PM autorizado.

**Responsabilidades:**

-   Resource;
-   Allocation;
-   Capacity;
-   utilization;
-   overallocation;
-   conflicts.

**Regra:** não é HRIS.

**UX:** `05-ux/screens/resources/`.

------------------------------------------------------------------------

# 25. Módulo 022 --- Documents

**Spec:** `/docs/04-specs/022-documents/`

**Propósito:** organizar documentos e evidências relacionados à
governança.

**Personas:** PM, PMO, Contributor autorizado.

**Responsabilidades:**

-   upload/reference;
-   metadata;
-   classification;
-   association;
-   access;
-   Evidence.

**Regra:** documentos confidenciais respeitam Data Policy específica.

**UX:** `05-ux/screens/documents/documents-main-reference.png`

------------------------------------------------------------------------

# 26. Módulo 023 --- Time Machine

**Spec:** `/docs/04-specs/023-time-machine/`

**Propósito:** permitir análise temporal da evolução do Project.

**Personas:** PMO, PMO Lead, Executive.

**Tipo:** projeção histórica.

**Responsabilidades:**

-   selecionar Snapshot;
-   visualizar estado histórico;
-   comparar períodos;
-   destacar mudanças;
-   apoiar investigação.

**Dependência crítica:** Snapshots.

**UX:** `05-ux/screens/time-machine/time-machine-main-reference.png`

------------------------------------------------------------------------

# 27. Módulo 024 --- Report Builder

**Spec:** `/docs/04-specs/024-report-builder/`

**Propósito:** gerar materiais de governança a partir dos dados do
sistema.

**Persona principal:** PMO.

**Responsabilidades:**

-   escolher contexto;
-   escolher seções;
-   selecionar current/snapshot;
-   montar report;
-   AI summary;
-   revisar;
-   exportar.

**Regra:** View permission não implica automaticamente Export
permission.

**UX:** `05-ux/screens/report-builder/report-builder-main-reference.png`

------------------------------------------------------------------------

# 28. Módulo 025 --- PMO Copilot

**Spec:** `/docs/04-specs/025-pmo-copilot/`

**Propósito:** fornecer inteligência contextual sobre Projects e
Portfolios.

**Personas:** PMO, PMO Lead, PM, Executive.

**Responsabilidades:**

-   Q&A;
-   summaries;
-   change analysis;
-   prioritization;
-   explanations;
-   recommendations;
-   committee preparation;
-   Status support;
-   future scenarios.

**Entradas:**

``` text
Authorized Domain Data
Snapshots
Documents/Evidence
User Context
Tenant AI Policy
```

**Regras:**

-   não ampliar acesso;
-   respeitar classificação;
-   diferenciar fact/inference/recommendation;
-   ações consequenciais exigem confirmação e nova autorização.

**UX:** `05-ux/screens/pmo-copilot/pmo-copilot-main-reference.png`

------------------------------------------------------------------------

# 29. Módulo 026 --- Notifications

**Spec:** `/docs/04-specs/026-notifications/`

**Propósito:** levar eventos relevantes ao usuário no momento adequado.

**Personas:** todas conforme contexto.

**Responsabilidades:**

-   assignment;
-   deadline;
-   reminder;
-   escalation;
-   Status;
-   Decision;
-   critical event;
-   preferences.

**Canais:** in-app e e-mail inicialmente conforme escopo final.

**Regra:** conteúdo deve respeitar classificação e autorização.

------------------------------------------------------------------------

# 30. Módulo 027 --- Audit Log

**Spec:** `/docs/04-specs/027-audit-log/`

**Propósito:** preservar rastreabilidade de eventos relevantes.

**Personas:** administradores e usuários explicitamente autorizados.

**Responsabilidades:**

-   actor;
-   action;
-   timestamp;
-   resource;
-   before/after quando aplicável;
-   reason;
-   correlation.

**Eventos sensíveis incluem:**

-   access changes;
-   baseline;
-   budget;
-   RAG override;
-   publication;
-   executive decision;
-   sensitive export;
-   exceptional support access.

**Regra:** usuário comum não altera Audit Log.

------------------------------------------------------------------------

# 31. Módulo 028 --- Import / Export

**Spec:** `/docs/04-specs/028-import-export/`

**Propósito:** mover dados de forma controlada para dentro e para fora
do sistema.

**Personas:** PMO Admin, Tenant Admin e outros explicitamente
autorizados.

**Responsabilidades:**

-   upload/source;
-   validation;
-   mapping;
-   preview;
-   import;
-   error summary;
-   export.

**Regras:**

-   Tenant binding;
-   autorização;
-   classificação;
-   audit;
-   idempotência quando aplicável.

------------------------------------------------------------------------

# 32. Módulo 029 --- Settings

**Spec:** `/docs/04-specs/029-settings/`

**Propósito:** administrar configurações permitidas do Tenant.

**Persona principal:** Tenant Admin.

**Responsabilidades:**

-   users/access entry points;
-   taxonomies;
-   RAG configuration;
-   AI/BYOK;
-   integrations;
-   notification settings;
-   governance parameters;
-   futuras customizações.

**Regra:** configuração não pode desabilitar invariantes fundamentais de
segurança.

**UX:** `05-ux/screens/settings/settings-main-reference.png`

------------------------------------------------------------------------

# 33. Capability complementar --- Schedule

Schedule aparece como experiência importante do Project, embora não
possua uma Spec numerada própria no catálogo inicial.

**Responsabilidades:**

-   timeline;
-   planned dates;
-   Baseline;
-   Forecast;
-   Actual;
-   schedule variance;
-   relações temporais.

Sua responsabilidade detalhada deve ser incorporada às Specs adequadas
ou promovida a Spec própria caso a complexidade justifique.

**UX:** `05-ux/screens/schedule/schedule-main-reference.png`

------------------------------------------------------------------------

# 34. Capability complementar --- Team

Team é uma visão das pessoas e responsabilidades do Project.

**Responsabilidades:**

-   project members;
-   responsibilities;
-   owners;
-   roles no contexto do Project.

Não substitui Resources/Capacity nem RBAC.

**UX:** `05-ux/screens/resources/team-main-reference.png`

------------------------------------------------------------------------

# 35. Capability complementar --- Evidence

Evidence conecta uma fonte comprobatória a um objeto de governança.

Exemplos:

``` text
Decision → Evidence
Risk → Evidence
Deliverable → Evidence
Baseline Change → Evidence
Status → Evidence
```

Sua modelagem detalhada será definida nas Specs/Data.

------------------------------------------------------------------------

# 36. Capability complementar --- Baseline Management

Baseline é transversal a Project/Schedule e governança.

Fluxo conceitual:

``` text
Change Request
      ↓
Reason / Impact / Evidence
      ↓
Approval
      ↓
New Baseline Version
      ↓
Audit
```

Caso sua complexidade cresça, poderá justificar Spec dedicada.

------------------------------------------------------------------------

# 37. Capability complementar --- Executive Portfolio

É uma experiência especializada construída principalmente sobre:

``` text
Portfolios
Projects
Status
RAG
Financial
Risks
Milestones
Decisions
```

Não deve criar domínio paralelo.

**UX:**
`05-ux/screens/executive-portfolio/executive-portfolio-main-reference.png`

------------------------------------------------------------------------

# 38. Módulos fonte

Módulos predominantemente fonte de dados:

``` text
Projects
Milestones
Deliverables
Risks
Issues
Actions
Decisions
Dependencies
Financial
Resources
Documents
Status Update
Settings
```

------------------------------------------------------------------------

# 39. Módulos de projeção/composição

``` text
Project Control Center
My Day
Project Dashboard
Portfolio Dashboard
Executive Portfolio
Time Machine
Report Builder
PMO Copilot
```

Esses módulos devem consumir fontes autorizadas.

------------------------------------------------------------------------

# 40. Módulos de infraestrutura funcional

``` text
Authentication
Multi-tenancy
RBAC
Notifications
Audit
Import/Export
Settings
```

São necessários para funcionamento seguro e governado da plataforma.

------------------------------------------------------------------------

# 41. Dependências críticas

``` text
Authentication
      ↓
Multi-tenancy
      ↓
RBAC
      ↓
Projects
      ↓
Operational Modules
      ↓
Status
      ↓
RAG
      ↓
Snapshots
      ↓
Dashboards / Time Machine
      ↓
Reports / Copilot
```

Isso não representa necessariamente a ordem exata de implementação, mas
indica dependências conceituais.

------------------------------------------------------------------------

# 42. Matriz módulo × persona

  ------------------------------------------------------------------------------------
  Módulo         PMO        PMO Lead   PM         Contributor   Executive   Tenant
                                                                            Admin
  -------------- ---------- ---------- ---------- ------------- ----------- ----------
  Portfolio      ●          ●          ○          ---           ●           ○

  Project        ●          ●          ●          ○             ○           ○

  Milestones     ●          ●          ●          ○             ○           ---

  Deliverables   ●          ○          ●          ●             ○           ---

  Risks          ●          ●          ●          ○             ○           ---

  Issues         ●          ●          ●          ○             ○           ---

  Actions        ●          ●          ●          ●             ○           ---

  Decisions      ●          ●          ●          ○             ●           ---

  Status         ●          ●          ●          ○             ○           ---

  Financial      ●          ●          ●          ---           ●           ○

  Resources      ●          ●          ●          ○             ○           ○

  Documents      ●          ○          ●          ●             ○           ○

  Time Machine   ●          ●          ○          ---           ●           ---

  Reports        ●          ●          ○          ---           ●           ---

  Copilot        ●          ●          ●          ○             ●           ○

  Settings       ○          ○          ---        ---           ---         ●
  ------------------------------------------------------------------------------------

Legenda:

``` text
● uso principal/relevante
○ uso secundário ou condicionado
— normalmente não aplicável
```

A matriz não substitui autorização.

------------------------------------------------------------------------

# 43. Matriz módulo × natureza

  Módulo            Fonte   Projeção   Workflow   Histórico   IA
  --------------- ------- ---------- ---------- ----------- ----
  Projects              ●                     ●           ● 
  Milestones            ●                     ●           ● 
  Risks                 ●                     ●           ●    ○
  Issues                ●                     ●           ●    ○
  Actions               ●                     ●           ●    ○
  Decisions             ●                     ●           ●    ○
  Status Update         ●          ○          ●           ●    ○
  RAG Engine                       ●          ●           ●    ○
  Snapshots             ●                                 ● 
  My Day                           ●                           ○
  Dashboards                       ●                      ○    ○
  Time Machine                     ●                      ●    ○
  Reports                          ●                      ●    ○
  Copilot                          ●                      ●    ●

------------------------------------------------------------------------

# 44. Integração entre módulos

Módulos devem se relacionar por contratos claros.

Exemplo:

``` text
Decision
   ↓ creates
Action
```

``` text
Risk
   ↓ materializes into
Issue
```

``` text
Status Publication
   ↓ creates
Snapshot
```

``` text
Snapshot
   ↓ consumed by
Time Machine
```

Evitar dependências implícitas difíceis de rastrear.

------------------------------------------------------------------------

# 45. Eventos relevantes entre módulos

Exemplos conceituais:

``` text
ProjectCreated
MilestoneThreatened
DeliverableDelayed
RiskEscalated
RiskMaterialized
IssueResolved
ActionOverdue
DecisionMade
StatusPublished
SnapshotCreated
RAGOverridden
```

A definição técnica final será feita nas Specs/arquitetura.

------------------------------------------------------------------------

# 46. Regras para módulos derivados

Um módulo derivado MUST:

1.  consultar apenas dados autorizados;
2.  preservar semântica da fonte;
3.  não permitir alteração indireta sem workflow explícito;
4.  identificar origem quando necessário;
5.  respeitar Snapshot quando operando em contexto histórico.

------------------------------------------------------------------------

# 47. Regras para módulos de IA

Módulos que usam IA MUST:

1.  resolver autorização antes de construir contexto;
2.  aplicar Data Classification;
3.  respeitar Tenant AI Policy;
4.  minimizar dados enviados;
5.  validar output estruturado;
6.  distinguir fato/inferência/recomendação;
7.  exigir confirmação para ações consequenciais;
8.  auditar quando aplicável.

------------------------------------------------------------------------

# 48. Regras para módulos financeiros

Módulos que exibem ou manipulam Financial Data MUST verificar permissões
específicas.

Exemplos:

``` text
financial.view
financial.edit
```

Acesso ao Project não concede automaticamente acesso financeiro.

------------------------------------------------------------------------

# 49. Regras para documentos confidenciais

Documentos classificados como Confidential/Restricted devem exigir
política apropriada.

Exemplo:

``` text
documents.confidential.view
```

A existência do documento pode também exigir tratamento cuidadoso
dependendo da classificação.

------------------------------------------------------------------------

# 50. Regras para exportação

Exportação é uma capacidade distinta de visualização.

Exemplo:

``` text
report.export
```

O sistema deve evitar que um usuário contorne Data Policies por meio de
export.

------------------------------------------------------------------------

# 51. Regras para histórico

Quando a experiência é histórica, o sistema deve distinguir:

``` text
Current State
```

de:

``` text
Published Historical State
```

Não reconstruir Snapshot antigo consultando apenas entidades atuais.

------------------------------------------------------------------------

# 52. Regras para arquivamento

Módulos relacionados a Projects arquivados devem:

-   preservar histórico;
-   restringir alterações conforme regras;
-   manter acesso autorizado;
-   removê-los de views operacionais padrão quando apropriado.

------------------------------------------------------------------------

# 53. Critério para criação de novo módulo

Uma nova capacidade deve virar módulo quando possuir combinação
relevante de:

-   propósito próprio;
-   lifecycle;
-   regras;
-   permissões;
-   dados;
-   UX;
-   integrações;
-   volume funcional.

Não criar módulo apenas por conveniência de menu.

------------------------------------------------------------------------

# 54. Critério para nova Specification

Uma capability pode justificar nova Spec quando:

-   regras são extensas;
-   possui lifecycle independente;
-   envolve segurança própria;
-   possui contratos de API relevantes;
-   exige Acceptance Criteria próprios;
-   possui dependências significativas.

------------------------------------------------------------------------

# 55. Lacunas conhecidas para avaliação posterior

Durante detalhamento das Specs, avaliar se merecem Specs próprias:

``` text
Schedule
Baseline Management
Team
Evidence
Executive Portfolio
```

A decisão deve ocorrer antes de implementação dessas capacidades se o
escopo exceder as Specs existentes.

------------------------------------------------------------------------

# 56. Relação com Feature Prioritization

Este catálogo define **o que existe funcionalmente**.

`feature-prioritization.md` definirá:

``` text
Must
Should
Could
Future
```

e ajudará a estabelecer a ordem de entrega.

------------------------------------------------------------------------

# 57. Relação com MVP Scope

`mvp-scope.md` definirá quais partes deste catálogo entram efetivamente
no MVP.

A existência no catálogo não implica inclusão completa no MVP.

------------------------------------------------------------------------

# 58. Relação com Specifications

O catálogo define responsabilidade.

A Spec define comportamento verificável.

Cada Spec deverá detalhar:

-   Actors;
-   Requirements;
-   Business Rules;
-   Permissions;
-   Scope;
-   Data Policies;
-   States;
-   Workflows;
-   API;
-   Events;
-   Audit;
-   Classification;
-   Errors;
-   Edge Cases;
-   Acceptance Criteria;
-   Tests.

------------------------------------------------------------------------

# 59. Invariantes do catálogo

1.  Cada módulo possui responsabilidade definida.
2.  Uma tela não cria automaticamente domínio.
3.  Projeções não duplicam fontes.
4.  Project permanece núcleo operacional.
5.  Status consolida entidades existentes.
6.  Snapshot preserva estado publicado.
7.  Time Machine depende de histórico real.
8.  Copilot é transversal e autorizado.
9.  Audit não é log técnico comum.
10. Financial possui acesso específico.
11. Resources não é HRIS.
12. Documents não é DMS genérico.
13. Platform Admin não possui acesso automático a dados de negócio.
14. Settings não anulam invariantes de segurança.
15. Novos módulos exigem justificativa funcional.

------------------------------------------------------------------------

# 60. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/personas.md`
-   `/docs/01-product/user-journeys.md`
-   `/docs/01-product/functional-map.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/04-specs/`
-   `/docs/05-ux/screens/`

------------------------------------------------------------------------

# 61. Status

**Documento:** Module Catalog\
**Status:** Under Review\
**Responsabilidade:** estabelecer o catálogo oficial de módulos e
capacidades do PMO Control, suas responsabilidades, dependências,
personas e relação com Specifications.
