# ADR-008 --- Inngest Background Workflows

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Adotar Inngest como mecanismo inicial para workflows
assíncronos, tarefas em background, retries e processamento orientado a
eventos do PMO Control.

------------------------------------------------------------------------

## 1. Context

O PMO Control possui operações que não devem permanecer acopladas ao
ciclo síncrono de uma requisição HTTP.

Exemplos:

-   envio de notificações;
-   sincronização com integrações;
-   geração de relatórios;
-   processamento de documentos;
-   tarefas de IA;
-   recomputação não crítica;
-   jobs agendados;
-   retries;
-   processamento pós-publicação de Status.

A arquitetura inicial utiliza:

``` text
Next.js + TypeScript
Vercel
Supabase/PostgreSQL
```

É necessário um mecanismo confiável para processamento assíncrono sem
introduzir infraestrutura distribuída excessiva no MVP.

------------------------------------------------------------------------

## 2. Problem

Executar todo processamento dentro de requests síncronos causa riscos
como:

-   timeout;
-   alta latência;
-   retries frágeis;
-   experiência ruim;
-   perda de trabalho;
-   acoplamento com providers externos;
-   dificuldade de agendamento.

Por outro lado, introduzir Kafka, RabbitMQ ou infraestrutura própria de
workers no MVP aumentaria significativamente a complexidade operacional.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   integração com TypeScript;
-   baixo overhead operacional;
-   retries;
-   scheduling;
-   observabilidade;
-   idempotência;
-   workflows duráveis;
-   compatibilidade com Vercel;
-   simplicidade de desenvolvimento;
-   isolamento de falhas externas;
-   evolução futura.

------------------------------------------------------------------------

## 4. Decision

Adotar:

``` text
Inngest
```

como plataforma inicial para:

``` text
Background Workflows
Scheduled Jobs
Retries
Event-triggered Processing
Long-running Orchestration
```

------------------------------------------------------------------------

## 5. Synchronous vs Asynchronous

Regra:

``` text
Critical Business Transaction
→ Synchronous / Transactional
```

``` text
Non-critical Side Effect
→ Asynchronous when appropriate
```

------------------------------------------------------------------------

## 6. Critical Transaction Boundary

Exemplo: publicação de Status.

``` text
Validate
 ↓
Authorize
 ↓
Calculate
 ↓
Create Publication
 ↓
Create Snapshot
 ↓
Create Audit
 ↓
COMMIT
```

Esse fluxo crítico não depende do sucesso de Inngest.

------------------------------------------------------------------------

## 7. Post-Commit Processing

Após commit:

``` text
Status Published
      ↓
Event / Job
      ↓
Notifications
AI Summary
Report Rendering
Analytics
Integrations
```

Falha pós-commit não desfaz a publicação.

------------------------------------------------------------------------

## 8. Principle

``` text
Async Failure
≠
Business Transaction Failure
```

quando o trabalho assíncrono é efeito derivado não crítico.

------------------------------------------------------------------------

## 9. Candidate Workloads

Inngest poderá executar:

-   email notifications;
-   reminder generation;
-   overdue checks;
-   integration synchronization;
-   webhook follow-up;
-   scheduled portfolio processing;
-   report generation;
-   document processing;
-   AI summaries;
-   AI enrichment;
-   batch import processing;
-   cleanup governado;
-   projection refresh.

------------------------------------------------------------------------

## 10. Not Every Operation Is a Job

Não transformar toda operação em workflow assíncrono.

Operações simples e rápidas permanecem síncronas.

------------------------------------------------------------------------

## 11. Events

Eventos internos podem representar fatos relevantes.

Exemplos conceituais:

``` text
status.published
risk.created
decision.requested
action.overdue
report.requested
integration.sync.requested
```

------------------------------------------------------------------------

## 12. Event Is a Fact

Preferência:

``` text
status.published
```

em vez de evento ambíguo como:

``` text
do_everything_after_status
```

Consumers decidem seus efeitos.

------------------------------------------------------------------------

## 13. Domain Events vs Integration Events

Nem todo Domain Event precisa ser publicado externamente.

Distinção conceitual:

``` text
Domain/Application Event
```

vs:

``` text
External Integration Event
```

------------------------------------------------------------------------

## 14. Delivery Semantics

Workflows devem assumir que eventos/jobs podem ser processados mais de
uma vez.

Portanto:

``` text
At-least-once mindset
```

deve orientar handlers.

------------------------------------------------------------------------

## 15. Idempotency

