# PMO Control --- System Architecture

**Documento:** `system-architecture.md`\
**Camada:** Architecture\
**Status:** Approved\
**Tipo:** Arquitetura lógica e runtime do sistema

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a arquitetura sistêmica do PMO Control no nível
lógico e de runtime.

Ele descreve:

-   componentes principais;
-   responsabilidades;
-   fronteiras;
-   fluxos síncronos e assíncronos;
-   dependências;
-   composição dos módulos;
-   publicação de Status;
-   projeções;
-   integrações;
-   IA;
-   observabilidade;
-   evolução arquitetural.

O foco é explicar **como o sistema se organiza para suportar o
comportamento definido pelo produto**, sem antecipar detalhes
desnecessários de implementação.

------------------------------------------------------------------------

# 2. Contexto arquitetural

O PMO Control é um SaaS multi-tenant para governança de projetos e
portfólios.

O sistema precisa suportar simultaneamente:

``` text
Operational Project Data
        +
Governance Workflows
        +
Historical State
        +
Executive Projections
        +
Reporting
        +
AI-assisted Intelligence
```

A arquitetura precisa preservar a diferença entre esses conceitos.

------------------------------------------------------------------------

# 3. Estilo arquitetural inicial

O MVP adota:

``` text
Modular Monolith
```

com aplicação web em:

``` text
Next.js + TypeScript
```

e persistência principal em:

``` text
PostgreSQL / Supabase
```

------------------------------------------------------------------------

# 4. Por que monólito modular

Benefícios para o estágio atual:

-   menor complexidade operacional;
-   transações simples entre módulos;
-   deploy único;
-   desenvolvimento rápido;
-   boundaries lógicos sem custo distribuído;
-   observabilidade simplificada;
-   menor custo;
-   domínio ainda em evolução.

------------------------------------------------------------------------

# 5. O que modular monolith não significa

Não significa:

-   um único módulo gigante;
-   ausência de boundaries;
-   acesso irrestrito entre domínios;
-   business logic dentro de UI;
-   queries aleatórias em qualquer tabela.

A aplicação deve continuar organizada por responsabilidades.

------------------------------------------------------------------------

# 6. System Context

``` text
┌──────────────────────────────────────────────┐
│                  USERS                       │
│                                              │
│ PMO · PM · Contributor · Executive · Admin  │
└──────────────────────┬───────────────────────┘
                       │ HTTPS
                       ▼
┌──────────────────────────────────────────────┐
│              PMO CONTROL                     │
│          Next.js Application                 │
│                                              │
│ UI · Application · Domain · APIs             │
└───────┬──────────┬──────────┬───────────┬────┘
        │          │          │           │
        ▼          ▼          ▼           ▼
 PostgreSQL     Storage     Inngest    AI Gateway
 / Supabase                            │
                                      ▼
                                  AI Provider

        PMO CONTROL
             │
             ▼
     External Integrations
       / SMTP / APIs
```

------------------------------------------------------------------------

# 7. Runtime principal

O runtime principal é composto por:

``` text
Browser
Next.js Runtime
Supabase/PostgreSQL
Supabase Storage
Inngest
SMTP
AI Provider
External Integration APIs
```

------------------------------------------------------------------------

# 8. Browser

Responsabilidades:

-   renderização;
-   interação;
-   formulários;
-   navegação;
-   visualização;
-   optimistic UX quando segura;
-   envio de comandos ao servidor.

O browser nunca é autoridade para:

-   Tenant;
-   Role;
-   Permission;
-   ownership;
-   workflow authorization;
-   sensitive policy.

------------------------------------------------------------------------

# 9. Next.js Application

É o runtime central da aplicação.

Responsabilidades:

-   presentation;
-   server-side application logic;
-   authorization orchestration;
-   domain services;
-   API endpoints/server actions;
-   transaction orchestration;
-   AI gateway;
-   integration adapters;
-   job dispatch;
-   observability hooks.

------------------------------------------------------------------------

# 10. PostgreSQL / Supabase

É o sistema transacional principal.

Responsabilidades:

-   persistent state;
-   relational integrity;
-   Tenant ownership;
-   constraints;
-   transactions;
-   historical records;
-   Audit;
-   configuration;
-   projections quando apropriadas.

------------------------------------------------------------------------

# 11. Supabase Auth

Responsável por identidade e sessão conforme decisão arquitetural final.

Não substitui RBAC de negócio.

``` text
Authentication
≠
Authorization
```

