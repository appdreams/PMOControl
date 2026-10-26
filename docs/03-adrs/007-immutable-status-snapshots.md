# ADR-007 --- Immutable Status Snapshots

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Persistir cada Status publicado como um Snapshot histórico
imutável, separado do estado operacional atual do projeto.

------------------------------------------------------------------------

## 1. Context

O PMO Control possui dois conceitos distintos:

``` text
Current Operational State
```

e:

``` text
Published Governance State
```

Durante a execução, Milestones, Deliverables, Risks, Issues, Actions,
Decisions, Forecasts e indicadores continuam mudando.

Porém, quando um Status é publicado, a organização precisa preservar
exatamente o que foi comunicado naquele momento.

Essa informação alimenta:

-   histórico;
-   Time Machine;
-   comitês;
-   auditoria;
-   comparações;
-   tendências;
-   explicações;
-   relatórios;
-   PMO Copilot.

------------------------------------------------------------------------

## 2. Problem

Se dashboards históricos consultarem apenas as tabelas operacionais
atuais, o passado será reescrito sempre que os dados mudarem.

Exemplo:

``` text
Status published on 01/10
Progress = 62%

Current project on 15/10
Progress = 74%
```

O sistema precisa continuar sabendo que em 01/10 o valor oficialmente
publicado era 62%.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   verdade histórica;
-   auditabilidade;
-   Time Machine;
-   comparação entre períodos;
-   explicabilidade;
-   governança executiva;
-   reconstrução de reports;
-   integridade;
-   AI grounded history;
-   prevenção de reescrita do passado.

------------------------------------------------------------------------

## 4. Decision

Cada publicação de Status criará um:

``` text
Immutable Snapshot
```

representando o estado oficial publicado naquele instante.

------------------------------------------------------------------------

## 5. Core Model

``` text
Operational Entities
       ↓
Status Draft
       ↓
Validation
       ↓
RAG Calculation
       ↓
Publication
       ↓
Snapshot
       ↓
Historical Governance
```

------------------------------------------------------------------------

## 6. Current State vs Snapshot

### Current State

Mutável conforme execução.

### Snapshot

Imutável após publicação.

``` text
Current State ≠ Historical Truth
```

------------------------------------------------------------------------

## 7. Snapshot Is a Governance Fact

Depois de publicado:

``` text
Snapshot
=
Official historical governance record
```

Ele não é cache descartável.

------------------------------------------------------------------------

## 8. Publication Boundary

Publicação deve ser transacional.

Fluxo conceitual:

``` text
Validate
   ↓
Authorize
   ↓
Calculate KPIs
   ↓
Calculate RAG
   ↓
Resolve Authorized Override
   ↓
Create Publication
   ↓
Create Snapshot
   ↓
Create Audit
   ↓
COMMIT
```

------------------------------------------------------------------------

## 9. No Partial Publication

Se uma etapa crítica falhar antes do commit:

``` text
ROLLBACK
```

Não pode existir:

-   publication sem Snapshot;
-   Snapshot incompleto;
-   official Status parcialmente gravado.

------------------------------------------------------------------------

## 10. Post-Commit Work

Após commit, tarefas derivadas podem ocorrer assíncronamente:

-   notifications;
-   AI summary;
-   report rendering;
-   analytics;
-   non-critical projections.

Falha nessas tarefas não invalida a publicação oficial.

------------------------------------------------------------------------

## 11. Snapshot Contents

Snapshot deve conter informação suficiente para reconstruir o Status
publicado sem depender do estado mutável atual.

Pode incluir:

-   Project identity/context;
-   reporting period;
-   progress;
-   baseline;
-   forecast;
-   milestones;
-   deliverables;
-   risks;
-   issues;
-   actions;
-   decisions;
-   dependencies;
-   financial summary autorizado;
-   calculated RAG;
-   effective RAG;
-   executive summary;
-   achievements;
-   challenges;
-   next steps;
-   indicators;
-   publication metadata.

------------------------------------------------------------------------

## 12. Snapshot Header

Metadata conceitual:

``` text
snapshot_id
tenant_id
project_id
publication_id
sequence
published_at
published_by
schema_version
calculated_rag
effective_rag
integrity_metadata
```

------------------------------------------------------------------------

## 13. Snapshot Payload

A representação física pode ser:

1.  totalmente normalizada;
2.  document-oriented JSON;
3.  híbrida.

