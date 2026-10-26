# PMO Control --- Functional Map

**Documento:** `functional-map.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Mapa funcional do produto

------------------------------------------------------------------------

## 1. Objetivo

Este documento organiza as capacidades funcionais do PMO Control em
domínios, módulos e relações.

Seu objetivo é responder:

> **Quais capacidades o produto precisa possuir para sustentar as
> jornadas e a proposta de valor?**

O Functional Map não substitui:

-   o PDD;
-   o Domain Model;
-   o Module Catalog;
-   as Specifications;
-   a arquitetura.

Ele funciona como ponte entre visão de produto, jornadas e decomposição
funcional.

------------------------------------------------------------------------

# 2. Visão funcional

O PMO Control pode ser representado em sete grandes áreas:

``` text
PMO CONTROL
│
├── 1. Platform & Access
├── 2. Portfolio Governance
├── 3. Project Management
├── 4. Execution Governance
├── 5. Status & Historical Governance
├── 6. Management & Knowledge
└── 7. Intelligence & Reporting
```

Essas áreas são apoiadas transversalmente por:

``` text
Security
Audit
Notifications
Integrations
Data Governance
AI
```

------------------------------------------------------------------------

# 3. Mapa funcional macro

``` text
                         ┌─────────────────────────┐
                         │      PMO CONTROL        │
                         └────────────┬────────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
 Platform & Access            Portfolio Governance          Project Management
        │                             │                             │
 Authentication                  Portfolios                      Projects
 Multi-tenancy                  Executive View              Project Control Center
 RBAC                           Prioritization                    Schedule
 Settings                       Portfolio Health                 Milestones
                                                                   Deliverables
                                                                   Dependencies
        │                             │                             │
        └─────────────────────────────┼─────────────────────────────┘
                                      │
                           Execution Governance
                                      │
                      Risks / Issues / Actions / Decisions
                                      │
                                      ▼
                         Status & Historical Governance
                                      │
                    Status Update / RAG / Snapshots / Time Machine
                                      │
                 ┌────────────────────┴────────────────────┐
                 │                                         │
        Management & Knowledge                  Intelligence & Reporting
                 │                                         │
       Financial / Resources                         My Day
       Team / Documents                         Project Dashboard
       Evidence                                Portfolio Dashboard
                                                Report Builder
                                                PMO Copilot
