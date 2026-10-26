# PMO Control --- Architecture

**Documento:** `README.md`\
**Camada:** Architecture\
**Status:** Approved\
**Tipo:** Índice e diretrizes da arquitetura

------------------------------------------------------------------------

## 1. Objetivo

Esta pasta documenta a arquitetura do PMO Control.

Seu propósito é transformar as decisões de produto, domínio, segurança e
MVP em uma arquitetura implementável, evolutiva, auditável e compatível
com Spec-Driven Development.

A arquitetura deve responder:

-   quais são os principais componentes do sistema;
-   como as responsabilidades são distribuídas;
-   onde os dados vivem;
-   como o isolamento entre Tenants é garantido;
-   como autenticação e autorização são aplicadas;
-   como operações síncronas e assíncronas se relacionam;
-   como IA é integrada sem contaminar o domínio;
-   como integrações externas são isoladas;
-   como o sistema é implantado e operado;
-   quais decisões exigem ADR.

------------------------------------------------------------------------

# 2. Princípio arquitetural central

A arquitetura deve servir ao domínio.

``` text
Product
   ↓
Domain Rules
   ↓
Specifications
   ↓
Architecture
   ↓
Implementation
```

Não inverter a relação para:

``` text
Technology
   ↓
Product forced to fit technology
```

------------------------------------------------------------------------

# 3. Objetivos arquiteturais

A arquitetura deve favorecer:

1.  segurança;
2.  isolamento multi-tenant;
3.  simplicidade operacional;
4.  modularidade;
5.  rastreabilidade;
6.  testabilidade;
7.  evolução incremental;
8.  baixo acoplamento;
9.  consistência transacional onde necessária;
10. processamento assíncrono onde apropriado;
11. observabilidade;
12. integração segura de IA;
13. custo compatível com o estágio do produto.

------------------------------------------------------------------------

# 4. Arquitetura do MVP

Stack inicialmente selecionada:

``` text
Frontend / Application
Next.js + TypeScript

Hosting
Vercel

Database
Supabase / PostgreSQL

Authentication
Supabase Auth

Object Storage
Supabase Storage

Background Workflows
Inngest

Repository
GitHub

E-mail
SMTP configurável

AI
BYOK per Tenant
```

Decisões arquiteturais definitivas serão registradas em ADRs quando
necessário.

------------------------------------------------------------------------

# 5. Filosofia do MVP

O MVP deve evitar infraestrutura prematura.

Não introduzir sem necessidade comprovada:

``` text
Redis
Kafka
RabbitMQ
Neo4j
Elasticsearch
Kubernetes
Firebase
```

A ausência desses componentes não impede evolução futura.

------------------------------------------------------------------------

# 6. Modelo arquitetural inicial

O PMO Control começa como uma aplicação web modular com banco relacional
compartilhado e isolamento lógico forte por Tenant.

Visão simplificada:

``` text
Browser
   │
   ▼
Next.js Application
   │
   ├── Authentication / Authorization
   ├── Domain Modules
   ├── Application Services
   ├── API / Server Actions
   ├── AI Gateway
   └── Integration Layer
   │
   ▼
Supabase / PostgreSQL
   │
   ├── Relational Data
   ├── Tenant Isolation
   ├── RLS where appropriate
   └── Storage
   │
   ├──────────────► Inngest
   │                 │
   │                 ├── notifications
   │                 ├── AI jobs
   │                 ├── imports
   │                 └── derived processing
   │
   └──────────────► External Services
```

------------------------------------------------------------------------

# 7. Arquitetura modular

Os módulos funcionais definidos em:

``` text
/docs/01-product/module-catalog.md
```

devem possuir fronteiras claras na implementação.

Exemplos:

``` text
projects
milestones
deliverables
risks
issues
actions
decisions
status
snapshots
financial
resources
documents
reports
ai
```

Modularidade não exige microservices.

------------------------------------------------------------------------

# 8. Monólito modular

A estratégia inicial recomendada é:

``` text
Modular Monolith
```

Razões:

-   menor complexidade operacional;
-   transações mais simples;
-   velocidade de desenvolvimento;
-   domínio ainda evoluindo;
-   deploy simplificado;
-   menor custo;
-   possibilidade de extração futura quando justificada.

------------------------------------------------------------------------

# 9. Microservices

Microservices não fazem parte da arquitetura inicial.

Um domínio só deve ser extraído quando existirem motivos concretos,
como:

-   escala independente;
-   boundary estável;
-   equipe independente;
-   requisitos operacionais específicos;
-   isolamento técnico necessário;
-   carga incompatível com aplicação principal.

------------------------------------------------------------------------

# 10. Camadas conceituais

``` text
Presentation
      ↓
Application
      ↓
Domain
      ↓
Data / Infrastructure
```

Com capacidades transversais:

``` text
Security
Audit
Observability
Notifications
AI
Integrations
```

------------------------------------------------------------------------

# 11. Presentation Layer

Responsável por:

-   UI;
-   forms;
-   navigation;
-   visualization;
-   user feedback;
-   client-side interaction.

Não é responsável por decidir autorização.

------------------------------------------------------------------------

# 12. Application Layer

Responsável por:

-   use cases;
-   orchestration;
-   authorization calls;
-   transactions;
-   workflows;
-   coordination between domain components.

Exemplo:

``` text
PublishStatus
```

é um caso de uso, não apenas um update de tabela.

------------------------------------------------------------------------

# 13. Domain Layer

Responsável por:

-   entidades;
-   invariantes;
-   estados;
-   regras;
-   transitions;
-   domain semantics.

Exemplos:

``` text
Risk materialization
RAG override
Status publication
Decision lifecycle
Baseline change
```

------------------------------------------------------------------------

# 14. Infrastructure Layer

Responsável por:

-   PostgreSQL;
-   Storage;
-   SMTP;
-   Inngest;
-   AI providers;
-   external APIs;
-   telemetry;
-   deployment infrastructure.

Infraestrutura não deve definir regras de negócio.

------------------------------------------------------------------------

# 15. Source of Truth

Entidades operacionais são fontes primárias.

Exemplos:

``` text
Risk
Issue
Action
Decision
Milestone
Deliverable
Financial Record
```

Dashboards e relatórios são derivados.

------------------------------------------------------------------------

# 16. Current State vs Published State

A arquitetura deve distinguir:

``` text
Current Operational State
```

de:

``` text
Published Historical State
```

O segundo é preservado por Snapshot.

------------------------------------------------------------------------

# 17. Snapshot architecture

Na publicação:

``` text
Validate
   ↓
Authorize
   ↓
Calculate KPIs
   ↓
Calculate RAG
   ↓
Consolidate
   ↓
Create Snapshot
   ↓
Register Publication/Audit
   ↓
Commit
```

Snapshot oficial deve ser criado na mesma fronteira de consistência da
publicação.

------------------------------------------------------------------------

# 18. Trabalho pós-publicação

Após commit, trabalhos derivados podem ser assíncronos:

``` text
Notifications
AI Summary
Report Preparation
Derived Cache
Analytics
```

Falha nesses processos não invalida uma publicação já confirmada.

------------------------------------------------------------------------

# 19. Multi-tenancy

Tenant é boundary fundamental.

Todo dado tenant-scoped deve possuir relação inequívoca com Tenant.

Princípio:

``` text
No Tenant Context
      ↓
No Tenant Data Access
```

------------------------------------------------------------------------

# 20. Tenant isolation

Defesa em profundidade:

``` text
Application Authorization
        +
Tenant-aware Queries
        +
Database Constraints
        +
RLS where appropriate
        +
Automated Isolation Tests
```

Não depender de um único mecanismo.

------------------------------------------------------------------------

# 21. Authorization

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

A autorização deve ocorrer no servidor.

------------------------------------------------------------------------

# 22. Sensitive permissions

Exemplos:

``` text
financial.view
financial.edit
resources.view
resources.edit
documents.confidential.view
status.update.publish
baseline.change
projects.{projectId}.rag-evaluations.override
decision.approve
report.export
```