Handlers precisam ser idempotentes quando repetição puder causar efeito
duplicado.

Exemplo:

``` text
Send Status Notification
```

não deve enviar dez emails por retries do mesmo evento.

------------------------------------------------------------------------

## 16. Idempotency Key

Quando apropriado:

``` text
operation
+
tenant_id
+
resource_id
+
event/version
```

formam chave lógica de idempotência.

------------------------------------------------------------------------

## 17. Retry

Falhas transitórias devem utilizar retry com estratégia apropriada.

Exemplos:

-   provider timeout;
-   HTTP 5xx;
-   temporary rate limit;
-   network failure.

------------------------------------------------------------------------

## 18. Non-Retryable Errors

Erros permanentes não devem ser repetidos indefinidamente.

Exemplos:

-   invalid configuration;
-   revoked credential;
-   malformed payload;
-   forbidden operation.

------------------------------------------------------------------------

## 19. Backoff

Retries devem usar backoff adequado e respeitar provider rate limits.

------------------------------------------------------------------------

## 20. Maximum Attempts

Todo workflow precisa possuir política finita ou controlada de retry.

Não criar loops infinitos.

------------------------------------------------------------------------

## 21. Failure State

Após esgotar retries:

``` text
Failed
```

deve ser observável e, quando necessário, reprocessável.

------------------------------------------------------------------------

## 22. Reprocessing

Operações críticas de integração devem permitir reprocessamento
controlado.

Reprocessar não significa ignorar idempotência.

------------------------------------------------------------------------

## 23. Tenant Context

Todo workflow tenant-scoped deve possuir Tenant explícito.

Exemplo:

``` text
tenant_id
project_id
operation
```

------------------------------------------------------------------------

## 24. Tenant Isolation

Job do Tenant A nunca pode processar dados do Tenant B por erro de
lookup.

Queries continuam tenant-scoped.

------------------------------------------------------------------------

## 25. Authorization

Um job iniciado por usuário não herda autorização eterna.

A execução deve diferenciar:

-   autorização da ação original;
-   autoridade legítima do sistema para concluir o workflow.

A modelagem específica será definida por use case.

------------------------------------------------------------------------

## 26. Actor Context

Quando relevante, preservar:

``` text
initiated_by
```

para Audit e rastreabilidade.

------------------------------------------------------------------------

## 27. System Actor

Jobs agendados podem executar como System Actor com:

-   propósito explícito;
-   Tenant Scope;
-   capabilities limitadas;
-   Audit quando necessário.

------------------------------------------------------------------------

## 28. Secrets

Jobs podem precisar de:

-   provider credentials;
-   BYOK;
-   integration tokens.

Secrets devem ser obtidos server-side no momento apropriado.

Não incluir secrets diretamente no event payload.

------------------------------------------------------------------------

## 29. Payload Minimization

Eventos devem transportar identificadores/contexto necessário, não
cópias indiscriminadas de dados sensíveis.

Preferência:

``` text
tenant_id
resource_id
event_id
```

e carregar dados autorizados quando executar.

------------------------------------------------------------------------

## 30. Sensitive Data

Evitar PII/confidential data em payloads, logs e observabilidade quando
não necessário.

------------------------------------------------------------------------

## 31. Long AI Tasks

Tarefas de IA que excedam request normal podem ser executadas em
background.

Exemplos:

-   executive report draft;
-   large document analysis;
-   portfolio synthesis.

------------------------------------------------------------------------

## 32. AI Failure

Falha do provider de IA não pode corromper estado operacional.

------------------------------------------------------------------------

## 33. Integration Sync

Fluxo conceitual:

``` text
Sync Requested
      ↓
Load Tenant Integration
      ↓
Load Credential
      ↓
Call Provider
      ↓
Validate
      ↓
Map
      ↓
Domain/Application Command
      ↓
Persist
```

Adapters não escrevem arbitrariamente no banco.

------------------------------------------------------------------------

## 34. Scheduled Work

Inngest poderá executar tarefas periódicas como:

-   overdue action evaluation;
-   upcoming milestone reminders;
-   integration polling;
-   scheduled reports;
-   portfolio health refresh.

------------------------------------------------------------------------

## 35. My Day

Meu Dia pode utilizar dados derivados de processos periódicos, mas
informações críticas devem continuar deriváveis das entidades fonte.

------------------------------------------------------------------------

## 36. Notifications

Notificação é side effect.

``` text
Business Event
→ Notification Job
→ SMTP / Future Channel
```