```

------------------------------------------------------------------------

# 4. Área 1 --- Platform & Access

Responsável por identidade, isolamento organizacional, acesso e
configuração.

Capacidades:

``` text
Authentication
Multi-tenancy
Membership
RBAC
Scope
Permissions
Data Policies
Workflow Rules
Settings
Tenant Configuration
Platform Administration
```

------------------------------------------------------------------------

# 5. Authentication

Capacidades:

-   login;
-   logout;
-   sessão;
-   recuperação de acesso;
-   convite;
-   autenticação segura;
-   revogação de sessão;
-   futura evolução para SSO/MFA conforme roadmap.

Relaciona-se com:

``` text
Multi-tenancy
RBAC
Audit
Notifications
```

Spec:

``` text
/docs/04-specs/001-authentication/
```

------------------------------------------------------------------------

# 6. Multi-tenancy

Capacidades:

-   Tenant;
-   Membership;
-   isolamento de dados;
-   contexto de Tenant;
-   configuração por Tenant;
-   suporte a múltiplas organizações.

Regra central:

``` text
Tenant A ≠ Tenant B
```

Dados de negócio não podem atravessar essa fronteira sem mecanismo
explicitamente autorizado.

Spec:

``` text
/docs/04-specs/002-multi-tenancy/
```

------------------------------------------------------------------------

# 7. RBAC & Authorization

Capacidades:

-   Roles;
-   Scope;
-   Permissions;
-   Data Policies;
-   Workflow Rules;
-   grants/revocations;
-   segregation of duties.

Modelo:

``` text
Effective Access =
Tenant
+ Role
+ Scope
+ Permission
+ Data Policy
+ Workflow Rule
```

Spec:

``` text
/docs/04-specs/003-rbac/
```

------------------------------------------------------------------------

# 8. Settings

Capacidades:

-   Tenant settings;
-   taxonomies;
-   RAG configuration;
-   notification preferences;
-   AI/BYOK;
-   integration settings;
-   future custom fields;
-   governance parameters.

Spec:

``` text
/docs/04-specs/029-settings/
```

------------------------------------------------------------------------

# 9. Área 2 --- Portfolio Governance

Responsável por organizar e governar conjuntos de projetos.

Capacidades:

``` text
Portfolios
Portfolio Health
Executive Portfolio
Prioritization
Cross-project Exceptions
Investment View
Strategic Decisions
```

------------------------------------------------------------------------

# 10. Portfolios

Capacidades:

-   criar Portfolio;
-   organizar Projects;
-   atribuir responsáveis;
-   visualizar saúde;
-   consolidar indicadores;
-   filtrar;
-   comparar;
-   acompanhar exceções.

Spec:

``` text
/docs/04-specs/004-portfolios/
```

------------------------------------------------------------------------

# 11. Portfolio Health

Consolida:

-   Project RAG;
-   progress;
-   milestones;
-   risks;
-   issues;
-   actions;
-   decisions;
-   financial;
-   trends.

Não deve manter cópias independentes dos dados operacionais.

------------------------------------------------------------------------

# 12. Executive Portfolio

Visão orientada à liderança.

Perguntas:

``` text
Which projects need attention?
What changed?
What is the impact?
Which decisions are pending?
Where is investment at risk?
What are the next critical milestones?
```

Spec relacionada:

``` text
/docs/04-specs/019-portfolio-dashboard/
```

------------------------------------------------------------------------

# 13. Priorização

Capacidade de apoiar ordenação de iniciativas conforme critérios
definidos pela organização.

Pode considerar futuramente:

-   valor;
-   risco;
-   urgência;
-   investimento;
-   capacidade;
-   dependências;
-   alinhamento estratégico.

A lógica detalhada deve ser configurável e especificada antes de
implementação.

------------------------------------------------------------------------

# 14. Área 3 --- Project Management

Responsável pela estrutura fundamental do projeto.

Capacidades:

``` text
Projects
Project Control Center
Schedule
Baseline
Forecast
Milestones
Deliverables
Dependencies
```

------------------------------------------------------------------------

# 15. Projects

Capacidades:

-   criar;
-   configurar;
-   atribuir responsáveis;
-   associar Portfolio;
-   definir lifecycle;
-   acompanhar estado;
-   pausar;
-   concluir;
-   cancelar;
-   arquivar.

Spec:

``` text
/docs/04-specs/005-projects/
```

------------------------------------------------------------------------

# 16. Project Control Center

É a visão operacional consolidada do projeto.

Deve permitir navegar rapidamente entre:

``` text
Overview
Schedule
Milestones
Deliverables
Risks
Issues
Actions
Decisions
Financial
Team
Resources
Documents
Status
History
```

Não é uma nova fonte de dados.

É uma composição das entidades do projeto.

Spec:

``` text
/docs/04-specs/006-project-control-center/
```

------------------------------------------------------------------------

# 17. Schedule

Capacidades:

-   planejamento temporal;
-   datas;
-   Baseline;
-   Forecast;
-   Actual;
-   dependências;
-   visualização de Timeline;
-   identificação de atraso.

O Schedule pode evoluir em integração com ferramentas externas.

------------------------------------------------------------------------

# 18. Baseline

Representa compromisso aprovado.

Capacidades:

-   registrar versão;
-   preservar histórico;
-   Change Request;
-   aprovação;
-   nova versão.

Baseline não deve ser sobrescrita silenciosamente pelo Forecast.

------------------------------------------------------------------------

# 19. Forecast

Representa expectativa atual.

Permite responder:

> **"Dado o estado atual, quando esperamos concluir?"**

Baseline e Forecast devem permanecer semanticamente distintos.

------------------------------------------------------------------------

# 20. Milestones

Capacidades:

-   criar;
-   editar;
-   atribuir data;
-   associar dependências;
-   acompanhar Forecast;
-   acompanhar Actual;
-   classificar criticidade;
-   identificar ameaça;
-   relacionar Deliverables.

Spec:

``` text
/docs/04-specs/007-milestones/
```

------------------------------------------------------------------------

# 21. Deliverables

Capacidades:

-   criar;
-   atribuir owner;
-   definir prazo;
-   acompanhar progresso;
-   concluir;
-   associar Milestone;
-   associar Evidence;
-   identificar atraso.

Spec:

``` text
/docs/04-specs/008-deliverables/
```

------------------------------------------------------------------------

# 22. Dependencies

Capacidades:

-   registrar dependência;
-   identificar origem/destino;
-   acompanhar estado;
-   indicar impacto;
-   relacionar Projects/Milestones/Deliverables quando permitido.

Spec:

``` text
/docs/04-specs/013-dependencies/
```

------------------------------------------------------------------------

# 23. Área 4 --- Execution Governance

Responsável por controlar exceções, impedimentos, compromissos e
decisões.

Capacidades:

``` text
Risks
Issues
Actions
Decisions
Dependencies
Escalations
```

------------------------------------------------------------------------

# 24. Risks

Capacidades:

-   identificar;
-   avaliar;
-   atribuir owner;
-   classificar;
-   definir resposta;
-   mitigar;
-   monitorar;
-   escalar;
-   fechar;
-   materializar em Issue.

Spec:

``` text
/docs/04-specs/009-risks/
```

------------------------------------------------------------------------

# 25. Issues

Capacidades:

-   registrar problema existente;
-   classificar severidade;
-   avaliar impacto;
-   atribuir owner;
-   definir resolução;
-   criar Actions;
-   escalar;
-   resolver.

Spec:

``` text
/docs/04-specs/010-issues/
```

------------------------------------------------------------------------

# 26. Actions

Capacidades:

-   criar;
-   atribuir owner;
-   definir due date;
-   acompanhar;
-   identificar overdue;
-   concluir;
-   relacionar origem.

Uma Action pode nascer de:

``` text
Risk
Issue
Decision
Meeting
Status
Milestone
Manual Follow-up
```

Spec:

``` text
/docs/04-specs/011-actions/
```

------------------------------------------------------------------------

# 27. Decisions

Capacidades:

-   registrar solicitação;
-   contexto;
-   opções;
-   impacto;
-   impacto da não decisão;
-   deadline;
-   decision maker;
-   evidence;
-   approve;
-   reject;
-   defer;
-   comment;
-   gerar Actions.

Spec:

``` text
/docs/04-specs/012-decisions/
```

------------------------------------------------------------------------

# 28. Área 5 --- Status & Historical Governance

Responsável por consolidar o estado do projeto e preservar histórico
confiável.

Capacidades:

``` text
Status Update
RAG Engine
Snapshots
Time Machine
Historical Comparison
```

------------------------------------------------------------------------

# 29. Status Update

O Status Update funciona como checkpoint de governança.

Etapas:

``` text
1. Execution & Indicators
2. Milestones & Deliverables
3. Risks & Issues
4. Actions & Decisions
5. Summary & Publication
```

Spec:

``` text
/docs/04-specs/014-status-update/
```

------------------------------------------------------------------------

# 30. Status workflow

Fluxo padrão MVP:

```text
Draft → Validate → Publish (Project Manager with explicit grant) → Immutable Snapshot
```

Aprovação separada, `Under Review` e `PMO Review` não são etapas obrigatórias do MVP. Correção posterior exige permission e motivo e cria publicação sucessora. Workflow customizável pode ser evolução futura, não pressuposto atual.

# 31. Status consolidation

O Status deve consumir entidades operacionais.

Exemplo:

``` text
Risks ────────┐
Issues ───────┤
Actions ──────┤
Decisions ────┤
Milestones ───┤
Deliverables ─┤
Financial ────┤
Progress ─────┘
       ↓