Deny by default.

------------------------------------------------------------------------

# 23. Security boundary

Nunca confiar em:

-   tenant ID enviado pelo cliente;
-   role informado pelo frontend;
-   resource ownership inferido apenas da URL;
-   UI hidden state;
-   IDs sem autorização server-side.

------------------------------------------------------------------------

# 24. Data architecture

PostgreSQL é o sistema transacional principal do MVP.

A modelagem deve privilegiar:

-   integridade referencial;
-   constraints;
-   versioned migrations;
-   tenant ownership;
-   indexes baseados em queries reais;
-   auditability;
-   temporal requirements.

Detalhamento:

``` text
/docs/02-architecture/data-architecture.md
```

------------------------------------------------------------------------

# 25. Storage architecture

Supabase Storage poderá armazenar artefatos/documentos quando aplicável.

Requisitos:

-   tenant isolation;
-   authorized access;
-   metadata no banco;
-   classification;
-   safe filenames/paths;
-   controlled download;
-   retention considerations.

------------------------------------------------------------------------

# 26. AI architecture

IA deve ser uma camada integrada, mas não autoridade do domínio.

Fluxo conceitual:

``` text
User
 ↓
Authorization
 ↓
Context Builder
 ↓
Data Classification / Policy
 ↓
AI Gateway
 ↓
Provider
 ↓
Validation
 ↓
Response
```

Detalhamento:

``` text
/docs/02-architecture/ai-architecture.md
```

------------------------------------------------------------------------

# 27. BYOK

Modelo inicial:

``` text
Tenant
  ↓
AI Configuration
  ↓
Encrypted/Protected Credential
  ↓
Provider Adapter
```

Chaves nunca devem ser retornadas integralmente ao cliente após
armazenamento.

------------------------------------------------------------------------

# 28. AI provider abstraction

A aplicação não deve espalhar chamadas diretas a providers pelo domínio.

Preferir:

``` text
Domain/Application
       ↓
AI Service / Gateway
       ↓
Provider Adapter
       ↓
OpenAI / Future Providers
```

------------------------------------------------------------------------

# 29. Integrations architecture

Integrações externas devem utilizar adapters/contracts.

Exemplo:

``` text
PMO Control Domain
       ↓
Integration Service
       ↓
Provider Adapter
       ↓
External System
```

Detalhamento:

``` text
/docs/02-architecture/integration-architecture.md
```

------------------------------------------------------------------------

# 30. Source Authority

Toda integração deve declarar:

-   system of record;
-   direction;
-   mapped fields;
-   sync behavior;
-   conflict policy;
-   failure behavior.

Evitar bidirectional sync sem regras explícitas.

------------------------------------------------------------------------

# 31. Background processing

Inngest será utilizado para workloads assíncronos apropriados.

Exemplos:

-   notifications;
-   AI processing;
-   imports;
-   scheduled workflows;
-   retryable external calls;
-   derived processing.

------------------------------------------------------------------------

# 32. Regra de consistência

Não mover para background uma operação que precise fazer parte da
transação oficial do domínio.

Exemplo:

``` text
Create official Snapshot
```

não deve depender de um job eventual após publicação.

------------------------------------------------------------------------

# 33. Idempotência

Operações assíncronas e integrações devem considerar idempotência.

Especialmente:

-   imports;
-   notifications;
-   external sync;
-   webhook processing;
-   AI post-processing quando houver side effect.

------------------------------------------------------------------------

# 34. Retry

Retries devem diferenciar:

``` text
Transient Failure
Permanent Failure
Business Rejection
Authorization Failure
```

Não repetir indefinidamente erros permanentes.

------------------------------------------------------------------------

# 35. APIs

A camada de API será definida em:

``` text
/docs/08-api/
```

Princípios arquiteturais:

-   contracts claros;
-   authorization server-side;
-   validation;
-   consistent errors;
-   tenant-aware context;
-   pagination;
-   idempotency quando necessária;
-   observability.

