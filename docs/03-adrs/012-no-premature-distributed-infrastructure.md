# ADR-012 --- No Premature Distributed Infrastructure

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Não introduzir infraestrutura distribuída especializada
--- como Kafka, RabbitMQ, Redis, Elasticsearch/OpenSearch, Neo4j,
Kubernetes ou bancos especializados --- antes de existir necessidade
técnica, operacional ou comercial comprovada por requisitos e métricas.

------------------------------------------------------------------------

## 1. Context

O PMO Control nasce como um SaaS de governança de projetos com um
domínio amplo:

-   Portfolios;
-   Projects;
-   Milestones;
-   Deliverables;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Status;
-   Snapshots;
-   Dashboards;
-   Reports;
-   Documents;
-   Integrations;
-   AI/Copilot.

Esse escopo pode sugerir prematuramente uma arquitetura composta por
vários serviços, filas, caches, mecanismos de busca e bancos
especializados.

Entretanto, complexidade arquitetural também possui custo.

------------------------------------------------------------------------

## 2. Problem

Adicionar infraestrutura distribuída antes de existir necessidade real
cria:

-   mais serviços;
-   mais deployment;
-   mais configuração;
-   mais observabilidade;
-   mais failure modes;
-   mais segurança;
-   mais sincronização;
-   mais custos;
-   mais conhecimento operacional necessário.

O sistema precisa permanecer simples o suficiente para evoluir
rapidamente sem comprometer segurança e qualidade.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   velocidade de entrega;
-   simplicidade;
-   custo;
-   manutenibilidade;
-   confiabilidade;
-   capacidade do time;
-   observabilidade;
-   segurança;
-   testabilidade;
-   redução de failure modes;
-   evolução baseada em evidência.

------------------------------------------------------------------------

## 4. Decision

O MVP utilizará preferencialmente:

``` text
Next.js + TypeScript
Vercel
Supabase/PostgreSQL/Auth/Storage
Inngest
GitHub
SMTP
AI Gateway + Tenant BYOK
```

Não adicionar infraestrutura especializada sem necessidade comprovada.

------------------------------------------------------------------------

## 5. Core Principle

``` text
Start Simple
Measure
Identify Constraint
Optimize
Add Complexity Only When Justified
```

------------------------------------------------------------------------

## 6. Complexity Must Pay Rent

Toda nova tecnologia estrutural deve responder:

1.  qual problema concreto resolve?
2.  por que a stack atual não resolve?
3.  qual evidência demonstra o problema?
4.  qual custo operacional adiciona?
5.  qual failure mode adiciona?
6.  como será observada?
7.  como será protegida?
8.  como será removida/migrada no futuro?

------------------------------------------------------------------------

## 7. Not in MVP by Default

Ficam fora do MVP, salvo necessidade comprovada:

``` text
Redis
Kafka
RabbitMQ
Elasticsearch / OpenSearch
Neo4j
Kubernetes
Firebase
Dedicated Vector Database
Service Mesh
Self-managed Message Broker
```

------------------------------------------------------------------------

## 8. Redis

Não adicionar Redis apenas para:

-   "ter cache";
-   session storage sem necessidade;
-   queues já atendidas pelo Inngest;
-   locks sem problema real.

------------------------------------------------------------------------

## 9. Redis Trigger Examples

Considerar Redis se houver evidência de:

-   hot data com carga significativa;
-   latency target não atendido;
-   distributed coordination necessária;
-   rate limiting centralizado em escala;
-   cache com benefício medido.

------------------------------------------------------------------------

## 10. Kafka

Não adicionar Kafka apenas porque o sistema possui eventos.

------------------------------------------------------------------------

## 11. Kafka Trigger Examples

Considerar Kafka se surgirem requisitos reais de:

-   event streaming de alto volume;
-   múltiplos consumidores independentes;
-   replay durável como requisito central;
-   partitioned ordering;
-   analytics/event backbone;
-   throughput incompatível com solução atual.

------------------------------------------------------------------------

## 12. RabbitMQ

Não adicionar RabbitMQ apenas para executar jobs.

Inngest cobre inicialmente background workflows e retries.

------------------------------------------------------------------------

## 13. RabbitMQ Trigger Examples

Considerar broker dedicado se:

-   routing avançado de mensagens for necessário;
-   controle de queue semantics se tornar requisito;
-   self-hosted messaging for obrigatório;
-   limites do workflow provider forem comprovadamente insuficientes.

------------------------------------------------------------------------

## 14. Elasticsearch / OpenSearch

Não adicionar search engine apenas para busca textual básica.

------------------------------------------------------------------------

## 15. Search First Strategy

Preferência inicial:

