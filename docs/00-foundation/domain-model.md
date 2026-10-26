# PMO Control --- Domain Model

**Documento:** `domain-model.md`\
**Camada:** Foundation\
**Status:** Under Review\
**Tipo:** Modelo conceitual de domínio

------------------------------------------------------------------------

## 1. Objetivo

Este documento define o modelo conceitual de domínio do PMO Control: as
principais entidades, seus limites de responsabilidade, relacionamentos,
ciclos de vida e invariantes.

O objetivo não é definir tabelas físicas, endpoints ou componentes de
interface. Esses detalhes pertencem às Specifications e às camadas de
Dados, API e UX.

Este modelo deve ser utilizado como referência comum por todas as Specs.

------------------------------------------------------------------------

## 2. Princípios de modelagem

### 2.1 Entidades de domínio possuem identidade

Um conceito deve ser modelado como entidade quando possuir um ou mais
dos seguintes elementos:

-   identidade própria;
-   ciclo de vida;
-   responsável;
-   histórico;
-   regras de negócio;
-   permissões próprias;
-   eventos;
-   relacionamentos;
-   necessidade de auditoria.

Por isso, conceitos como `Risk`, `Issue`, `Action`, `Decision` e
`StatusUpdate` não devem ser reduzidos a campos de `Project`.

### 2.2 Projeto não é uma tabela gigante

`Project` é o contexto central de gestão, mas não deve absorver toda a
informação do sistema.

``` text
Project
├── Milestones
├── Deliverables
├── Risks
├── Issues
├── Actions
├── Decisions
├── Dependencies
├── Financial Records
├── Resource Allocations
├── Documents
└── Status Updates
```

### 2.3 Histórico não deve depender do estado atual

O estado atual pode mudar.

Estados formalmente publicados devem ser preservados por `Snapshot`.

### 2.4 Relacionamentos devem ser explícitos

Quando uma entidade estiver relacionada a outra, essa relação deve ser
representável e consultável.

Exemplo:

``` text
Risk
 ├── Mitigation Actions
 ├── Related Milestone
 ├── Related Deliverable
 └── Materialized Issue
```

------------------------------------------------------------------------

# 3. Visão geral do domínio

``` text
Platform
│
├── Tenant
│   ├── Tenant Memberships
│   │   └── Users
│   │
│   ├── Portfolios
│   │   └── Projects
│   │       ├── Milestones
│   │       ├── Deliverables
│   │       ├── Risks
│   │       ├── Issues
│   │       ├── Actions
│   │       ├── Decisions
│   │       ├── Dependencies
│   │       ├── Financial Records
│   │       ├── Resource Allocations
│   │       ├── Documents / Evidence
│   │       ├── Status Updates
│   │       │   └── Snapshots
│   │       └── Audit Events
│   │
│   ├── Notifications
│   ├── Integrations
│   ├── AI Configuration
│   └── Settings
│
└── Platform Configuration
```

Essa árvore representa pertencimento conceitual, não necessariamente
composição física de tabelas.

------------------------------------------------------------------------

# 4. Contextos principais

O domínio pode ser dividido inicialmente nos seguintes contextos:

``` text
Identity & Access
Portfolio Governance
Project Management
Execution Control
Governance & Status
Financial Management
Resource Management
Knowledge & Evidence
Reporting & Analytics
AI & Intelligence
Audit & Compliance
Platform Administration
```

Esses contextos ajudam a evitar acoplamento excessivo entre módulos.

------------------------------------------------------------------------

# 5. Platform

## Definição

Representa o PMO Control enquanto plataforma SaaS.

Responsabilidades conceituais:

-   gerenciamento de Tenants;
-   configurações globais;
-   planos e limites;
-   funcionalidades disponíveis;
-   operação da plataforma.

`Platform` não implica acesso automático aos dados de negócio dos
Tenants.

------------------------------------------------------------------------

# 6. Tenant

## Definição

Representa uma organização cliente isolada.

## Possui

``` text
Tenant
├── Memberships
├── Portfolios
├── Projects
├── Settings
├── Integrations
├── AI Configuration
└── Audit Context
```

## Invariantes

1.  Todo dado de negócio deve possuir associação inequívoca a um Tenant.
2.  Um Tenant não pode acessar dados de outro Tenant.
3.  Operações cross-tenant devem ser negadas por padrão.
4.  Configurações de um Tenant não podem alterar comportamento de outro.

------------------------------------------------------------------------

# 7. User e Tenant Membership