------------------------------------------------------------------------

# 36. Events

Eventos podem representar fatos relevantes do domínio.

Exemplos:

``` text
StatusPublished
RiskEscalated
DecisionMade
ActionOverdue
SnapshotCreated
```

No MVP, evento não implica automaticamente event broker dedicado.

------------------------------------------------------------------------

# 37. Domain events vs integration events

Separar conceitualmente:

``` text
Domain Event
```

de:

``` text
Integration Event
```

Nem todo evento interno precisa sair da aplicação.

------------------------------------------------------------------------

# 38. Audit architecture

Audit é domínio de governança, não simples log.

Deve registrar eventos relevantes com:

-   actor;
-   action;
-   resource;
-   tenant;
-   timestamp;
-   reason;
-   before/after quando aplicável;
-   correlation.

------------------------------------------------------------------------

# 39. Technical logs

Logs técnicos servem para:

-   troubleshooting;
-   observability;
-   performance;
-   security diagnostics.

Não substituem Audit Log.

------------------------------------------------------------------------

# 40. Observability

MVP deve prever:

-   structured logs;
-   error tracking;
-   request/correlation IDs;
-   job monitoring;
-   external call monitoring;
-   AI provider telemetry;
-   health indicators.

------------------------------------------------------------------------

# 41. Error handling

Erros devem ser classificados.

Exemplos:

``` text
ValidationError
AuthorizationError
NotFoundError
ConflictError
BusinessRuleError
ExternalDependencyError
UnexpectedError
```

Mensagens externas não devem expor internals sensíveis.

------------------------------------------------------------------------

# 42. Concurrency

Operações sensíveis devem considerar concorrência.

Exemplos:

-   Status publication;
-   Decision update;
-   RAG override;
-   Baseline change;
-   financial update.

Estratégias serão definidas por caso.

------------------------------------------------------------------------

# 43. Transactions

Usar transação quando múltiplas mudanças precisam ser atomicamente
consistentes.

Exemplo principal:

``` text
Status Publication
```

------------------------------------------------------------------------

# 44. Caching

Cache não é requisito inicial.

Adicionar apenas quando:

-   performance medida exigir;
-   invalidação for compreendida;
-   dados sensíveis permanecerem isolados.

Não introduzir Redis apenas por antecipação.

------------------------------------------------------------------------

# 45. Search

PostgreSQL deve atender busca inicial.

Avaliar mecanismo dedicado apenas quando requisitos reais justificarem.

------------------------------------------------------------------------

# 46. Graph relationships

Dependencies e relações entre entidades podem ser modeladas inicialmente
em PostgreSQL.

Neo4j não é requisito para representar grafos básicos.

------------------------------------------------------------------------

# 47. Deployment

Deploy inicial:

``` text
GitHub
  ↓
CI
  ↓
Vercel
```

Banco e serviços relacionados:

``` text
Supabase
Inngest
SMTP
AI Providers
```

Detalhamento:

``` text
/docs/02-architecture/deployment-architecture.md
```

------------------------------------------------------------------------

# 48. Environments

Prever ao menos:

``` text
Development
Preview/Test
Production
```

A estratégia exata será definida em DevOps.

------------------------------------------------------------------------

# 49. Configuration

Configuração deve ser externalizada.

Exemplos:

-   environment;
-   URLs;
-   credentials;
-   feature flags quando adotadas;
-   AI configuration;
-   SMTP;
-   integration secrets.

------------------------------------------------------------------------

# 50. Secrets

Nunca:

-   commit em Git;
-   retornar ao frontend;
-   registrar em logs;
-   incluir em Audit payloads;
-   armazenar em plaintext sem mecanismo adequado.

------------------------------------------------------------------------

# 51. Database migrations

Toda mudança de schema deve ser versionada.

Evitar alterações manuais não rastreadas em Production.

------------------------------------------------------------------------

# 52. Backups e recovery

A arquitetura deve possuir estratégia documentada compatível com
serviços escolhidos.