A decisão física final será detalhada posteriormente.

A arquitetura favorece inicialmente abordagem híbrida:

``` text
Snapshot Header
+
Structured Snapshot Payload
+
Indexed Key Attributes
```

------------------------------------------------------------------------

## 14. Schema Version

Todo Snapshot deve possuir versão de schema.

``` text
schema_version
```

Isso permite interpretar registros históricos após evolução do produto.

------------------------------------------------------------------------

## 15. Immutability

Operações comuns não podem:

``` text
UPDATE Snapshot
DELETE Snapshot
```

Correções precisam preservar histórico.

------------------------------------------------------------------------

## 16. Correction Strategy

Se Status publicado estiver incorreto, a correção deve ocorrer por novo
evento/publicação governada, e não por edição silenciosa do passado.

Exemplo:

``` text
Snapshot #12
      ↓
Correction / New Publication
      ↓
Snapshot #13
```

------------------------------------------------------------------------

## 17. Superseding History

Quando aplicável, metadata pode indicar que uma publicação posterior
corrige/substitui interpretação anterior.

O Snapshot original permanece preservado.

------------------------------------------------------------------------

## 18. Sequence

Snapshots de um Project devem possuir sequência consistente.

Exemplo:

``` text
Project ERP
Snapshot 001
Snapshot 002
Snapshot 003
```

------------------------------------------------------------------------

## 19. Time Machine

Time Machine consulta Snapshots, não tenta reconstruir o passado a
partir das tabelas atuais.

``` text
Select Historical Point
      ↓
Load Snapshot
      ↓
Render Published State
```

------------------------------------------------------------------------

## 20. Historical Comparison

Comparação:

``` text
Snapshot N
vs
Snapshot N-1
```

permite calcular:

-   progress delta;
-   RAG change;
-   risk evolution;
-   issue evolution;
-   forecast drift;
-   milestone changes;
-   action completion.

------------------------------------------------------------------------

## 21. Dashboard Current vs Historical

Dashboard deve deixar claro se apresenta:

``` text
CURRENT
```

ou:

``` text
AS OF SNAPSHOT
```

Nunca misturar silenciosamente dados de momentos diferentes.

------------------------------------------------------------------------

## 22. Portfolio Historical View

Portfolio pode consolidar Snapshots por período para reconstruir visão
executiva histórica.

------------------------------------------------------------------------

## 23. Reports

Report deve declarar origem temporal:

-   current;
-   latest published;
-   specific Snapshot;
-   period comparison.

------------------------------------------------------------------------

## 24. AI / Copilot

Perguntas como:

> "O que mudou desde o último Status?"

devem usar:

``` text
Current State
vs
Last Published Snapshot
```

------------------------------------------------------------------------

## 25. AI Historical Questions

Perguntas como:

> "Como estava o projeto no comitê de agosto?"

devem usar Snapshot correspondente, não dados atuais.

------------------------------------------------------------------------

## 26. Fact vs Interpretation

Snapshot fornece fatos históricos.

IA pode explicar ou resumir, mas não alterar o registro histórico.

------------------------------------------------------------------------

## 27. RAG

Snapshot persiste:

``` text
calculated_rag
effective_rag
override metadata when applicable
```

para preservar explicabilidade.

------------------------------------------------------------------------

## 28. RAG Rule Version

Quando necessário, persistir versão/configuração suficiente para
explicar como o RAG foi calculado.

------------------------------------------------------------------------

## 29. Baseline and Forecast

Snapshot deve preservar os valores vigentes no momento da publicação.

Isso permite medir forecast drift.

------------------------------------------------------------------------

## 30. Financial Data

Se incluído no Snapshot, respeita:

-   classification;
-   permission;
-   publication policy.

A representação histórica precisa evitar exposição indevida.

------------------------------------------------------------------------

## 31. Documents and Evidence

Snapshot pode registrar referências/evidence metadata relevantes.

Não é obrigatório duplicar todos os binários.

------------------------------------------------------------------------

## 32. Referential Stability

Referências históricas não devem quebrar porque entidade operacional foi
arquivada.

------------------------------------------------------------------------

## 33. Option A --- Reconstruct History from Audit

### Vantagens

-   evita duplicação de Snapshot.

### Desvantagens

-   reconstrução complexa;
-   Audit não é event sourcing;
-   alto custo;
-   risco de inconsistência.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 34. Option B --- Query Current Tables