## User

Representa a identidade de uma pessoa ou conta autenticável.

## Tenant Membership

Representa o vínculo entre `User` e `Tenant`.

``` text
User
  │
  └── Tenant Membership
          │
          ├── Role Assignments
          └── Scope Assignments
```

A autorização não deve depender apenas de `User`.

Um mesmo usuário poderá futuramente possuir membership em mais de um
Tenant, caso essa capacidade seja aprovada nas Specs.

------------------------------------------------------------------------

# 8. Role Assignment

Representa a associação entre:

``` text
User / Membership
        +
Role
        +
Scope
```

Exemplo:

``` text
Ana Silva
Role: Project Manager
Scope: Project ERP
```

Outro:

``` text
Paulo
Role: PMO
Scope: Portfolio IA
```

A definição completa será formalizada em `permission-model.md` e na Spec
`003-rbac`.

------------------------------------------------------------------------

# 9. Portfolio

## Definição

Agrupamento governado de projetos.

## Relacionamento

``` text
Tenant
  └── Portfolio
        ├── Project A
        ├── Project B
        └── Project C
```

## Responsabilidades

-   consolidar projetos;
-   permitir visão de saúde;
-   consolidar riscos;
-   consolidar investimentos;
-   consolidar marcos;
-   consolidar decisões;
-   suportar priorização.

## Regra

Dashboard de Portfolio é uma projeção dos dados governados, não uma
fonte independente.

------------------------------------------------------------------------

# 10. Project

## Definição

Principal unidade operacional de gestão.

## Atributos conceituais

Entre outros:

-   identidade;
-   nome;
-   descrição;
-   objetivo;
-   área;
-   sponsor;
-   Project Manager;
-   fase;
-   estado;
-   progresso;
-   datas;
-   baseline;
-   forecast;
-   saúde/RAG;
-   orçamento;
-   escopo;
-   timestamps.

A lista definitiva pertence à Spec `005-projects`.

## Estados iniciais

``` text
planning
execution
paused
completed
cancelled
```

## Relacionamentos

``` text
Project
├── Portfolio
├── Members
├── Milestones
├── Deliverables
├── Risks
├── Issues
├── Actions
├── Decisions
├── Dependencies
├── Financial Records
├── Resource Allocations
├── Documents
├── Status Updates
└── Audit Events
```

------------------------------------------------------------------------

# 11. Project Membership

Representa a participação de um usuário em um projeto.

Não deve ser confundido automaticamente com autorização total.

Exemplo:

``` text
Project Membership
├── User
├── Project
├── Function
└── Access Context
```

Um Contributor pode pertencer ao projeto e ainda assim possuir acesso
apenas aos itens atribuídos.

------------------------------------------------------------------------

# 12. Baseline

Baseline representa um compromisso aprovado e versionado.

Conceitualmente:

``` text
Project
  └── Baseline
       ├── Version
       ├── Effective Date
       ├── Approved By
       ├── Schedule Commitments
       ├── Financial Commitments
       └── Scope Commitments
```

## Invariantes

-   baseline aprovada não é sobrescrita silenciosamente;
-   mudança relevante cria histórico/versionamento;
-   motivo e aprovação podem ser obrigatórios;
-   comparação com Forecast deve continuar possível.

------------------------------------------------------------------------

# 13. Forecast

Representa a previsão corrente.

Pode existir para:

-   data;
-   custo;
-   conclusão;
-   capacidade;
-   benefício.

Forecast pode mudar ao longo da execução sem substituir a Baseline.

``` text
Variance = Forecast - Baseline
```

A interpretação da variação depende do indicador.

------------------------------------------------------------------------

# 14. Milestone

## Definição

Marco significativo do projeto.

## Relacionamentos

``` text
Project
  └── Milestone
       ├── Deliverables
       ├── Dependencies
       ├── Risks
       └── Actions
```

## Propriedades conceituais

-   planned date;
-   forecast date;
-   actual date;
-   status;
-   owner;
-   criticality;
-   progress;
-   description.

## Estados iniciais sugeridos

``` text
planned
in_progress
completed
delayed
cancelled
```

A Spec `007-milestones` definirá estados definitivos.

------------------------------------------------------------------------

# 15. Deliverable

## Definição

Resultado verificável produzido pelo projeto.

## Relações possíveis

``` text
Deliverable
├── Project
├── Milestone
├── Owner
├── Evidence
├── Dependencies
└── Actions
```