Detalhamento será tratado em Architecture/DevOps.

------------------------------------------------------------------------

# 53. Testing architecture

A arquitetura deve facilitar:

-   unit tests;
-   domain tests;
-   integration tests;
-   database tests;
-   authorization tests;
-   tenant isolation tests;
-   API tests;
-   end-to-end tests.

------------------------------------------------------------------------

# 54. Testes arquiteturalmente críticos

Obrigatórios:

``` text
Cross-tenant isolation
Authorization
Status transaction
Snapshot immutability
RAG override authorization
Sensitive data access
AI authorization boundaries
```

------------------------------------------------------------------------

# 55. Performance

Performance deve ser medida.

Não otimizar prematuramente.

Princípios:

-   evitar N+1;
-   índices orientados por query;
-   paginação;
-   limitar payloads;
-   background para workloads apropriados;
-   profiling antes de complexidade adicional.

------------------------------------------------------------------------

# 56. Scalability

Escala inicial:

``` text
Scale Up + Managed Platform + Efficient Queries
```

antes de:

``` text
Distributed Complexity
```

------------------------------------------------------------------------

# 57. Failure isolation

Falhas em serviços auxiliares não devem derrubar funções centrais quando
possível.

Exemplo:

``` text
AI unavailable
```

não deve impedir:

``` text
Status publication
```

------------------------------------------------------------------------

# 58. Graceful degradation

Exemplos:

-   AI indisponível → mostrar funcionalidade core sem IA;
-   SMTP indisponível → registrar/retry notification;
-   report async failure → permitir retry;
-   external integration unavailable → preservar estado local e
    sinalizar sync issue.

------------------------------------------------------------------------

# 59. Security architecture

Documento específico:

``` text
/docs/02-architecture/security-architecture.md
```

Cobrirá:

-   trust boundaries;
-   authentication;
-   authorization;
-   tenant isolation;
-   secrets;
-   storage;
-   API security;
-   secure AI;
-   integration security;
-   audit;
-   threat considerations.

------------------------------------------------------------------------

# 60. Architecture Decision Records

Decisões arquiteturais relevantes serão registradas em:

``` text
/docs/03-adrs/
```

Exemplos candidatos:

-   modular monolith;
-   Supabase;
-   tenant isolation strategy;
-   RLS strategy;
-   Inngest;
-   snapshot model;
-   AI provider abstraction;
-   BYOK storage;
-   event strategy.

------------------------------------------------------------------------

# 61. Quando criar ADR

Criar ADR quando a decisão:

-   afeta múltiplos módulos;
-   é difícil de reverter;
-   possui trade-offs relevantes;
-   altera segurança;
-   altera modelo de dados;
-   altera infraestrutura;
-   define padrão arquitetural.

------------------------------------------------------------------------

# 62. Architecture vs Specification

Architecture responde:

> **Como o sistema é estruturado para suportar o comportamento?**

Specification responde:

> **Qual comportamento o sistema precisa possuir?**

Não misturar os dois níveis.

------------------------------------------------------------------------

# 63. Architecture vs Implementation

Arquitetura não deve prescrever detalhes de código sem necessidade.

Exemplo:

Arquitetura pode definir:

``` text
Provider Adapter
```

A implementação decidirá detalhes internos compatíveis com os contratos.

------------------------------------------------------------------------

# 64. Bounded responsibilities

Exemplo:

``` text
Project Control Center
```

é composição.

Não deve possuir cópias independentes de:

``` text
Risks
Issues
Milestones
Actions
```

------------------------------------------------------------------------

# 65. Derived views

Dashboards devem ser projeções.

Podem utilizar:

-   queries;
-   views;
-   materialized structures;
-   derived tables;

desde que exista clareza sobre a fonte e consistência.

A decisão será baseada em necessidade real.

------------------------------------------------------------------------

# 66. Architecture evolution

A arquitetura deve permitir evolução sem assumir que toda capacidade
futura precisa estar implementada agora.

Exemplo:

``` text
AI Provider Interface
```

pode existir desde o MVP.