------------------------------------------------------------------------

# 12. Supabase Storage

Responsável por objetos binários, especialmente:

-   documentos;
-   evidências;
-   anexos;
-   exports temporários quando aplicável.

Metadata e autorização de negócio permanecem controladas pela
aplicação/banco.

------------------------------------------------------------------------

# 13. Inngest

Responsável por workloads assíncronos.

Exemplos:

-   notifications;
-   AI processing;
-   report jobs;
-   imports;
-   external sync;
-   retries;
-   scheduled governance tasks.

------------------------------------------------------------------------

# 14. SMTP

Canal inicial de e-mail.

Usos:

-   invitation;
-   password/recovery flows quando aplicável;
-   notifications;
-   decision requests;
-   reminders.

------------------------------------------------------------------------

# 15. AI Gateway

Fronteira entre domínio e providers de IA.

Responsabilidades:

-   resolver configuração;
-   selecionar provider/model;
-   aplicar policy;
-   construir contexto autorizado;
-   redigir/minimizar dados;
-   chamar provider;
-   validar output;
-   registrar telemetry;
-   retornar resultado estruturado.

------------------------------------------------------------------------

# 16. External Integrations

Integrações futuras podem incluir:

-   Jira;
-   Azure DevOps;
-   GitHub;
-   Microsoft Project;
-   SharePoint;
-   OneDrive;
-   Google Drive;
-   Teams;
-   Slack;
-   sistemas financeiros.

Cada integração deve possuir adapter próprio.

------------------------------------------------------------------------

# 17. Camadas internas

``` text
┌─────────────────────────────┐
│ Presentation                │
├─────────────────────────────┤
│ Application                 │
├─────────────────────────────┤
│ Domain                      │
├─────────────────────────────┤
│ Infrastructure / Data       │
└─────────────────────────────┘
```

Capacidades transversais atravessam essas camadas por contratos
definidos.

------------------------------------------------------------------------

# 18. Organização orientada a módulo

Estrutura conceitual:

``` text
modules/
├── authentication/
├── tenants/
├── authorization/
├── portfolios/
├── projects/
├── milestones/
├── deliverables/
├── risks/
├── issues/
├── actions/
├── decisions/
├── dependencies/
├── status/
├── rag/
├── snapshots/
├── financial/
├── resources/
├── documents/
├── reports/
├── notifications/
├── audit/
└── ai/
```

A estrutura física final será definida no guia de desenvolvimento.

------------------------------------------------------------------------

# 19. Regra de ownership

Cada domínio deve possuir ownership claro sobre suas entidades e
invariantes.

Exemplo:

``` text
Risks module
owns Risk lifecycle.
```

Project Dashboard não deve alterar Risk diretamente ignorando o módulo
responsável.

------------------------------------------------------------------------

# 20. Composição

Módulos de composição podem reunir dados de múltiplos domínios.

Exemplos:

``` text
Project Control Center
My Day
Project Dashboard
Portfolio Dashboard
Executive Portfolio
```

Eles não se tornam owners dos dados exibidos.

------------------------------------------------------------------------

# 21. Fluxo de comando

Exemplo:

``` text
User
 ↓
UI
 ↓
Application Use Case
 ↓
Authentication Context
 ↓
Authorization
 ↓
Validation
 ↓
Domain Rule
 ↓
Transaction
 ↓
Persistence
 ↓
Audit / Event
 ↓
Response
```

------------------------------------------------------------------------

# 22. Fluxo de leitura

``` text
User
 ↓
UI
 ↓
Query
 ↓
Authentication Context
 ↓
Authorization / Data Policy
 ↓
Tenant-scoped Read
 ↓
Projection
 ↓
Response
```

------------------------------------------------------------------------

# 23. CQRS

O MVP não exige CQRS formal com infraestrutura separada.

Entretanto, a arquitetura reconhece a distinção conceitual entre:

``` text
Commands
```

e:

``` text
Queries
```

Isso ajuda a preservar regras de escrita e otimizar leituras sem
introduzir complexidade prematura.

------------------------------------------------------------------------

# 24. Command boundaries

Operações relevantes devem possuir use cases explícitos.

Exemplos:

``` text
CreateProject
UpdateRisk
MaterializeRisk
CompleteAction
MakeDecision
OverrideRAG
PublishStatus
ChangeBaseline
```

Evitar endpoints genéricos que permitam alterar qualquer campo sem
semântica.

------------------------------------------------------------------------