Um Milestone pode depender da conclusão de uma ou várias Deliverables.

------------------------------------------------------------------------

# 16. Risk

## Definição

Evento ou condição incerta que pode afetar objetivos.

## Modelo conceitual

``` text
Risk
├── Probability
├── Impact
├── Exposure / Criticality
├── Category
├── Owner
├── Response
├── Mitigation Actions
├── Related Entities
└── Evidence
```

## Estados iniciais

``` text
identified
assessing
treating
monitoring
closed
materialized
```

## Materialização

Quando um Risk ocorre:

``` text
Risk
  │ materializes
  ▼
Issue
```

A associação deve preservar rastreabilidade.

------------------------------------------------------------------------

# 17. Issue

## Definição

Problema ou impedimento existente.

## Modelo conceitual

``` text
Issue
├── Severity
├── Impact
├── Owner
├── Root Cause
├── Resolution Plan
├── Actions
├── Related Entities
└── Evidence
```

## Estados iniciais

``` text
open
analyzing
in_progress
blocked
resolved
closed
```

------------------------------------------------------------------------

# 18. Action

## Definição

Atividade rastreável com responsável e prazo.

## Pode estar relacionada a

``` text
Action
├── Project
├── Risk
├── Issue
├── Decision
├── Milestone
├── Deliverable
├── Meeting
└── Status Update
```

## Propriedades conceituais

-   owner;
-   due date;
-   priority;
-   status;
-   progress;
-   evidence;
-   comments.

## Regra

Uma Action vencida e não concluída deve ser identificável como
`overdue`.

------------------------------------------------------------------------

# 19. Decision

## Definição

Registro governado de uma escolha relevante.

## Modelo conceitual

``` text
Decision
├── Context
├── Options
├── Recommendation
├── Requested By
├── Decision Makers
├── Due Date
├── Impact
├── Evidence
├── Result
└── Actions
```

## Estados iniciais sugeridos

``` text
draft
pending
approved
rejected
deferred
cancelled
```

A decisão deve preservar quem decidiu, quando e em qual contexto.

------------------------------------------------------------------------

# 20. Dependency

## Definição

Relação de dependência entre entidades.

O modelo deve suportar dependências como:

``` text
Project → Project
Milestone → Milestone
Deliverable → Deliverable
Project → External Dependency
```

Uma dependência pode possuir:

-   predecessor;
-   successor;
-   owner;
-   due date;
-   criticality;
-   status;
-   impact.

Dependências críticas devem ser visíveis para governança.

------------------------------------------------------------------------

# 21. Financial Record

Representa informação financeira governada associada ao projeto ou
portfólio.

Conceitos relacionados:

``` text
Budget
Actual
Commitment
Forecast
Variance
```

Informações financeiras podem possuir Data Policy específica.

A modelagem detalhada pertence à Spec `020-financial`.

------------------------------------------------------------------------

# 22. Resource e Resource Allocation

## Resource

Representa capacidade alocável.

## Resource Allocation

Relaciona um Resource a um Project e período.

``` text
Resource
  └── Allocation
       ├── Project
       ├── Period
       └── Allocation %
```

A soma das alocações permite identificar sobrealocação.

A Spec `021-resources` definirá o modelo definitivo.

------------------------------------------------------------------------

# 23. Document

Representa documento associado a contexto de negócio.

``` text
Document
├── Tenant
├── Project / Portfolio
├── Classification
├── Version
├── Owner
└── Metadata
```

Documentos podem possuir classificação e acesso adicionais.

------------------------------------------------------------------------

# 24. Evidence

Evidence representa material utilizado para sustentar uma afirmação ou
evento de governança.

Pode estar relacionada a:

-   Deliverable;
-   Risk;
-   Issue;
-   Decision;
-   Action;
-   Status Update;
-   Baseline change.

Evidence pode apontar para Document ou outra fonte suportada.

------------------------------------------------------------------------

# 25. Status Update

## Definição

Aggregate de governança que consolida o estado de um Project para um
período.

## Modelo conceitual

``` text
Status Update
├── Project
├── Period
├── Prepared By
├── Workflow State
├── Executive Summary
├── KPI Summary
├── RAG Assessment
├── Relevant Milestones
├── Relevant Deliverables
├── Relevant Risks
├── Relevant Issues
├── Relevant Actions
├── Relevant Decisions
├── Publication
└── Snapshot
```

## Estados iniciais

``` text
draft
under_review
published
superseded
```

## Regra central