Status Update
```

------------------------------------------------------------------------

# 32. RAG Engine

Capacidades:

-   calcular/recomendar RAG;
-   aplicar thresholds;
-   explicar resultado;
-   permitir override autorizado;
-   registrar justificativa;
-   preservar calculated/effective RAG.

Spec:

``` text
/docs/04-specs/015-rag-engine/
```

------------------------------------------------------------------------

# 33. Snapshots

Capacidades:

-   capturar estado publicado;
-   preservar imutabilidade;
-   permitir consulta histórica;
-   sustentar comparação;
-   sustentar Time Machine.

Spec:

``` text
/docs/04-specs/016-snapshots/
```

------------------------------------------------------------------------

# 34. Time Machine

Capacidades:

-   navegar Status históricos;
-   visualizar Snapshot;
-   comparar períodos;
-   explicar evolução;
-   investigar mudanças.

Spec:

``` text
/docs/04-specs/023-time-machine/
```

------------------------------------------------------------------------

# 35. Área 6 --- Management & Knowledge

Responsável por dimensões complementares de governança.

Capacidades:

``` text
Financial
Team
Resources
Capacity
Documents
Evidence
```

------------------------------------------------------------------------

# 36. Financial

Capacidades:

-   Budget;
-   Actual;
-   Forecast;
-   Variance;
-   tendências;
-   exceções;
-   visão de projeto;
-   consolidação autorizada de Portfolio.

Spec:

``` text
/docs/04-specs/020-financial/
```

Acesso financeiro requer Data Policy/Permission apropriada.

------------------------------------------------------------------------

# 37. Team

Capacidades:

-   visualizar equipe do projeto;
-   responsabilidades;
-   papéis;
-   owners;
-   relação com assignments.

Team não substitui sistema de RH.

------------------------------------------------------------------------

# 38. Resources & Capacity

Capacidades:

-   Resources;
-   Allocations;
-   Capacity;
-   overallocation;
-   conflitos;
-   visão cross-project autorizada.

Spec:

``` text
/docs/04-specs/021-resources/
```

------------------------------------------------------------------------

# 39. Documents

Capacidades:

-   armazenar/referenciar documento;
-   classificar;
-   relacionar ao domínio;
-   controlar acesso;
-   preservar metadados.

Spec:

``` text
/docs/04-specs/022-documents/
```

------------------------------------------------------------------------

# 40. Evidence

Evidence é relação entre artefato e afirmação/entidade de governança.

Pode sustentar:

-   Decision;
-   Risk;
-   Issue;
-   Deliverable;
-   Status;
-   Baseline Change;
-   Audit investigation.

Evidence não precisa necessariamente ser um arquivo; o modelo final será
definido nas Specs/Data.

------------------------------------------------------------------------

# 41. Área 7 --- Intelligence & Reporting

Responsável por transformar dados em atenção, informação e suporte à
decisão.

Capacidades:

``` text
My Day
Project Dashboard
Portfolio Dashboard
Report Builder
PMO Copilot
Notifications
```

------------------------------------------------------------------------

# 42. My Day

Workspace operacional do PMO.

Capacidades:

-   overdue actions;
-   due this week;
-   critical risks;
-   critical issues;
-   projects without Status;
-   pending decisions;
-   upcoming milestones;
-   dependencies;
-   resource conflicts;
-   quick navigation.

Spec:

``` text
/docs/04-specs/017-my-day/
```

------------------------------------------------------------------------

# 43. Project Dashboard

Visão executiva/gerencial de projeto.

Capacidades:

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

Spec:

``` text
/docs/04-specs/018-project-dashboard/
```

------------------------------------------------------------------------

# 44. Portfolio Dashboard

Capacidades:

-   portfolio health;
-   RAG distribution;
-   investment;
-   trends;
-   critical projects;
-   critical risks;
-   decisions;
-   milestones.

Spec:

``` text
/docs/04-specs/019-portfolio-dashboard/
```

------------------------------------------------------------------------

# 45. Report Builder

Capacidades:

-   selecionar contexto;
-   selecionar seções;
-   usar dados atuais ou Snapshot;
-   gerar report;
-   revisar;
-   exportar;
-   aplicar AI summary quando autorizado.

Spec:

``` text
/docs/04-specs/024-report-builder/
```

------------------------------------------------------------------------

# 46. PMO Copilot

Capacidades:

-   Q&A contextual;
-   resumo;
-   comparação;
-   priorização;
-   análise;
-   recomendações;
-   preparação de comitê;
-   apoio ao Status;
-   explicação de RAG;
-   futuro scenario analysis.

Spec:

``` text
/docs/04-specs/025-pmo-copilot/
```

------------------------------------------------------------------------

# 47. Notifications

Capacidades:

-   eventos;
-   reminders;
-   escalations;
-   assignments;
-   decisões;
-   Status;
-   deadlines;
-   preferências.

Spec:

``` text
/docs/04-specs/026-notifications/
```

------------------------------------------------------------------------

# 48. Capacidade transversal --- Audit

Audit atravessa módulos sensíveis.

Capacidades:

-   registrar actor;
-   action;
-   timestamp;
-   resource;
-   previous/new state quando aplicável;
-   justification;
-   correlation.

Spec:

``` text
/docs/04-specs/027-audit-log/
```

------------------------------------------------------------------------

# 49. Capacidade transversal --- Import / Export

Capacidades:

-   importação;
-   validação;
-   mapping;
-   preview;
-   execução;
-   export;
-   autorização;
-   audit.

Spec:

``` text
/docs/04-specs/028-import-export/
```

------------------------------------------------------------------------

# 50. Capacidade transversal --- Integrations

Integrações futuras podem conectar:

``` text
Jira
Azure DevOps
Microsoft Project
Excel
Corporate APIs
Financial Systems
Document Systems
```

Princípios:

-   source authority explícita;
-   Tenant binding;
-   idempotência;
-   observabilidade;
-   segurança;
-   rastreabilidade.

------------------------------------------------------------------------

# 51. Capacidade transversal --- Security

Security aplica-se a todo o mapa.

Inclui:

``` text
Authentication
Authorization
Tenant Isolation
Data Policies
Secret Management
Session Security
IDOR/BOLA Protection
Secure Export
Audit
```

------------------------------------------------------------------------

# 52. Capacidade transversal --- AI

IA pode atuar em diferentes módulos, mas não cria domínio paralelo.

Exemplo:

``` text
Status
 └── AI Summary