# 25. Query boundaries

Consultas podem ser orientadas a necessidades de tela.

Exemplos:

``` text
GetMyDay
GetProjectDashboard
GetExecutivePortfolio
GetProjectStatusHistory
```

Queries podem combinar múltiplas fontes desde que respeitem autorização.

------------------------------------------------------------------------

# 26. Transaction boundaries

Transações devem proteger invariantes.

Exemplo:

``` text
PublishStatus
```

precisa garantir consistência entre:

-   publication;
-   effective RAG;
-   Snapshot;
-   audit record;
-   status state.

------------------------------------------------------------------------

# 27. Status publication --- runtime

``` text
Client
  │
  ▼
Publish Status Use Case
  │
  ├─► Resolve User/Tenant
  ├─► Authorize status.update.publish
  ├─► Validate Workflow State
  ├─► Validate Required Data
  ├─► Calculate KPIs
  ├─► Calculate RAG
  ├─► Resolve Override
  │
  ▼
Database Transaction
  │
  ├─► Mark Publication
  ├─► Create Snapshot
  ├─► Create Audit Event
  └─► Commit
  │
  ▼
Dispatch Post-Publication Jobs
  │
  ├─► Notifications
  ├─► AI Summary
  ├─► Analytics
  └─► Derived Processing
```

------------------------------------------------------------------------

# 28. Falha durante publicação

Antes do commit:

``` text
Failure
  ↓
Rollback
```

Após commit:

falhas em jobs derivados não revertem a publicação.

Elas devem:

-   retry;
-   gerar observability;
-   permitir recuperação.

------------------------------------------------------------------------

# 29. Snapshot boundary

Snapshot é histórico publicado.

Não é:

-   cache;
-   cópia temporária;
-   backup;
-   dashboard record.

Ele representa um fato de governança.

------------------------------------------------------------------------

# 30. Snapshot immutability

Após criação oficial:

``` text
UPDATE snapshot
```

deve ser proibido para fluxo normal.

Correções exigem nova publicação/processo definido, não alteração
silenciosa do passado.

------------------------------------------------------------------------

# 31. RAG architecture

``` text
Project State
     ↓
RAG Rule Engine
     ↓
Calculated RAG
     ↓
Optional Authorized Override
     ↓
Effective RAG
```

Persistir, quando aplicável:

-   calculated value;
-   effective value;
-   justification;
-   actor;
-   timestamp.

------------------------------------------------------------------------

# 32. My Day architecture

My Day é uma projeção de exceções.

Fontes:

``` text
Actions
Risks
Issues
Statuses
Decisions
Milestones
Dependencies
Resources
```

Não possui lifecycle paralelo das entidades.

------------------------------------------------------------------------

# 33. Dashboard architecture

Dashboards podem utilizar queries especializadas.

Regra:

``` text
Projection ≠ Source of Truth
```

Se futuramente performance exigir materialização, deve existir
estratégia explícita de atualização/reconstrução.

------------------------------------------------------------------------

# 34. Portfolio aggregation

Portfolio consolida Projects autorizados.

``` text
Portfolio
  ↓
Authorized Projects
  ↓
Project Health / Status / RAG
  ↓
Risks / Decisions / Milestones
  ↓
Portfolio Projection
```

------------------------------------------------------------------------

# 35. Executive Portfolio

É uma projeção especializada para decisão.

Deve privilegiar:

-   exceptions;
-   impact;
-   change;
-   pending Decisions;
-   critical Milestones.

Não deve simplesmente reproduzir dashboard operacional.

------------------------------------------------------------------------

# 36. Financial architecture

Financial permanece módulo próprio.

Outros módulos podem consumir:

-   Budget;
-   Actual;
-   Forecast;
-   Variance.

A autorização financeira é avaliada separadamente.

------------------------------------------------------------------------

# 37. Resource architecture

Resources representa capacidade/alocação de projeto.

Não deve se tornar HRIS.

Identidade de usuário e Resource podem se relacionar, mas não devem ser
confundidas automaticamente.

------------------------------------------------------------------------

# 38. Documents architecture

Metadata relacional:

``` text
PostgreSQL
```

Binary object:

``` text
Storage
```

A aplicação controla:

-   authorization;
-   classification;
-   entity relation;
-   Evidence semantics.

------------------------------------------------------------------------

# 39. Evidence architecture

Evidence é relação governada entre um objeto e sua fonte comprobatória.

Pode apontar para:

-   stored document;
-   external URL autorizada;
-   record;
-   attachment;
-   future integration reference.

------------------------------------------------------------------------

# 40. Audit runtime

Para operação auditável:

``` text
Business Operation
      ↓
Determine Audit Requirement
      ↓
Create Audit Event
```

Quando a integridade exigir, o Audit Event deve participar da mesma
transação.

------------------------------------------------------------------------

# 41. Analytics runtime

Analytics é assíncrono quando possível.

Não deve bloquear operações de negócio normais.

``` text
Domain Activity
     ↓
Analytics Event
     ↓
Processing
```

------------------------------------------------------------------------

# 42. Notifications runtime

``` text
Domain Event
    ↓
Notification Rule
    ↓
Recipient Authorization / Context
    ↓
Notification Record
    ↓
Channel Delivery
```

A mensagem não deve revelar informação que o destinatário não possa
acessar.

------------------------------------------------------------------------

# 43. AI runtime

``` text
User Request
    ↓
Auth Context
    ↓
Intent / Use Case
    ↓
Authorization
    ↓
Context Retrieval
    ↓
Classification / Policy
    ↓
Prompt Construction
    ↓
AI Gateway
    ↓
Provider
    ↓
Output Validation
    ↓
Response
```

------------------------------------------------------------------------

# 44. AI data boundary

O provider só deve receber o contexto necessário.

Nunca construir contexto global do Tenant por conveniência quando a
pergunta exige apenas um Project.

------------------------------------------------------------------------

# 45. AI authorization

Autorização ocorre antes da recuperação final de contexto.

Também deve ser reavaliada antes de ações consequenciais.

------------------------------------------------------------------------

# 46. AI write operations

No MVP, IA não altera silenciosamente estado de negócio.

Fluxo:

``` text
AI Suggestion
     ↓
User Review
     ↓
Explicit Confirmation
     ↓
Authorization Re-check
     ↓
Domain Command
```

------------------------------------------------------------------------

# 47. AI provider failure

``` text
Provider Failure
      ↓
Graceful Error
```

Não deve corromper:

-   Status;
-   Snapshot;
-   Decision;
-   Project state.

------------------------------------------------------------------------

# 48. Background job architecture

Jobs devem possuir:

-   event/input schema;
-   tenant context;
-   correlation ID;
-   idempotency strategy;
-   retry policy;
-   observability;
-   authorization/service policy apropriada.

------------------------------------------------------------------------

# 49. Job security

Um job não ganha autorização irrestrita por ser interno.

Ele opera com:

-   service policy explícita;
-   Tenant context;
-   resource scope.

------------------------------------------------------------------------

# 50. Scheduled jobs

Exemplos:

-   overdue detection;
-   Status reminders;
-   notification digest;
-   integration sync;
-   cleanup;
-   future metric calculations.

------------------------------------------------------------------------

# 51. Webhooks

Quando utilizados:

``` text
External System
     ↓
Webhook Endpoint
     ↓
Signature Verification
     ↓
Validation
     ↓
Idempotency
     ↓
Tenant/Integration Resolution
     ↓
Processing
```

------------------------------------------------------------------------

# 52. Integration runtime

``` text
PMO Control
    ↓
Integration Contract
    ↓
Adapter
    ↓
External API
```

Adapters traduzem modelos externos para contratos internos.

------------------------------------------------------------------------

# 53. Integration failure

Falha externa deve ser registrada separadamente do estado de negócio.

Exemplo:

``` text
Project exists locally.
Jira sync failed.
```

O Project não deixa de existir por causa da falha do Jira.

------------------------------------------------------------------------

# 54. Source authority

Exemplo:

``` text
Jira = source for execution issue status
PMO Control = source for governance Risk
```

A autoridade precisa ser definida por integração/campo.

------------------------------------------------------------------------

# 55. Import architecture

``` text
Upload
 ↓
Store Temporary Artifact
 ↓
Parse
 ↓
Validate
 ↓
Map
 ↓
Preview
 ↓
Confirm
 ↓
Transactional/Batch Import
 ↓
Summary
```

Imports grandes podem usar background processing.

------------------------------------------------------------------------

# 56. Export architecture

``` text
Request
 ↓
Authorize report.export
 ↓
Apply Data Policy
 ↓
Build Dataset
 ↓
Generate Artifact
 ↓
Secure Delivery
```

------------------------------------------------------------------------

# 57. Error boundary

Falhas devem preservar contexto suficiente para suporte sem expor dados
sensíveis.