Status Update referencia/consolida entidades operacionais existentes;
não deve criar cópias independentes apenas para alimentar o relatório.

------------------------------------------------------------------------

# 26. Status Publication

Representa o ato governado de publicar uma atualização.

Fluxo conceitual:

``` text
Validate
  ↓
Calculate KPIs
  ↓
Calculate / Recommend RAG
  ↓
Consolidate
  ↓
Publish
  ↓
Create Snapshot
  ↓
Register Audit
  ↓
Update Derived Views
  ↓
Notify
```

A publicação deve ser consistente e não produzir estado parcialmente
publicado.

------------------------------------------------------------------------

# 27. Snapshot

## Definição

Estado histórico imutável produzido por uma publicação ou evento de
versionamento relevante.

``` text
Snapshot
├── Context
├── Timestamp
├── Source Version
├── Published By
├── Data
└── Integrity Metadata
```

## Regra

Snapshot não é a entidade operacional corrente.

Ele representa como o contexto estava em determinado momento.

------------------------------------------------------------------------

# 28. RAG Assessment

Representa a avaliação de saúde.

Conceitualmente deve permitir distinguir:

``` text
Calculated RAG
Recommended RAG
Effective RAG
Override?
Override Reason
Rule Version
```

Isso preserva explicabilidade e auditoria.

------------------------------------------------------------------------

# 29. Notification

Representa uma comunicação destinada a um usuário.

Pode ser gerada por:

-   Action overdue;
-   Decision pending;
-   Risk escalation;
-   Status review;
-   Milestone approaching;
-   Publication;
-   Assignment.

Notificação não substitui a entidade que a originou.

------------------------------------------------------------------------

# 30. Audit Event

Representa fato registrado para auditoria.

``` text
Audit Event
├── Tenant
├── Actor
├── Action
├── Resource
├── Timestamp
├── Before
├── After
├── Reason
└── Context
```

Eventos de auditoria devem ser protegidos contra alteração indevida.

------------------------------------------------------------------------

# 31. PMO Copilot Context

O PMO Copilot não deve possuir um domínio paralelo.

Ele consome dados autorizados das entidades existentes.

``` text
User
  ↓
Authorization Context
  ↓
Authorized Domain Data
  ↓
PMO Copilot
  ↓
Answer / Analysis / Recommendation
```

A IA nunca deve ampliar o escopo de acesso.

------------------------------------------------------------------------

# 32. Relações críticas

## Risk → Issue

``` text
Risk
 └── materialized_as → Issue
```

## Decision → Action

``` text
Decision
 └── generates → Action(s)
```

## Issue → Action

``` text
Issue
 └── resolution_plan → Action(s)
```

## Milestone → Deliverable

``` text
Milestone
 └── depends_on → Deliverable(s)
```

## Status Update → Snapshot

``` text
Status Update
 └── publication → Snapshot
```

## Baseline → Forecast

``` text
Baseline
     ↓ compare
Forecast
     ↓
Variance
```

------------------------------------------------------------------------

# 33. Agregações e projeções

Nem tudo que aparece na UI precisa ser uma entidade persistente
independente.

Exemplos de projeções:

-   Project Dashboard;
-   Portfolio Dashboard;
-   Executive View;
-   My Day;
-   KPI cards;
-   charts;
-   Copilot summaries.

Essas visões são derivadas das entidades governadas.

``` text
Domain Data
     ↓
Projection / Aggregation
     ↓
Dashboard / Report / My Day
```

Isso evita transformar cada tela em uma fonte de dados separada.

------------------------------------------------------------------------

# 34. Meu Dia

`My Day` deve ser tratado inicialmente como uma projeção operacional
personalizada.

Ele consolida itens como:

``` text
User
├── Overdue Actions
├── Actions Due Today
├── Pending Decisions
├── Critical Risks
├── Projects Without Status
├── Upcoming Milestones
├── Meetings
└── Recent Changes
```

Não é necessário criar uma entidade `MyDay` apenas para reproduzir a
tela.

------------------------------------------------------------------------

# 35. Project Control Center

Também é uma projeção.

``` text
Project
     ↓
Current State + KPIs + Exceptions + Recent Events
     ↓
Project Control Center
```

As informações permanecem pertencentes às entidades originais.

------------------------------------------------------------------------

# 36. Portfolio Dashboard

É uma agregação autorizada dos projetos pertencentes ao escopo.

``` text
Portfolio
  ↓
Authorized Projects
  ↓
Aggregation
  ↓
Portfolio Dashboard
```