Falha de email não desfaz operação de negócio.

------------------------------------------------------------------------

## 37. Report Generation

Reports pesados podem seguir:

``` text
Report Requested
      ↓
Queued
      ↓
Generating
      ↓
Completed / Failed
```

------------------------------------------------------------------------

## 38. Import

Importações grandes podem usar:

``` text
Upload
 ↓
Staging
 ↓
Validation Job
 ↓
Preview
 ↓
User Confirmation
 ↓
Apply
```

------------------------------------------------------------------------

## 39. Concurrency

Workflows devem controlar concorrência quando múltiplas execuções sobre
o mesmo recurso puderem causar conflito.

Exemplo:

``` text
integration_id
project_id
report_id
```

------------------------------------------------------------------------

## 40. Ordering

Não assumir ordenação global de eventos.

Quando ordering for requisito, deve ser explicitamente modelado.

------------------------------------------------------------------------

## 41. Duplicate Events

Consumer deve tolerar duplicidade.

------------------------------------------------------------------------

## 42. Out-of-Order Events

Quando relevante, utilizar:

-   version;
-   timestamp;
-   sequence;
-   current-state validation.

------------------------------------------------------------------------

## 43. Database Transaction + Event Emission

Existe risco clássico:

``` text
DB COMMIT succeeds
but
event emission fails
```

No MVP, workflows devem ser projetados considerando esse risco.

Para fluxos críticos que exijam garantia mais forte, poderá ser adotado
Outbox Pattern futuramente via ADR específico.

------------------------------------------------------------------------

## 44. Outbox

Outbox não será introduzido automaticamente no MVP.

Trigger para adoção:

-   perda de evento demonstrada como risco inaceitável;
-   integração crítica;
-   necessidade de delivery garantido entre commit e processamento.

------------------------------------------------------------------------

## 45. Inngest Is Not the Source of Truth

Fonte de verdade continua sendo PostgreSQL.

Inngest coordena execução.

------------------------------------------------------------------------

## 46. Job State

Estado técnico do workflow não substitui estado de negócio.

Exemplo:

``` text
Report.status = generating
```

pode existir no domínio/aplicação quando necessário.

------------------------------------------------------------------------

## 47. Observability

Cada execução deve permitir correlação por:

``` text
event_id
run_id
tenant_id
resource_id
operation
correlation_id
```

quando apropriado.

------------------------------------------------------------------------

## 48. Metrics

Monitorar:

-   executions;
-   failures;
-   retry count;
-   duration;
-   queue delay;
-   provider errors;
-   permanently failed jobs.

------------------------------------------------------------------------

## 49. Alerts

Alertas devem focar em:

-   repeated failures;
-   critical workflow failures;
-   backlog growth;
-   credential failures;
-   integration degradation.

------------------------------------------------------------------------

## 50. Logging

Não logar:

-   BYOK;
-   tokens;
-   passwords;
-   confidential payloads.

------------------------------------------------------------------------

## 51. Option A --- Execute Everything Synchronously

### Vantagens

-   arquitetura simples.

### Desvantagens

-   timeouts;
-   request latency;
-   retry frágil;
-   dependência de providers;
-   baixa resiliência.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 52. Option B --- Self-Managed Queue + Workers

Exemplos:

-   Redis/BullMQ;
-   RabbitMQ;
-   custom workers.

### Vantagens

-   controle total.

### Desvantagens

-   infraestrutura adicional;
-   deployment;
-   monitoring;
-   scaling;
-   operations.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 53. Option C --- Kafka

### Vantagens

-   alto throughput;
-   event streaming;
-   replay;
-   ecosystem robusto.

### Desvantagens

-   complexidade muito superior à necessidade atual;
-   operação;
-   schemas;
-   consumers;
-   partitions;
-   observabilidade.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 54. Option D --- Inngest

### Vantagens

-   workflows;
-   retries;
-   scheduling;
-   TypeScript;
-   observabilidade;
-   menor overhead operacional;
-   boa aderência a serverless.

### Desvantagens

-   dependência de provider;
-   limites de plataforma;
-   semântica própria;
-   custo futuro conforme volume.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 55. Consequences --- Positive

-   requests menores;
-   retries padronizados;
-   workflows observáveis;
-   menos infraestrutura;
-   integração natural com stack;
-   graceful degradation de providers;
-   scheduling simples.

------------------------------------------------------------------------

## 56. Consequences --- Negative

-   nova dependência SaaS;
-   handlers precisam de idempotência;
-   debugging atravessa boundary assíncrono;
-   consistência pode ser eventual;
-   custo pode crescer.