Não é necessário implementar cinco providers no MVP.

------------------------------------------------------------------------

# 67. Architecture Fitness Functions

Ao longo do desenvolvimento, alguns invariantes podem ser validados
automaticamente.

Exemplos:

-   nenhum acesso cross-tenant;
-   módulos não importam infraestrutura proibida;
-   sensitive endpoints exigem autorização;
-   Snapshot não sofre update;
-   provider credentials não aparecem em responses.

------------------------------------------------------------------------

# 68. Non-functional requirements

NFRs detalhados serão especificados posteriormente.

Categorias:

-   security;
-   availability;
-   performance;
-   scalability;
-   recoverability;
-   maintainability;
-   observability;
-   accessibility;
-   privacy.

------------------------------------------------------------------------

# 69. Dependência documental

A arquitetura depende de:

``` text
00-foundation
01-product
```

e alimentará:

``` text
03-adrs
04-specs
06-data
07-security
08-api
09-ai
10-integrations
11-testing
12-devops
13-guides
```

------------------------------------------------------------------------

# 70. Arquivos desta pasta

``` text
/docs/02-architecture/
├── README.md
├── system-architecture.md
├── data-architecture.md
├── security-architecture.md
├── ai-architecture.md
├── integration-architecture.md
└── deployment-architecture.md
```

------------------------------------------------------------------------

# 71. Responsabilidade dos documentos

## `README.md`

Visão geral, princípios, boundaries e índice.

## `system-architecture.md`

Arquitetura lógica e runtime do sistema.

## `data-architecture.md`

Persistência, tenancy, histórico, consistência e fluxos de dados.

## `security-architecture.md`

Trust boundaries, auth, authorization, isolation e proteção.

## `ai-architecture.md`

BYOK, providers, context, policy, grounding e safety.

## `integration-architecture.md`

Adapters, source authority, sync, webhooks e falhas.

## `deployment-architecture.md`

Ambientes, deploy, runtime, configuração, observabilidade e recovery.

------------------------------------------------------------------------

# 72. Ordem recomendada

``` text
README
  ↓
System Architecture
  ↓
Data Architecture
  ↓
Security Architecture
  ↓
AI Architecture
  ↓
Integration Architecture
  ↓
Deployment Architecture
```

------------------------------------------------------------------------

# 73. Invariantes arquiteturais

1.  Tenant isolation é obrigatório.
2.  Authorization ocorre no servidor.
3.  UI não é security boundary.
4.  Published Snapshot é imutável.
5.  AI não amplia acesso.
6.  AI não é requisito para core correctness.
7.  Audit é diferente de technical logging.
8.  Dashboards não são fontes paralelas.
9.  Background jobs não quebram atomicidade do domínio.
10. Secrets não chegam ao cliente.
11. Integrações possuem source authority.
12. Infrastructure complexity precisa de evidência.
13. Modularidade não exige microservices.
14. PostgreSQL é a fonte transacional principal do MVP.
15. Toda decisão arquitetural relevante deve ser rastreável.

------------------------------------------------------------------------

# 74. Critério de conclusão da pasta

A pasta `/docs/02-architecture/` estará concluída quando os sete
documentos:

-   estiverem gerados;
-   estiverem consistentes entre si;
-   refletirem PDD/MVP;
-   possuírem boundaries claros;
-   identificarem decisões que exigem ADR;
-   fornecerem base suficiente para Specs e implementação.

------------------------------------------------------------------------

# 75. Referências

-   `/docs/00-foundation/`
-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/functional-map.md`
-   `/docs/01-product/module-catalog.md`
-   `/docs/01-product/mvp-scope.md`
-   `/docs/01-product/roadmap.md`
-   `/docs/03-adrs/`
-   `/docs/04-specs/`

------------------------------------------------------------------------

# 76. Status

**Documento:** Architecture README\
**Status:** Approved\
**Responsabilidade:** estabelecer a visão, os princípios, as fronteiras,
a stack inicial e a organização documental da arquitetura do PMO
Control.