------------------------------------------------------------------------

# 37. Identidade das entidades

Toda entidade persistente relevante deve possuir identificador estável.

Diretriz conceitual:

``` text
id
tenant_id
created_at
updated_at
```

quando aplicável.

Campos físicos definitivos serão definidos em `/docs/06-data/` e nas
Specs.

IDs não devem expor sequência previsível quando isso representar risco.

------------------------------------------------------------------------

# 38. Temporalidade

O domínio precisa distinguir pelo menos:

``` text
Planned
Baseline
Forecast
Actual
Historical Snapshot
```

Esses conceitos não devem ser misturados.

Exemplo:

``` text
Milestone

Baseline: 01/12
Forecast: 15/12
Actual:   null
```

------------------------------------------------------------------------

# 39. Soft Delete, Archive e histórico

A estratégia física ainda será definida por ADR/Specs.

Conceitualmente, entidades relevantes para governança não devem
desaparecer sem preservar rastreabilidade.

Operações como:

-   delete;
-   archive;
-   cancel;
-   supersede;

não são necessariamente equivalentes.

------------------------------------------------------------------------

# 40. Eventos de domínio iniciais

Eventos previstos incluem:

``` text
ProjectCreated
ProjectUpdated
BaselineChanged
MilestoneCompleted
DeliverableCompleted
RiskCreated
RiskEscalated
RiskMaterialized
IssueCreated
IssueResolved
ActionCreated
ActionOverdue
DecisionRequested
DecisionMade
StatusDraftCreated
StatusPublished
RAGChanged
RAGOverridden
SnapshotCreated
BudgetThresholdExceeded
ResourceOverallocated
PermissionGranted
PermissionRevoked
```

A lista definitiva será distribuída entre as Specs correspondentes.

------------------------------------------------------------------------

# 41. Invariantes globais do domínio

1.  Todo dado de negócio pertence a um Tenant.
2.  Nenhuma projeção pode ampliar autorização.
3.  Status publicado deve possuir histórico preservado.
4.  Baseline aprovada não é silenciosamente sobrescrita.
5.  Forecast não substitui Baseline.
6.  Risk e Issue são conceitos distintos.
7.  Risk materializado pode originar/relacionar um Issue.
8.  Dashboard não é fonte primária.
9.  My Day não é fonte primária.
10. PMO Copilot não é fonte primária.
11. Operações sensíveis devem ser auditáveis.
12. Dados derivados devem ser reconstruíveis sempre que tecnicamente
    razoável.
13. Relações cross-tenant são proibidas por padrão.
14. Entidades históricas publicadas não devem depender exclusivamente do
    estado operacional corrente.

------------------------------------------------------------------------

# 42. Limites deste documento

Este documento não define:

-   schema SQL;
-   nomes definitivos de tabelas;
-   tipos físicos;
-   índices;
-   endpoints;
-   payloads;
-   componentes React;
-   políticas RLS completas;
-   fórmulas finais de KPIs;
-   regras finais do RAG;
-   contratos de eventos;
-   estratégia física de snapshots.

Esses elementos serão definidos nas camadas e Specs correspondentes.

------------------------------------------------------------------------

# 43. Dependências documentais

Este documento deve permanecer coerente com:

-   `/docs/00-foundation/glossary.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/01-product/PDD.md`
-   `/docs/04-specs/`
-   `/docs/06-data/`
-   `/docs/07-security/`

------------------------------------------------------------------------

# 44. Pontos ainda a decidir

As seguintes decisões permanecem abertas para documentos posteriores:

1.  cardinalidade exata Project ↔ Portfolio;
2.  suporte a projeto em múltiplos portfólios;
3.  modelo físico de Baseline;
4.  granularidade dos Financial Records;
5.  modelo de benefícios;
6.  representação de reuniões;
7.  modelo de comentários;
8.  estratégia de custom fields;
9.  estratégia de tags;
10. estratégia de soft delete/archive;
11. modelo físico de Snapshot;
12. retenção histórica;
13. memberships multi-tenant;
14. grupos/equipes para autorização;
15. recursos não humanos.

Nenhuma dessas questões deve ser resolvida implicitamente pela
implementação.

------------------------------------------------------------------------

# 45. Status

**Documento:** Domain Model\
**Status:** Under Review\
**Responsabilidade:** definir as entidades conceituais, relações,
agregações, projeções e invariantes fundamentais do domínio PMO Control.