Risks
 └── AI Analysis

Portfolio
 └── AI Prioritization

Reports
 └── AI Narrative

Copilot
 └── Cross-domain intelligence
```

------------------------------------------------------------------------

# 53. Relação funcional principal

``` text
Portfolio
   └── Project
        ├── Schedule
        ├── Milestones
        ├── Deliverables
        ├── Dependencies
        ├── Risks
        ├── Issues
        ├── Actions
        ├── Decisions
        ├── Financial
        ├── Resources
        ├── Documents
        └── Status Updates
             └── Snapshots
```

------------------------------------------------------------------------

# 54. Fluxo de dados funcional

``` text
Operational Entities
        ↓
Consolidation
        ↓
Status / Dashboards / My Day
        ↓
Portfolio
        ↓
Reports / Copilot
        ↓
Decision
        ↓
Action
```

------------------------------------------------------------------------

# 55. Fonte versus projeção

## Fontes operacionais

Exemplos:

``` text
Risk
Issue
Action
Decision
Milestone
Deliverable
Financial Record
Resource Allocation
```

## Projeções

Exemplos:

``` text
My Day
Project Dashboard
Portfolio Dashboard
Executive Portfolio
Reports
```

Uma projeção não deve se tornar fonte paralela do mesmo fato.

------------------------------------------------------------------------

# 56. Funcionalidades que alteram estado

Exemplos:

``` text
Projects
Milestones
Deliverables
Risks
Issues
Actions
Decisions
Status
Financial
Resources
Documents
Settings
```

------------------------------------------------------------------------

# 57. Funcionalidades predominantemente de leitura

Exemplos:

``` text
Executive Portfolio
Project Dashboard
Portfolio Dashboard
Time Machine
Reports
Audit
```

Isso não significa ausência de ações contextuais autorizadas.

------------------------------------------------------------------------

# 58. Funcionalidades derivadas

``` text
My Day
Dashboards
Reports
Copilot Insights
Notifications
```

dependem de outras entidades e eventos.

------------------------------------------------------------------------

# 59. Mapa de dependências --- Status

``` text
Projects
 ├── Milestones
 ├── Deliverables
 ├── Risks
 ├── Issues
 ├── Actions
 ├── Decisions
 ├── Financial
 └── Dependencies
        ↓
   Status Update
        ↓
     RAG Engine
        ↓
     Snapshot
        ↓
 Project Dashboard
 Portfolio Dashboard
 Time Machine
 Reports
 Copilot