``` text
PostgreSQL Search
      ↓
Indexes / FTS / Query Optimization
      ↓
Measure
      ↓
Specialized Search if justified
```

------------------------------------------------------------------------

## 16. Elasticsearch Trigger Examples

Considerar se houver necessidade comprovada de:

-   busca full-text complexa em grande escala;
-   relevância avançada;
-   faceting pesado;
-   logs/search workload especializado;
-   volume incompatível com PostgreSQL.

------------------------------------------------------------------------

## 17. Neo4j

O domínio possui relações, mas isso não implica necessidade de graph
database.

------------------------------------------------------------------------

## 18. Graph Trigger Examples

Considerar graph database se consultas de grafo profundas e frequentes
se tornarem core e demonstrarem inadequação do modelo relacional.

------------------------------------------------------------------------

## 19. Vector Database

Busca semântica futura não implica imediatamente vector database
separado.

Primeiro candidato:

``` text
PostgreSQL + pgvector
```

quando adequado.

------------------------------------------------------------------------

## 20. Dedicated Vector DB Trigger

Considerar apenas se:

-   volume vetorial;
-   latency;
-   recall;
-   filtering;
-   operational requirements;

ultrapassarem comprovadamente a solução PostgreSQL.

------------------------------------------------------------------------

## 21. Kubernetes

Não introduzir Kubernetes para "estar preparado para escala".

------------------------------------------------------------------------

## 22. Kubernetes Trigger Examples

Considerar quando houver necessidade concreta de:

-   muitos workloads containerizados independentes;
-   custom scheduling;
-   networking avançado;
-   self-hosted runtime;
-   portability/compliance;
-   escala operacional que justifique o custo.

------------------------------------------------------------------------

## 23. Microservices

Número de módulos não determina número de serviços.

O PMO Control começa como modular monolith.

------------------------------------------------------------------------

## 24. Service Extraction

Extrair serviço somente quando houver boundary estável e motivo
concreto, como:

-   scaling independente;
-   lifecycle independente;
-   compliance;
-   failure isolation;
-   ownership organizacional;
-   runtime especializado.

------------------------------------------------------------------------

## 25. Database Strategy

PostgreSQL permanece banco principal até que workload específico
demonstre necessidade de tecnologia adicional.

------------------------------------------------------------------------

## 26. Polyglot Persistence

Não adotar polyglot persistence por preferência arquitetural.

Cada novo banco cria:

-   consistência adicional;
-   backup adicional;
-   segurança adicional;
-   migrations adicionais;
-   observabilidade adicional.

------------------------------------------------------------------------

## 27. Cache

Cache não é source of truth.

Antes de adicionar cache:

``` text
Measure
→ Optimize Query
→ Index
→ Reduce Payload
→ Consider Materialization
→ Cache
```

------------------------------------------------------------------------

## 28. Cache Security

Qualquer cache futuro deve respeitar Tenant, Scope e Permission.

Performance nunca justifica vazamento cross-tenant.

------------------------------------------------------------------------

## 29. Async Processing

Inngest é suficiente inicialmente para:

-   jobs;
-   retries;
-   schedules;
-   post-commit workflows;
-   integração assíncrona.

------------------------------------------------------------------------

## 30. Event-Driven Architecture

O sistema pode utilizar eventos internos sem possuir um event streaming
platform.

``` text
Events
≠
Kafka Required
```

------------------------------------------------------------------------

## 31. Outbox Pattern

Não adicionar Outbox por ritual arquitetural.

Adicionar se atomicidade entre commit e emissão de evento se tornar
requisito crítico comprovado.

------------------------------------------------------------------------

## 32. CQRS

Separação conceitual entre Commands e Queries é útil.

Infraestrutura CQRS completa não entra no MVP por padrão.

------------------------------------------------------------------------

## 33. Event Sourcing

Snapshots históricos não transformam o sistema em Event Sourcing.

Event Sourcing não será adotado sem necessidade específica.

------------------------------------------------------------------------

## 34. Read Models

Dashboards podem utilizar queries/views/materializações antes de
introduzir banco separado.

------------------------------------------------------------------------

## 35. Data Warehouse

Warehouse não entra no MVP.

Pode surgir quando analytics histórico/BI em escala justificar.

------------------------------------------------------------------------

## 36. Operational Database vs Analytics

Não sobrecarregar PostgreSQL indefinidamente se analytics futuro provar
necessidade de separação.

Mas a separação será baseada em evidência.

------------------------------------------------------------------------

## 37. Managed Services First

Preferência:

``` text
Managed Service
before
Self-Managed Infrastructure
```

quando atender requisitos de segurança, custo e compliance.

------------------------------------------------------------------------

