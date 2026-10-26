# PMO Control --- Architecture Decision Records (ADRs)

**Diretório:** `/docs/03-adrs/`\
**Status:** Approved\
**Tipo:** Índice e governança de decisões arquiteturais

## 1. Objetivo

Este diretório registra as decisões arquiteturais relevantes do PMO
Control por meio de **Architecture Decision Records (ADRs)**.

Os documentos de `/docs/02-architecture/` descrevem a arquitetura. Os
ADRs registram **por que decisões importantes foram tomadas**, quais
alternativas foram consideradas, seus trade-offs, consequências e
gatilhos de reavaliação.

## 2. Princípio

``` text
Architecture describes the system.
ADR explains the decision.
```

Um ADR deve responder: qual problema exigia uma decisão; qual contexto
existia; quais alternativas eram viáveis; qual alternativa foi
escolhida; por quê; quais consequências foram aceitas; e quando a
decisão deve ser reavaliada.

## 3. Quando criar um ADR

Criar ADR quando a decisão: - afeta múltiplos módulos; - possui impacto
relevante de segurança; - cria restrição arquitetural; - envolve
trade-off significativo; - é difícil ou cara de reverter; - define
tecnologia estrutural; - estabelece padrão transversal; - precisa
permanecer compreensível no futuro.

Não criar ADR para detalhes triviais de implementação, pequenas escolhas
de UI ou regras funcionais já pertencentes às Specs.

## 4. Status

Status possíveis:

``` text
Proposed
Accepted
Superseded
Deprecated
Rejected
```

Os ADRs desta baseline, derivados da arquitetura já aprovada, serão
criados como **Accepted**.

## 5. Evolução e histórico

Um ADR aceito não deve ser silenciosamente reescrito quando a decisão
mudar.

``` text
ADR antigo
Status: Superseded
Superseded by: ADR novo
```

Git preserva versões do arquivo; o relacionamento semântico entre
decisões também deve permanecer explícito.

## 6. Numeração

Formato:

``` text
ADR-001
ADR-002
ADR-003
```

Arquivos:

``` text
001-modular-monolith.md
002-nextjs-typescript.md
```

A numeração não é reutilizada.

## 7. Estrutura padrão

Cada ADR deve conter, conforme aplicável:

``` text
Title
Status
Date
Context
Decision Drivers
Options Considered
Decision
Rationale
Consequences
Security Implications
Operational Implications
Rejected Alternatives
Revisit Triggers
References
```

## 8. Relação com SDD

``` text
Product Decision
      ↓
Architecture
      ↓
ADR when structurally relevant
      ↓
Functional / Technical Specification
      ↓
Implementation
      ↓
Tests
```

Specs devem referenciar ADRs quando dependerem de decisões arquiteturais
relevantes.

# 9. Catálogo inicial

A baseline de `/docs/03-adrs/` terá **13 arquivos: este README + 12
ADRs**.

  -------------------------------------------------------------------------------------------------------------
  ADR                     Arquivo                                            Decisão
  ----------------------- -------------------------------------------------- ----------------------------------
  ---                     `README.md`                                        Governança e catálogo de ADRs

  ADR-001                 `001-modular-monolith.md`                          Monólito modular como arquitetura
                                                                             inicial

  ADR-002                 `002-nextjs-typescript.md`                         Next.js + TypeScript como
                                                                             aplicação principal

  ADR-003                 `003-supabase-postgresql.md`                       Supabase/PostgreSQL/Auth/Storage
                                                                             no MVP

  ADR-004                 `004-multi-tenant-data-isolation.md`               Isolamento lógico multi-tenant com
                                                                             `tenant_id` e defesa em
                                                                             profundidade

  ADR-005                 `005-row-level-security.md`                        RLS como camada adicional, sem
                                                                             substituir autorização da
                                                                             aplicação

  ADR-006                 `006-authorization-model.md`                       Tenant + Role + Scope +
                                                                             Permission + Data Policy +
                                                                             Workflow Rule

  ADR-007                 `007-immutable-status-snapshots.md`                Status publicados persistidos como
                                                                             Snapshots imutáveis

  ADR-008                 `008-inngest-background-workflows.md`              Inngest para workflows assíncronos
                                                                             do MVP

  ADR-009                 `009-ai-gateway-byok.md`                           AI Gateway + BYOK por Tenant +
                                                                             abstração de provider

  ADR-010                 `010-integration-adapter-pattern.md`               Adapters/Anti-Corruption Layer
                                                                             para integrações

  ADR-011                 `011-vercel-deployment.md`                         Vercel como runtime/deployment
                                                                             inicial

  ADR-012                 `012-no-premature-distributed-infrastructure.md`   Não introduzir infraestrutura
                                                                             distribuída sem evidência
  -------------------------------------------------------------------------------------------------------------