------------------------------------------------------------------------

## 57. Mitigations

-   PostgreSQL como source of truth;
-   idempotency;
-   correlation IDs;
-   explicit workflow states;
-   observability;
-   retry policies;
-   adapter boundaries;
-   evitar colocar transações críticas no async path.

------------------------------------------------------------------------

## 58. Deployment

Functions/workflows devem ser versionados junto ao código e compatíveis
com deployments ativos.

------------------------------------------------------------------------

## 59. Versioning

Mudança de payload/event schema precisa considerar runs existentes.

Evitar alteração incompatível silenciosa.

------------------------------------------------------------------------

## 60. Backward Compatibility

Quando necessário:

``` text
event_version
```

ou handlers compatíveis com versões anteriores.

------------------------------------------------------------------------

## 61. Preview Environments

Jobs de Preview/Test não devem processar dados/eventos de Production.

------------------------------------------------------------------------

## 62. Environment Isolation

``` text
Development Events
≠
Production Events
```

------------------------------------------------------------------------

## 63. Testing

Cobrir:

-   success;
-   transient failure;
-   permanent failure;
-   retry;
-   duplicate event;
-   idempotency;
-   wrong Tenant;
-   provider timeout;
-   concurrency;
-   authorization/system authority;
-   secret handling.

------------------------------------------------------------------------

## 64. Local Testing

Workflows precisam ser testáveis sem depender exclusivamente de
Production.

------------------------------------------------------------------------

## 65. Revisit Triggers

Reavaliar Inngest se:

1.  volume/custo tornar-se inadequado;
2.  latency requirements mudarem;
3.  throughput exigir plataforma especializada;
4.  event streaming/replay tornar-se requisito central;
5.  compliance exigir self-hosting;
6.  provider limitations bloquearem workflows;
7.  workloads exigirem workers dedicados.

------------------------------------------------------------------------

## 66. Migration Path

Se outra infraestrutura se tornar necessária:

``` text
Stable Event Contracts
      ↓
Isolate Workflow Logic
      ↓
Introduce New Queue/Runtime
      ↓
Migrate Consumers
      ↓
Dual Validate if necessary
      ↓
Retire Inngest selectively
```

------------------------------------------------------------------------

## 67. Non-Triggers

Não adicionar Kafka/RabbitMQ/Redis apenas porque:

-   há eventos;
-   existem muitos módulos;
-   arquitetura orientada a eventos parece moderna;
-   outra empresa utiliza.

------------------------------------------------------------------------

## 68. Architecture Invariants

1.  PostgreSQL continua source of truth.
2.  Transação crítica não depende de side effect assíncrono.
3.  Jobs tenant-scoped possuem Tenant explícito.
4.  Secrets não entram em event payload.
5.  Handlers relevantes são idempotentes.
6.  Retry é controlado.
7.  Falha permanente é observável.
8.  Eventos podem ser duplicados.
9.  Ordering global não é presumido.
10. AI/provider failure não corrompe core.
11. Integration adapters não bypassam domínio.
12. Production e Preview permanecem isolados.
13. Outbox só entra mediante necessidade comprovada.

------------------------------------------------------------------------

## 69. Relationship with ADR-001

O monólito modular continua sendo o deployment principal.

Inngest complementa a aplicação com execução assíncrona; não transforma
os módulos em microservices.

------------------------------------------------------------------------

## 70. Relationship with ADR-007

Publicação e Snapshot são concluídos antes dos side effects
pós-publicação.

------------------------------------------------------------------------

## 71. Relationship with ADR-012

A escolha do Inngest evita introduzir prematuramente infraestrutura
distribuída autogerenciada.

------------------------------------------------------------------------

## 72. References

-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/integration-architecture.md`
-   `/docs/02-architecture/deployment-architecture.md`
-   `/docs/03-adrs/001-modular-monolith.md`
-   `/docs/03-adrs/007-immutable-status-snapshots.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 73. Decision Summary

``` text
Decision:
Use Inngest for background workflows,
scheduled jobs, retries and asynchronous processing.

Rule:
Critical Transaction
→ Commit first

Non-critical Side Effects
→ Async when appropriate

Why:
It provides durable workflow capabilities without
requiring self-managed messaging infrastructure
during the MVP.

Revisit:
When measured throughput, cost, compliance or
operational requirements justify another platform.
```

------------------------------------------------------------------------

**ADR:** ADR-008\
**Status:** Accepted