```

------------------------------------------------------------------------

# 60. Mapa de dependências --- My Day

``` text
Actions
Risks
Issues
Decisions
Milestones
Status Updates
Dependencies
Resources
      ↓
    My Day
```

My Day é uma projeção orientada à atenção.

------------------------------------------------------------------------

# 61. Mapa de dependências --- Executive Portfolio

``` text
Projects
Status / Snapshots
RAG
Financial
Risks
Issues
Milestones
Decisions
      ↓
Executive Portfolio
```

------------------------------------------------------------------------

# 62. Mapa de dependências --- Copilot

``` text
Authorized Domain Data
        +
Snapshots
        +
Documents/Evidence
        +
User Context
        +
Tenant AI Policy
        ↓
PMO Copilot
```

------------------------------------------------------------------------

# 63. Functional Map × Specifications

     \# Capability               Spec
  ----- ------------------------ ------------------------------
    001 Authentication           `001-authentication`
    002 Multi-tenancy            `002-multi-tenancy`
    003 RBAC                     `003-rbac`
    004 Portfolios               `004-portfolios`
    005 Projects                 `005-projects`
    006 Project Control Center   `006-project-control-center`
    007 Milestones               `007-milestones`
    008 Deliverables             `008-deliverables`
    009 Risks                    `009-risks`
    010 Issues                   `010-issues`
    011 Actions                  `011-actions`
    012 Decisions                `012-decisions`
    013 Dependencies             `013-dependencies`
    014 Status Update            `014-status-update`
    015 RAG Engine               `015-rag-engine`
    016 Snapshots                `016-snapshots`
    017 My Day                   `017-my-day`
    018 Project Dashboard        `018-project-dashboard`
    019 Portfolio Dashboard      `019-portfolio-dashboard`
    020 Financial                `020-financial`
    021 Resources                `021-resources`
    022 Documents                `022-documents`
    023 Time Machine             `023-time-machine`
    024 Report Builder           `024-report-builder`
    025 PMO Copilot              `025-pmo-copilot`
    026 Notifications            `026-notifications`
    027 Audit Log                `027-audit-log`
    028 Import / Export          `028-import-export`
    029 Settings                 `029-settings`

------------------------------------------------------------------------

# 64. Cobertura das telas já concebidas

As referências visuais atuais cobrem:

``` text
Login
My Day
Executive Portfolio
Portfolio
Project Control Center
Schedule
Milestones
Deliverables
Risks
Issues
Actions
Decisions
Financial
Team
Resources
Documents
Status Update
Time Machine
Report Builder
PMO Copilot
Settings
```

Essas telas devem permanecer rastreáveis às capacidades deste mapa.

------------------------------------------------------------------------

# 65. Capability sem tela própria

Nem toda capacidade precisa de tela dedicada.

Exemplos:

``` text
RAG Engine
Snapshots
Audit Events
Tenant Isolation
Data Policies
Workflow Rules
```

São capacidades fundamentais mesmo quando aparecem embutidas em outras
experiências.

------------------------------------------------------------------------

# 66. Tela sem domínio próprio

Nem toda tela cria entidade própria.

Exemplo:

``` text
My Day
```

é uma projeção.

``` text
Executive Portfolio
```

é uma projeção.

``` text
Project Control Center
```

é uma composição.

Essa distinção evita modelagem orientada por telas.

------------------------------------------------------------------------

# 67. CRUD não define a capacidade

Uma capacidade funcional não deve ser especificada apenas como:

``` text
Create
Read
Update
Delete
```

Também deve considerar:

-   lifecycle;
-   regras;
-   estados;
-   permissões;
-   relacionamentos;
-   eventos;
-   audit;
-   efeitos derivados.

------------------------------------------------------------------------

# 68. Capacidade de governança

Uma funcionalidade é considerada de governança quando ajuda a responder
uma ou mais perguntas:

``` text
What is happening?
Why?
What is the impact?
Who owns it?
What needs to happen?
Who must decide?
When?
What evidence exists?
What changed?
```

------------------------------------------------------------------------

# 69. Mapa de valor

``` text
Operational Control
       ↓