### Vantagens

-   simples.

### Desvantagens

-   passado muda;
-   impossível reproduzir report oficial;
-   Time Machine inconsistente.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 35. Option C --- Immutable Snapshot per Publication

### Vantagens

-   histórico confiável;
-   leitura simples;
-   Time Machine;
-   comparação;
-   auditabilidade;
-   AI grounding.

### Desvantagens

-   duplicação de dados;
-   necessidade de schema versioning;
-   storage cresce;
-   correções exigem novo processo.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 36. Snapshot Is Not Event Sourcing

A decisão não transforma o sistema em Event Sourcing.

``` text
Operational State
+
Periodic/Published Snapshots
```

continua sendo o modelo.

------------------------------------------------------------------------

## 37. Snapshot Is Not Cache

Cache pode ser reconstruído e descartado.

Snapshot não.

------------------------------------------------------------------------

## 38. Snapshot Is Not Audit

Audit registra:

``` text
Who did what and when
```

Snapshot registra:

``` text
What official state was published
```

São complementares.

------------------------------------------------------------------------

## 39. Snapshot Is Not Backup

Backup protege infraestrutura/dados.

Snapshot preserva semântica histórica de negócio.

------------------------------------------------------------------------

## 40. Security

Snapshot herda:

-   Tenant isolation;
-   Project Scope;
-   Data Policy;
-   confidential data rules.

Imutabilidade não significa acesso público.

------------------------------------------------------------------------

## 41. Authorization

Visualização histórica exige autorização atual apropriada.

Possuir link/ID do Snapshot não concede acesso.

------------------------------------------------------------------------

## 42. Publication Permission

Criar Snapshot oficial exige:

``` text
status.update.publish
```

ou workflow equivalente autorizado.

------------------------------------------------------------------------

## 43. Database Protection

Policies/constraints devem impedir update/delete comum em Snapshots
publicados.

------------------------------------------------------------------------

## 44. Audit Relationship

Publicação registra Audit Event relacionado ao Snapshot.

Exemplo:

``` text
STATUS_PUBLISHED
snapshot_id
actor
timestamp
```

------------------------------------------------------------------------

## 45. Integrity Metadata

Pode incluir:

-   payload hash;
-   schema version;
-   publication sequence;
-   source references.

Uso de hash será definido se necessário.

------------------------------------------------------------------------

## 46. Concurrency

Duas publicações concorrentes do mesmo Project precisam ser controladas.

Possíveis mecanismos:

-   version check;
-   sequence constraint;
-   transaction lock;
-   optimistic concurrency.

------------------------------------------------------------------------

## 47. Duplicate Publication

Retry técnico não deve criar dois Snapshots oficiais idênticos por
acidente.

Publicação precisa de idempotência apropriada.

------------------------------------------------------------------------

## 48. Transaction Scope

Chamadas externas não devem ocorrer dentro da transação crítica quando
evitável.

``` text
DB Transaction
→ Commit
→ External Side Effects
```

------------------------------------------------------------------------

## 49. Failure Example

Se AI summary falhar:

``` text
Snapshot remains valid
```

Se notification falhar:

``` text
Snapshot remains valid
```

Se Snapshot persistence falhar antes do commit:

``` text
Publication fails
```

------------------------------------------------------------------------

## 50. Storage Growth

Snapshots duplicam parte do estado.

Isso é trade-off aceito pela governança.

Otimização só será considerada com dados reais de volume.

------------------------------------------------------------------------

## 51. Retention

Snapshots publicados possuem alta relevância histórica.

Política de retention deve ser definida com governança/legal/comercial.

Não aplicar cleanup genérico.

------------------------------------------------------------------------

## 52. Tenant Deletion

Exclusão de Tenant deve considerar obrigação de retenção de Snapshots.

Não realizar cascade indiscriminado sem política.

------------------------------------------------------------------------

## 53. Project Archive

Arquivar Project não apaga automaticamente seu histórico publicado.

------------------------------------------------------------------------

## 54. Data Migration

Mudanças de schema não devem reescrever Snapshot antigo apenas para
parecer novo.

Readers devem compreender versões anteriores quando necessário.

------------------------------------------------------------------------

## 55. Snapshot Reader

Conceitualmente:

``` text
Snapshot
  ↓
Schema Version
  ↓
Compatible Reader
  ↓
Historical View
```