# 10. Resumo das decisões

## ADR-001 --- Modular Monolith

``` text
PMO Control starts as a modular monolith.
```

Favorece menor complexidade operacional, transações locais, velocidade
de desenvolvimento e boundaries internos claros, preservando futura
extração seletiva.

## ADR-002 --- Next.js + TypeScript

``` text
Next.js + TypeScript
```

como stack principal da aplicação web e camada server-side do MVP.

## ADR-003 --- Supabase + PostgreSQL

``` text
Supabase
 ├── PostgreSQL
 ├── Auth
 └── Storage
```

como plataforma inicial de dados.

## ADR-004 --- Multi-Tenant Data Isolation

``` text
Shared relational platform
+
Explicit Tenant ownership
+
tenant_id
+
Tenant-safe queries/constraints
```

com isolamento lógico forte.

## ADR-005 --- Row Level Security

``` text
Application Authorization
+
RLS Defense-in-Depth
```

RLS não substitui o authorization model.

## ADR-006 --- Authorization Model

``` text
Tenant
+ Role
+ Scope
+ Permission
+ Data Policy
+ Workflow Rule
```

com deny by default.

## ADR-007 --- Immutable Status Snapshots

``` text
Operational State
      ↓
Status Publication
      ↓
Immutable Snapshot
```

para verdade histórica e Time Machine.

## ADR-008 --- Inngest

Inngest será usado para jobs, retries, schedules e workflows assíncronos
iniciais, sem broker dedicado no MVP.

## ADR-009 --- AI Gateway + BYOK

``` text
AI Use Case
   ↓
AI Gateway
   ↓
Provider Adapter
   ↓
Tenant BYOK
```

evitando acoplamento do domínio a provider único.

## ADR-010 --- Integration Adapter Pattern

``` text
External Provider
      ↓
Adapter / Anti-Corruption Layer
      ↓
Internal Contract
      ↓
Domain
```

com Source Authority explícita.

## ADR-011 --- Vercel

``` text
GitHub
  ↓
CI
  ↓
Vercel
```

como estratégia inicial de hosting/deployment da aplicação Next.js.

## ADR-012 --- No Premature Distributed Infrastructure

Não introduzir inicialmente:

``` text
Microservices
Kubernetes
Kafka
RabbitMQ
Redis
Elasticsearch
Neo4j
Firebase
```

salvo necessidade comprovada.

A ausência dessas tecnologias é uma decisão arquitetural intencional.

# 11. Decisões futuras

Novos ADRs poderão ser adicionados para: - representação física de
Snapshot; - armazenamento de secrets BYOK; - transactional outbox; -
semantic/vector retrieval; - enterprise SSO; - public API; -
observability stack; - data warehouse; - regional deployment; - agent
architecture.

Criá-los apenas quando a decisão realmente precisar ser tomada.

# 12. Relação com Architecture

Fonte principal:

``` text
/docs/02-architecture/
```

Os ADRs devem apontar para os documentos arquiteturais que
contextualizam cada decisão.

# 13. Relação com Specs

Specs em:

``` text
/docs/04-specs/
```

devem respeitar ADRs Accepted.

Se uma Spec exigir arquitetura incompatível com um ADR vigente, a
decisão deve ser formalmente revisada antes da implementação.

# 14. Relação com implementação

Código deve refletir os boundaries definidos pelos ADRs.

Exemplo: se ADR-010 define Integration Adapter Pattern, objetos
específicos de SDKs externos não devem contaminar o domínio.

# 15. Revisão

Revisar ADR quando existir gatilho real, como: - limite de plataforma; -
requisito regulatório; - mudança relevante de escala; - novo SLA; -
custo incompatível; - nova necessidade de isolamento; - evidência
operacional contrária à decisão.

# 16. Trade-offs

Todo ADR deve registrar:

``` text
Benefits
Trade-offs
Risks
Operational Impact
Future Constraints
```

Uma decisão arquitetural sem consequências negativas explícitas
provavelmente está incompleta.

# 17. Critério de conclusão da pasta

A baseline de `/docs/03-adrs/` estará concluída quando:

``` text
README
+
12 ADRs
=
13/13 arquivos Accepted
```

Novos ADRs poderão ser adicionados posteriormente sem invalidar a
baseline.

# 18. Referências

-   `/docs/00-foundation/`
-   `/docs/01-product/`
-   `/docs/02-architecture/`
-   `/docs/04-specs/`
-   `/docs/12-devops/`

# 19. Status

**Documento:** ADR Index / README\
**Status:** Approved\
**Responsabilidade:** definir governança, convenções, catálogo inicial e
evolução dos Architecture Decision Records do PMO Control.