Reliable Data
       ↓
Governance
       ↓
Context
       ↓
Insight
       ↓
Decision
       ↓
Action
       ↓
Outcome
```

As capacidades do produto devem contribuir para esse fluxo.

------------------------------------------------------------------------

# 70. Dependências funcionais críticas

## Status depende de

-   Project;
-   operational entities;
-   permissions;
-   RAG;
-   Snapshot.

## Portfolio depende de

-   Projects;
-   current/published health;
-   aggregation.

## Time Machine depende de

-   published Snapshots.

## Copilot depende de

-   authorization;
-   domain data;
-   classification;
-   AI configuration.

## My Day depende de

-   queryable exceptions;
-   ownership;
-   deadlines;
-   status.

------------------------------------------------------------------------

# 71. Sequência funcional de construção

A ordem exata será refinada em `feature-prioritization.md`,
`mvp-scope.md` e roadmap.

Dependência conceitual:

``` text
Access Foundation
      ↓
Projects / Portfolio
      ↓
Operational Entities
      ↓
Status / RAG
      ↓
Snapshots
      ↓
Dashboards / My Day
      ↓
Reports
      ↓
Copilot
      ↓
Advanced Intelligence
```

------------------------------------------------------------------------

# 72. Capabilities futuras

Possíveis extensões:

``` text
Advanced Scenario Simulation
Predictive Risk
Portfolio Optimization
AI Agents
Automated Data Quality
Advanced Integrations
Custom Workflows
Custom Fields
Advanced Resource Planning
Strategy / OKR Alignment
Benefits Realization
Outcome Tracking
```

Essas capacidades não devem ser assumidas como MVP apenas por constarem
como direção futura.

------------------------------------------------------------------------

# 73. Critério para inclusão de nova capacidade

Toda nova capability deve declarar:

1.  problema;
2.  persona;
3.  Job to Be Done;
4.  domínio;
5.  fonte de dados;
6.  dependências;
7.  impacto de autorização;
8.  impacto de classificação;
9.  impacto em auditoria;
10. valor esperado;
11. fase do produto.

------------------------------------------------------------------------

# 74. Critério para separar módulo

Criar módulo separado quando houver justificativa clara, como:

-   lifecycle próprio;
-   conjunto relevante de regras;
-   ownership distinto;
-   permissões específicas;
-   volume funcional significativo;
-   necessidade de navegação própria.

Evitar criar módulos apenas porque existe um card ou gráfico.

------------------------------------------------------------------------

# 75. Critério para composição

Preferir composição quando a experiência agrega entidades existentes.

Exemplo:

``` text
Project Control Center
```

compõe informações de múltiplos módulos.

Não deve duplicar os domínios.

------------------------------------------------------------------------

# 76. Critério para projeção

Preferir projeção quando a necessidade é reorganizar dados para uma
pergunta específica.

Exemplo:

``` text
My Day
```

responde:

> "O que exige minha atenção?"

Não precisa criar cópias de Risks, Actions ou Milestones.

------------------------------------------------------------------------

# 77. Critério para automação

Automação deve reduzir tarefas repetitivas como:

-   consolidação;
-   comparação;
-   cálculo;
-   alerta;
-   sumarização;
-   propagação.

Não deve ocultar decisões humanas relevantes.

------------------------------------------------------------------------

# 78. Critério para IA

Usar IA onde ela oferece valor adicional sobre regras determinísticas.

``` text
Rules → deterministic governance
AI    → contextual analysis
```

Os dois podem coexistir.

------------------------------------------------------------------------

# 79. Invariantes funcionais

1.  Portfolio contém Projects.
2.  Project é o núcleo operacional.
3.  Entidades operacionais são fontes.
4.  Dashboards são projeções.
5.  Status consolida, não duplica.
6.  Snapshot preserva publicação.
7.  Time Machine depende de Snapshot.
8.  RAG deve ser explicável.
9.  My Day é orientado a exceções.
10. Decision pode gerar Action.
11. Risk pode materializar em Issue.
12. Documents podem atuar como Evidence.
13. Financial e Resources possuem políticas específicas.
14. Copilot não amplia autorização.
15. Audit atravessa operações sensíveis.
16. Settings configuram comportamento permitido, não anulam invariantes.
17. Multi-tenancy atravessa todas as capacidades.
18. Cada capability deve ser rastreável a problema e persona.

------------------------------------------------------------------------

# 80. Relação com próximos documentos

`module-catalog.md` detalhará cada módulo de maneira padronizada,
incluindo:

``` text
Purpose
Primary Personas
Responsibilities
Inputs
Outputs
Dependencies
Key Entities
Key Rules
Related Specs
Related Screens
```

`feature-prioritization.md` determinará prioridade.

`mvp-scope.md` estabelecerá a fronteira do MVP.

------------------------------------------------------------------------

# 81. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/personas.md`
-   `/docs/01-product/user-journeys.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/04-specs/`
-   `/docs/05-ux/screens/`

------------------------------------------------------------------------

# 82. Status

**Documento:** Functional Map\
**Status:** Under Review\
**Responsabilidade:** organizar as capacidades funcionais do PMO Control
e estabelecer suas relações antes do detalhamento por módulos e
Specifications.