------------------------------------------------------------------------

## 56. Backfill

Se campo novo não existia em Snapshot antigo, sistema deve representar
ausência corretamente em vez de inventar valor histórico.

------------------------------------------------------------------------

## 57. Testing

Testes críticos:

-   successful publication;
-   rollback on failure;
-   immutable update denial;
-   immutable delete denial;
-   sequence;
-   idempotency;
-   concurrent publication;
-   Tenant isolation;
-   historical rendering;
-   schema version compatibility.

------------------------------------------------------------------------

## 58. Integrity Test

Após publicação:

``` text
Snapshot Content
```

não pode mudar por alterações nas entidades operacionais.

------------------------------------------------------------------------

## 59. Time Machine Test

Alterar Project atual e confirmar que Snapshot anterior permanece
idêntico.

------------------------------------------------------------------------

## 60. Observability

Monitorar:

-   publication failures;
-   Snapshot creation failures;
-   duplicate attempts;
-   sequence conflicts;
-   integrity errors;
-   post-publication job failures.

------------------------------------------------------------------------

## 61. Critical Metrics

Objetivos arquiteturais:

``` text
Snapshot Integrity = 100%
Partial Publication Incidents = 0
```

------------------------------------------------------------------------

## 62. Consequences --- Positive

-   verdade histórica;
-   relatórios reproduzíveis;
-   Time Machine confiável;
-   comparação temporal;
-   melhor Audit;
-   AI grounded;
-   explicabilidade executiva.

------------------------------------------------------------------------

## 63. Consequences --- Negative

-   maior armazenamento;
-   schema versioning;
-   readers históricos;
-   maior complexidade de publicação;
-   correções não podem ser simples edits.

------------------------------------------------------------------------

## 64. Mitigations

-   payload estruturado;
-   schema version;
-   transactional publication;
-   tests;
-   idempotency;
-   clear correction workflow;
-   indexed metadata.

------------------------------------------------------------------------

## 65. Revisit Triggers

Reavaliar representação física se:

1.  volume causar custo relevante;
2.  consultas históricas exigirem outro formato;
3.  analytics exigir materialização diferente;
4.  compliance exigir retenção específica;
5.  performance histórica se tornar problema medido.

A necessidade de preservar imutabilidade não é reaberta por esses
triggers; apenas a implementação física.

------------------------------------------------------------------------

## 66. Architecture Invariants

1.  Published Status gera Snapshot.
2.  Snapshot publicado é imutável.
3.  Current State não substitui histórico.
4.  Publication e Snapshot são atomicamente consistentes.
5.  Não existe publicação parcial.
6.  Post-commit side effects não invalidam Snapshot.
7.  Snapshot possui Tenant.
8.  Snapshot possui schema version.
9.  Correção cria novo fato histórico.
10. Time Machine usa Snapshots.
11. Audit e Snapshot são conceitos distintos.
12. AI não altera Snapshot.
13. Retry não duplica publicação oficial.
14. Histórico não é inventado por backfill.

------------------------------------------------------------------------

## 67. Relationship with ADR-003

Snapshots serão persistidos inicialmente no PostgreSQL/Supabase.

------------------------------------------------------------------------

## 68. Relationship with ADR-004/005

Snapshots continuam sujeitos a Tenant isolation e RLS.

------------------------------------------------------------------------

## 69. Relationship with ADR-006

`status.update.publish` e acesso histórico seguem Authorization Model.

------------------------------------------------------------------------

## 70. References

-   `/docs/00-foundation/business-rules.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/03-adrs/003-supabase-postgresql.md`
-   `/docs/03-adrs/006-authorization-model.md`
-   `/docs/04-specs/014-status-update/`
-   `/docs/04-specs/016-snapshots/`
-   `/docs/04-specs/023-time-machine/`

------------------------------------------------------------------------

## 71. Decision Summary

``` text
Decision:
Every published Project Status creates an immutable
historical Snapshot.

Model:
Current Operational State
≠
Published Historical State

Publication:
Validate
→ Authorize
→ Calculate
→ Persist Publication + Snapshot + Audit
→ Commit
→ Async Side Effects

Why:
Governance requires reproducible historical truth.

Revisit:
The physical representation may evolve,
but published historical immutability remains invariant.
```

------------------------------------------------------------------------

**ADR:** ADR-007\
**Status:** Accepted