Resposta ao cliente:

-   código;
-   mensagem segura;
-   correlation ID quando apropriado.

Detalhes técnicos ficam em logs protegidos.

------------------------------------------------------------------------

# 58. Observability context

Propagar quando possível:

``` text
request_id
correlation_id
tenant_id
user_id
operation
module
job_id
```

Sem registrar secrets ou payloads sensíveis desnecessários.

------------------------------------------------------------------------

# 59. Security logging

Eventos de segurança podem incluir:

-   repeated auth failures;
-   authorization denials;
-   cross-tenant attempts;
-   privileged access;
-   suspicious exports.

Isso não substitui controles preventivos.

------------------------------------------------------------------------

# 60. Deployment topology

Visão inicial:

``` text
Internet
   │
   ▼
Vercel / Next.js
   │
   ├────────► Supabase
   │            ├─ PostgreSQL
   │            ├─ Auth
   │            └─ Storage
   │
   ├────────► Inngest
   │
   ├────────► SMTP
   │
   └────────► AI / External APIs
```

------------------------------------------------------------------------

# 61. Environment isolation

Cada ambiente deve possuir configuração própria.

Evitar:

-   Production DB em Development;
-   Production secrets em Preview;
-   compartilhamento indevido de BYOK;
-   dados reais em demo sem autorização.

------------------------------------------------------------------------

# 62. Feature flags

Podem ser adotadas para:

-   rollout;
-   experimental AI;
-   Tenant-specific enablement;
-   migration control.

Não usar flags como substituto permanente de arquitetura limpa.

------------------------------------------------------------------------

# 63. Dependency direction

Preferência:

``` text
Presentation
    ↓
Application
    ↓
Domain
```

Infrastructure implementa contratos necessários.

O domínio não deve depender diretamente de SDKs externos sempre que isso
prejudicar testabilidade/boundary.

------------------------------------------------------------------------

# 64. External SDK isolation

Exemplos:

``` text
OpenAI SDK
Supabase-specific services
SMTP library
External API clients
```

devem permanecer próximos da infraestrutura/adapters.

------------------------------------------------------------------------

# 65. Shared kernel

Código compartilhado deve ser limitado a conceitos realmente
transversais.

Exemplos possíveis:

-   IDs;
-   dates;
-   Result/Error;
-   authorization context;
-   pagination;
-   audit primitives.

Evitar pasta `utils` sem ownership.

------------------------------------------------------------------------

# 66. Cross-module communication

Preferência inicial:

1.  application orchestration;
2.  explicit service contract;
3.  domain event quando útil.

Evitar acesso acidental direto à persistência de outro módulo sem
boundary.

------------------------------------------------------------------------

# 67. Eventual consistency

Aceitável para:

-   notification;
-   analytics;
-   AI summaries;
-   non-critical derived views;
-   external sync.

Não aceitável para invariantes da publicação oficial.

------------------------------------------------------------------------

# 68. Data consistency

Quando o usuário recebe sucesso de uma operação crítica, o estado
necessário para afirmar esse sucesso deve estar persistido.

------------------------------------------------------------------------

# 69. Concurrency strategy

Casos críticos devem considerar:

-   optimistic concurrency;
-   version fields;
-   transaction locks;
-   state preconditions.

A técnica será escolhida por domínio.

------------------------------------------------------------------------

# 70. Example --- concurrent publication

Se dois usuários tentarem publicar o mesmo Status:

``` text
Request A
Request B
```

o sistema deve impedir publicações conflitantes ou produzir ordem
consistente conforme a Spec.

------------------------------------------------------------------------

# 71. Example --- concurrent Decision

Uma Decision já decidida não deve ser silenciosamente sobrescrita por
uma requisição baseada em estado antigo.

------------------------------------------------------------------------

# 72. Scalability strategy

Ordem preferencial:

``` text
Efficient Queries
      ↓
Indexes
      ↓
Pagination
      ↓
Background Processing
      ↓
Caching when justified
      ↓
Read optimization/materialization
      ↓
Service extraction only if justified
```

------------------------------------------------------------------------

# 73. Performance hotspots prováveis

Monitorar:

-   Portfolio aggregation;
-   My Day;
-   Project Dashboard;
-   Time Machine comparison;
-   Reports;
-   large imports;
-   AI context retrieval.

------------------------------------------------------------------------

# 74. Database access strategy

Acesso deve ser centralizado por patterns consistentes.