## 38. Why Managed

Serviços gerenciados reduzem inicialmente:

-   patching;
-   upgrades;
-   cluster operation;
-   backups operacionais;
-   scaling manual;
-   infrastructure toil.

------------------------------------------------------------------------

## 39. Managed Does Not Mean Unmanaged Risk

Ainda é necessário governar:

-   access;
-   secrets;
-   costs;
-   limits;
-   regions;
-   backups;
-   provider failures.

------------------------------------------------------------------------

## 40. Option A --- Enterprise Distributed Stack from Day One

Exemplo:

``` text
Kubernetes
Kafka
Redis
Elasticsearch
Microservices
Multiple Databases
```

### Vantagens

-   grande flexibilidade futura.

### Desvantagens

-   enorme complexidade imediata;
-   maior custo;
-   mais failure modes;
-   menor velocidade;
-   necessidades ainda hipotéticas.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 41. Option B --- Minimal Managed Architecture

### Vantagens

-   foco no produto;
-   menor operação;
-   menor custo inicial;
-   menos failure modes;
-   evolução incremental.

### Desvantagens

-   algumas migrações podem ocorrer no futuro;
-   limites de managed services precisam ser monitorados.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 42. Avoiding Premature Optimization

Não otimizar para:

``` text
10 million users
```

sem evidência de que esse é o problema atual.

Projetar boundaries saudáveis, mas implementar para requisitos reais.

------------------------------------------------------------------------

## 43. Scale Readiness

Simplicidade não significa ignorar escala.

Desde o início:

-   indexes;
-   pagination;
-   bounded queries;
-   idempotency;
-   tenant isolation;
-   async workloads;
-   observability;
-   clean boundaries.

------------------------------------------------------------------------

## 44. Evolutionary Architecture

Objetivo:

``` text
Simple Today
+
Extractable Tomorrow
```

------------------------------------------------------------------------

## 45. Architectural Fitness

A stack atual é adequada enquanto:

-   latency atende objetivos;
-   throughput atende demanda;
-   costs são aceitáveis;
-   reliability atende SLA;
-   team consegue operar;
-   security/compliance são atendidos.

------------------------------------------------------------------------

## 46. Evidence

Evidência pode incluir:

-   APM metrics;
-   query plans;
-   latency percentiles;
-   throughput;
-   queue delay;
-   database utilization;
-   cost reports;
-   incident history;
-   customer requirements.

------------------------------------------------------------------------

## 47. Architecture Change Proposal

Nova infraestrutura estrutural deve ser acompanhada de ADR.

------------------------------------------------------------------------

## 48. Required ADR Questions

Novo ADR deve registrar:

-   current bottleneck;
-   measured evidence;
-   considered alternatives;
-   expected benefit;
-   operational cost;
-   migration path;
-   rollback/exit strategy.

------------------------------------------------------------------------

## 49. Team Capability

Tecnologia só deve ser adicionada se puder ser operada com segurança.

------------------------------------------------------------------------

## 50. Operational Ownership

Toda nova plataforma precisa de owner.

------------------------------------------------------------------------

## 51. Observability Requirement

Não adicionar componente que não possa ser adequadamente monitorado.

------------------------------------------------------------------------

## 52. Security Requirement

Nova tecnologia exige threat/security review proporcional ao risco.

------------------------------------------------------------------------

## 53. Backup Requirement

Novo datastore exige estratégia de backup/recovery.

------------------------------------------------------------------------

## 54. Cost Requirement

Novo serviço exige entendimento de custo e crescimento esperado.

------------------------------------------------------------------------

## 55. Failure Budget

Cada componente adiciona novos failure modes.

A arquitetura deve considerar se o benefício compensa.

------------------------------------------------------------------------

## 56. Dependency Failure

Preferência por graceful degradation quando componente não crítico
falhar.

------------------------------------------------------------------------

## 57. Avoid Distributed Transactions

Não introduzir múltiplos bancos/serviços que exijam distributed
transaction sem necessidade extrema.

------------------------------------------------------------------------

## 58. Strong Consistency Core

Operações críticas de governança permanecem preferencialmente dentro do
boundary transacional PostgreSQL.

------------------------------------------------------------------------

## 59. Eventual Consistency

Usar eventual consistency apenas onde semanticamente aceitável.

Exemplos:

-   notifications;
-   external sync;
-   derived AI summary.

------------------------------------------------------------------------

## 60. Cost of Extraction

Aceita-se que uma arquitetura simples possa exigir extração futura.

Esse custo é preferível ao custo permanente de complexidade prematura.

------------------------------------------------------------------------

## 61. Technical Debt vs Premature Architecture

Não confundir simplicidade deliberada com dívida técnica.