Não espalhar queries sensíveis sem:

-   Tenant context;
-   authorization;
-   error handling;
-   observability.

------------------------------------------------------------------------

# 75. RLS

Row Level Security pode atuar como defesa adicional.

Não deve ser considerada substituta automática de autorização de
aplicação.

A estratégia final será detalhada em Data/Security Architecture e ADR.

------------------------------------------------------------------------

# 76. API exposure

Nem todo serviço interno precisa ser API pública.

Separar:

``` text
Internal Application Contract
```

de:

``` text
External/Public API Contract
```

------------------------------------------------------------------------

# 77. Versioning

APIs externas, imports e integrações devem possuir estratégia de
versionamento quando estabilidade contratual exigir.

------------------------------------------------------------------------

# 78. Backward compatibility

Alterações que afetam:

-   integrations;
-   exported formats;
-   public APIs;
-   persisted events;

precisam considerar compatibilidade e migração.

------------------------------------------------------------------------

# 79. Resilience

Princípios:

-   timeouts;
-   retries controlados;
-   idempotência;
-   circuit-breaking apenas quando necessário;
-   failure isolation;
-   graceful degradation.

------------------------------------------------------------------------

# 80. Recovery

O sistema deve permitir recuperar:

-   failed jobs;
-   failed imports;
-   failed integrations;
-   failed notifications;

sem repetir efeitos já confirmados.

------------------------------------------------------------------------

# 81. Architecture evolution triggers

Reavaliar arquitetura quando houver evidência de:

-   volume elevado;
-   latency persistente;
-   team scaling;
-   isolation requirement;
-   integration volume;
-   search complexity;
-   AI workload growth;
-   operational bottleneck.

------------------------------------------------------------------------

# 82. Não gatilhos

Não mudar arquitetura apenas porque:

-   uma tecnologia está popular;
-   concorrente usa;
-   parece mais enterprise;
-   microservices parecem mais modernos;
-   um componente pode ser útil algum dia.

------------------------------------------------------------------------

# 83. Architecture decision candidates

Este documento indica ADRs prováveis:

``` text
ADR — Modular Monolith
ADR — Next.js Application Architecture
ADR — Supabase/PostgreSQL
ADR — Tenant Isolation Strategy
ADR — RLS Strategy
ADR — Inngest Background Workflows
ADR — Snapshot Persistence Model
ADR — AI Provider Abstraction
ADR — BYOK Secret Storage
ADR — Integration Adapter Pattern
```

A lista será refinada em `/docs/03-adrs/`.

------------------------------------------------------------------------

# 84. Fitness functions

Possíveis checks automatizados:

-   cross-tenant tests;
-   forbidden dependency checks;
-   immutable Snapshot tests;
-   authorization coverage;
-   migration checks;
-   secret scanning;
-   AI provider response validation.

------------------------------------------------------------------------

# 85. System Architecture invariants

1.  O sistema começa como monólito modular.
2.  PostgreSQL é a fonte transacional principal.
3.  Tenant context é obrigatório para dados tenant-scoped.
4.  Authorization é server-side.
5.  Módulos derivados não são fontes.
6.  Snapshot publicado é imutável.
7.  Publicação é transacional.
8.  Jobs assíncronos não completam invariantes críticas.
9.  IA é acessada por gateway/adapter.
10. IA não amplia acesso.
11. Integrações possuem adapters.
12. Integrações possuem source authority.
13. Audit é distinto de log.
14. Secrets não são expostos ao cliente.
15. Falha de IA não impede o core.
16. Complexidade distribuída exige evidência.

------------------------------------------------------------------------

# 86. Relação com próximos documentos

Este documento alimenta:

``` text
data-architecture.md
security-architecture.md
ai-architecture.md
integration-architecture.md
deployment-architecture.md
```

e posteriormente:

``` text
ADRs
Specs
Data
Security
API
AI
Integrations
Testing
DevOps
```

------------------------------------------------------------------------

# 87. Referências

-   `/docs/02-architecture/README.md`
-   `/docs/01-product/PDD.md`
-   `/docs/01-product/module-catalog.md`
-   `/docs/01-product/mvp-scope.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`

------------------------------------------------------------------------

# 88. Status

**Documento:** System Architecture\
**Status:** Approved\
**Responsabilidade:** definir a arquitetura lógica e de runtime do PMO
Control, incluindo componentes, boundaries, fluxos, consistência,
modularidade, processamento assíncrono, IA e integrações.