Uma decisão simples, documentada e com caminho de evolução é arquitetura
intencional.

------------------------------------------------------------------------

## 62. Consequences --- Positive

-   menor custo;
-   menor operação;
-   desenvolvimento mais rápido;
-   menos failure modes;
-   debugging mais simples;
-   onboarding mais fácil;
-   foco no domínio.

------------------------------------------------------------------------

## 63. Consequences --- Negative

-   futuras migrações podem ser necessárias;
-   alguns componentes podem atingir limites;
-   exige disciplina para medir antes de escalar;
-   equipe precisa evitar acoplamento que impeça evolução.

------------------------------------------------------------------------

## 64. Mitigations

-   modular boundaries;
-   adapters;
-   internal contracts;
-   migrations versionadas;
-   observability;
-   metrics;
-   ADRs;
-   performance testing;
-   provider abstraction onde faz sentido.

------------------------------------------------------------------------

## 65. Revisit Triggers

Esta decisão deve ser reavaliada componente a componente quando houver:

1.  bottleneck medido;
2.  SLA não atendido;
3.  custo excessivo;
4.  compliance;
5.  data residency;
6.  throughput incompatível;
7.  workload especializado;
8.  necessidade de isolamento;
9.  provider hard limit;
10. customer contractual requirement.

------------------------------------------------------------------------

## 66. Non-Triggers

Não são justificativas suficientes:

-   "todo SaaS grande usa";
-   "microservices escalam melhor";
-   "Kafka é padrão enterprise";
-   "Kubernetes prepara para o futuro";
-   "Redis deixa tudo mais rápido";
-   "NoSQL escala mais";
-   "graph database combina com dependências".

------------------------------------------------------------------------

## 67. Decision Framework

Antes de adicionar tecnologia:

``` text
Problem?
 ↓
Measured?
 ↓
Can current stack solve it?
 ↓
Can optimization solve it?
 ↓
Can managed capability solve it?
 ↓
Is new infrastructure justified?
 ↓
ADR
 ↓
Implementation
```

------------------------------------------------------------------------

## 68. Architecture Invariants

1.  Complexity requires evidence.
2.  PostgreSQL remains primary datastore until proven insufficient.
3.  Inngest handles initial background workflows.
4.  No broker is required merely because events exist.
5.  No cache is added without measured benefit.
6.  No specialized search engine without search requirements.
7.  No graph DB because the domain has relationships.
8.  No Kubernetes for perceived enterprise maturity.
9.  No microservice extraction without a concrete boundary/benefit.
10. Managed services are preferred initially.
11. Security and Tenant isolation cannot be traded for performance.
12. New structural infrastructure requires an ADR.
13. Critical governance stays strongly consistent where feasible.
14. Evolution remains possible through clean boundaries.

------------------------------------------------------------------------

## 69. Relationship with ADR-001

ADR-001 chooses the modular monolith.

ADR-012 establishes why it should not be prematurely fragmented.

------------------------------------------------------------------------

## 70. Relationship with ADR-003

PostgreSQL/Supabase remains the primary data platform until a measured
workload justifies another datastore.

------------------------------------------------------------------------

## 71. Relationship with ADR-008

Inngest avoids the immediate need for self-managed messaging
infrastructure.

------------------------------------------------------------------------

## 72. Relationship with ADR-010

Adapters preserve clean boundaries so external complexity can evolve
without forcing distributed architecture.

------------------------------------------------------------------------

## 73. Relationship with ADR-011

Vercel and managed services support the strategy of low operational
overhead for the MVP.

------------------------------------------------------------------------

## 74. References

-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/deployment-architecture.md`
-   `/docs/03-adrs/001-modular-monolith.md`
-   `/docs/03-adrs/003-supabase-postgresql.md`
-   `/docs/03-adrs/008-inngest-background-workflows.md`
-   `/docs/03-adrs/010-integration-adapter-pattern.md`
-   `/docs/03-adrs/011-vercel-deployment.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 75. Decision Summary

``` text
Decision:
Do not introduce specialized distributed infrastructure
before measurable requirements justify it.

MVP:
Next.js + TypeScript
Vercel
Supabase/PostgreSQL/Auth/Storage
Inngest
GitHub
SMTP
AI Gateway + BYOK

Principle:
Start Simple
→ Measure
→ Optimize
→ Identify Constraint
→ Add Complexity Only When Justified

Why:
Premature infrastructure creates permanent operational,
security and cognitive cost for hypothetical benefits.

Revisit:
Component by component, when measured scale, SLA,
cost, compliance or workload requirements justify change.
```

------------------------------------------------------------------------

**ADR:** ADR-012\
**Status:** Accepted
