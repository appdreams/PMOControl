# PMO Control --- Data Architecture

**Documento:** `data-architecture.md`\
**Camada:** Architecture\
**Status:** Approved\
**Tipo:** Arquitetura de dados, persistência, tenancy, histórico e
consistência

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a arquitetura de dados do PMO Control.

Ele estabelece como o sistema deve:

-   persistir dados transacionais;
-   representar Tenants e ownership;
-   garantir isolamento;
-   modelar entidades de governança;
-   diferenciar estado atual de estado publicado;
-   preservar histórico;
-   suportar auditoria;
-   organizar documentos e evidências;
-   suportar dashboards e relatórios;
-   alimentar IA com contexto autorizado;
-   executar importações e integrações;
-   manter integridade, rastreabilidade e evolução do schema.

------------------------------------------------------------------------

# 2. Princípio central

A arquitetura de dados deve preservar:

``` text
Integrity
+
Tenant Isolation
+
Traceability
+
Historical Truth
+
Explainability
```

O banco não é apenas armazenamento.

Ele participa da proteção dos invariantes do produto.

------------------------------------------------------------------------

# 3. Tecnologia principal

No MVP:

``` text
Supabase
   ↓
PostgreSQL
```

PostgreSQL será o sistema transacional principal.

Supabase também fornecerá, conforme arquitetura final:

``` text
Auth
Storage
Managed Database capabilities
```

------------------------------------------------------------------------

# 4. Modelo de persistência

A estratégia inicial é relacional.

Motivos:

-   forte integridade;
-   relações claras;
-   transações;
-   constraints;
-   consultas analíticas operacionais;
-   suporte a tenancy;
-   histórico;
-   maturidade operacional.

------------------------------------------------------------------------

# 5. Princípio de ownership

Toda entidade persistida deve possuir ownership claro.

Exemplos:

``` text
Tenant owns Portfolio
Portfolio contains Projects
Project owns governance records
```

Entidades compartilhadas devem possuir regra explícita.

------------------------------------------------------------------------

# 6. Tenant como boundary

Todo dado de negócio tenant-scoped deve estar relacionado de forma
inequívoca a um Tenant.

Preferência:

``` text
tenant_id
```

explícito nas entidades relevantes, mesmo quando o Tenant possa ser
inferido por joins, quando isso aumentar segurança, performance e
clareza.

A decisão final por tabela será feita no modelo físico.

------------------------------------------------------------------------

# 7. Regra de acesso

``` text
Authenticated User
      ↓
Tenant Membership
      ↓
Role / Scope / Permission
      ↓
Data Policy
      ↓
Authorized Rows
```

Nenhuma query tenant-scoped deve confiar apenas em IDs recebidos do
cliente.

------------------------------------------------------------------------

# 8. Defense in depth

Isolamento utiliza múltiplas camadas:

``` text
Application Authorization
        +
Tenant-scoped Query
        +
Foreign Keys / Constraints
        +
RLS where appropriate
        +
Automated Isolation Tests
```

------------------------------------------------------------------------

# 9. Entidades estruturais

Núcleo estrutural conceitual:

``` text
Tenant
 ├── Membership
 ├── Portfolio
 │    └── Project
 ├── Settings
 ├── AI Configuration
 └── Integration Configuration
```

------------------------------------------------------------------------

# 10. Membership

Membership representa a relação entre usuário e Tenant.

Não confundir:

``` text
User Identity
```

com:

``` text
Tenant Membership
```

O mesmo usuário poderá, futuramente, participar de mais de um Tenant se
o produto permitir.

------------------------------------------------------------------------

# 11. Authorization data

Conceitos persistentes podem incluir:

``` text
Role
Permission
Role Permission
Scope Assignment
Access Grant
Data Policy configuration
```

No MVP, Roles padrão podem ser seed/configuração controlada em vez de um
sistema totalmente dinâmico.

------------------------------------------------------------------------

# 12. Portfolio

Portfolio organiza Projects.

Conceitos principais:

-   Tenant;
-   name;
-   owner;
-   status;
-   metadata;
-   governance configuration quando aplicável.

------------------------------------------------------------------------

# 13. Project

Project é um aggregate central de navegação e governança.

Possíveis atributos:

-   tenant_id;
-   portfolio_id;
-   name;
-   code;
-   description;
-   owner;
-   sponsor;
-   lifecycle state;
-   phase;
-   planned progress;
-   actual progress;
-   start/end dates;
-   baseline;
-   forecast;
-   archive state.

O modelo físico será detalhado em `/docs/06-data/`.

------------------------------------------------------------------------

# 14. Entidades operacionais

Principais:

``` text
Milestone
Deliverable
Risk
Issue
Action
Decision
Dependency
Financial Record
Resource Allocation
Document
Evidence
```

------------------------------------------------------------------------

# 15. IDs

IDs devem:

-   ser únicos;
-   não carregar autorização;
-   não revelar sequência sensível quando evitável;
-   ser adequados a sistemas distribuídos futuros.

UUID é candidato natural no PostgreSQL/Supabase.

A decisão será formalizada no modelo de dados/ADR se necessário.

------------------------------------------------------------------------

# 16. Timestamps

Entidades relevantes devem utilizar timestamps consistentes.

Exemplos:

``` text
created_at
updated_at
deleted_at
published_at
resolved_at
completed_at
```

Usar timezone-aware timestamps no banco.

------------------------------------------------------------------------

# 17. Usuário responsável por alteração

Quando necessário para governança:

``` text
created_by
updated_by
```

podem existir.

Entretanto, isso não substitui Audit Log para operações sensíveis.

------------------------------------------------------------------------

# 18. Soft delete

Soft delete não deve ser aplicado automaticamente a tudo.

Usar quando:

-   retenção é necessária;
-   restauração é necessária;
-   referência histórica exige;
-   domínio permite exclusão lógica.

Algumas entidades podem utilizar estados como:

``` text
Archived
Cancelled
Closed
```

em vez de delete.

------------------------------------------------------------------------

# 19. Hard delete

Hard delete deve ser restrito.

Antes de permitir, avaliar:

-   histórico;
-   Audit;
-   Evidence;
-   Snapshot;
-   compliance;
-   references.

Published history não pode ser destruído por exclusão operacional comum.

------------------------------------------------------------------------

# 20. Current state

As tabelas operacionais representam o estado corrente.

Exemplo:

``` text
risk.status = mitigated
```

representa o estado atual do Risk.

------------------------------------------------------------------------

# 21. Historical published state

Snapshots representam o estado oficialmente publicado em determinado
momento.

``` text
Operational Tables
      ↓
Publication
      ↓
Immutable Snapshot
```

------------------------------------------------------------------------

# 22. Snapshot strategy

O Snapshot deve capturar dados suficientes para reconstruir a visão
publicada sem depender do estado corrente.

Não deve ser apenas:

``` text
status_id + timestamp
```

com queries futuras sobre tabelas mutáveis.

------------------------------------------------------------------------

# 23. Snapshot representation

Opções possíveis:

1.  estrutura relacional versionada;
2.  documento JSON estruturado;
3.  modelo híbrido.

A escolha física será formalizada em ADR após avaliar:

-   query patterns;
-   immutability;
-   evolução de schema;
-   comparação;
-   tamanho;
-   reporting;
-   performance.

------------------------------------------------------------------------

# 24. Recomendação inicial para Snapshot

Para o MVP, um modelo híbrido é forte candidato:

``` text
Snapshot Header
+
Structured Snapshot Payload
+
Key indexed attributes
```

Isso preserva fidelidade histórica e permite consultas essenciais.

A decisão final não é tomada neste documento.

------------------------------------------------------------------------

# 25. Snapshot metadata

Deve incluir conceitualmente:

-   tenant_id;
-   project_id;
-   status publication ID;
-   sequence/version;
-   published_at;
-   published_by;
-   calculated RAG;
-   effective RAG;
-   schema version;
-   payload integrity metadata quando necessário.

------------------------------------------------------------------------

# 26. Snapshot immutability

Após commit:

``` text
UPDATE
DELETE
```

não devem fazer parte do fluxo normal.

Proteções podem incluir:

-   application rules;
-   permissions;
-   database policy;
-   tests.

------------------------------------------------------------------------

# 27. Schema version do Snapshot

Snapshots precisam sobreviver à evolução do produto.

Portanto, o payload deve possuir versão.

Exemplo:

``` text
snapshot_schema_version = 1
```

Readers futuros devem tratar versões suportadas.

------------------------------------------------------------------------

# 28. Status publication data

Separar conceitualmente:

``` text
Status Draft
Status Publication
Snapshot
```

Draft é mutável.

Publication é evento/registro oficial.

Snapshot é representação imutável do estado publicado.

------------------------------------------------------------------------

# 29. RAG data

Persistir quando aplicável:

``` text
calculated_rag
effective_rag
override_reason
override_by
override_at
```

A regra utilizada também pode exigir versionamento/referência para
explicabilidade.

------------------------------------------------------------------------

# 30. RAG rule versioning

Se thresholds mudarem, histórico não deve parecer ter sido calculado
pelas regras atuais.

Por isso, publicação pode registrar:

-   rule set/version;
-   inputs relevantes;
-   result.

------------------------------------------------------------------------

# 31. Baseline

Baseline precisa ser distinguida de Forecast e Actual.

``` text
Baseline
Forecast
Actual
```

Não sobrescrever silenciosamente Baseline.

------------------------------------------------------------------------

# 32. Baseline versioning

No MVP, pelo menos mudanças relevantes precisam ser rastreáveis.

Modelo futuro completo:

``` text
Baseline Version
Change Request
Approval
Effective Date
Reason
Evidence
```

------------------------------------------------------------------------

# 33. Forecast

Forecast é mutável ao longo do tempo.

Snapshots preservam o Forecast publicado em cada checkpoint.

Isso permite medir:

``` text
Forecast Drift
```

------------------------------------------------------------------------

# 34. Milestones

Dados temporais importantes:

``` text
baseline_date
forecast_date
actual_date
```

Evitar um único `date` que muda de significado.

------------------------------------------------------------------------

# 35. Deliverables

Devem preservar:

-   ownership;
-   due date;
-   status;
-   progress;
-   Milestone relation;
-   Evidence relation.

------------------------------------------------------------------------

# 36. Risks

Risk deve possuir lifecycle explícito.

Conceitos:

-   probability;
-   impact;
-   exposure/severity;
-   response;
-   owner;
-   status;
-   materialization.

------------------------------------------------------------------------

# 37. Risk materialization

Quando um Risk se materializa:

``` text
Risk
  ↓
Issue
```

manter referência entre os dois.

Não transformar o registro de Risk no Issue apagando a história.

------------------------------------------------------------------------

# 38. Issues

Issue representa problema materializado.

Pode existir:

-   origin Risk;
-   severity;
-   impact;
-   owner;
-   resolution;
-   state.

------------------------------------------------------------------------

# 39. Actions

Action deve possuir origem rastreável quando aplicável.

``` text
source_type
source_id
```

ou relação equivalente.

Origens:

-   Risk;
-   Issue;
-   Decision;
-   Status;
-   Milestone;
-   Manual.

------------------------------------------------------------------------

# 40. Decisions

Decision deve preservar:

-   request context;
-   requested_by;
-   decision maker;
-   requested_at;
-   due_at;
-   decision;
-   decided_at;
-   rationale/comment;
-   Evidence.

Decisão final não deve ser perdida por edição posterior.

------------------------------------------------------------------------

# 41. Decision history

Alterações relevantes de estado devem ser auditadas.

Se deferida e depois decidida, preservar a sequência.

------------------------------------------------------------------------

# 42. Dependencies

Dependency precisa identificar claramente:

``` text
Source
Target
Type
Status
Owner
Impact
```

O modelo deve impedir relações inválidas quando possível.

------------------------------------------------------------------------

# 43. Polymorphic relations

Relações como Evidence e Action Source podem ser polimórficas.

Evitar polimorfismo sem integridade.

Alternativas:

-   typed reference;
-   junction tables específicas;
-   registry;
-   constraints/triggers quando necessários.

A decisão será tomada no modelo físico.

------------------------------------------------------------------------

# 44. Financial

Dados financeiros exigem classificação e autorização próprias.

Conceitos:

``` text
Budget
Actual
Forecast
Variance
Currency
Period
```

Evitar floating point inadequado para valores monetários.

Usar tipo decimal/numeric apropriado.

------------------------------------------------------------------------

# 45. Currency

Se múltiplas moedas forem suportadas:

-   armazenar currency code;
-   não somar moedas diferentes sem conversão explícita;
-   registrar fonte/data de taxa se conversão existir.

MVP pode limitar moeda conforme Tenant.

------------------------------------------------------------------------

# 46. Resources

Separar:

``` text
User
Resource
Project Membership
Allocation
```

Um Resource pode representar pessoa/capacidade mesmo quando não possui
login.

------------------------------------------------------------------------

# 47. Allocation

Conceitos:

-   resource_id;
-   project_id;
-   allocation period;
-   allocation amount/percentage;
-   capacity.

Evitar armazenar apenas um percentual global sem período.

------------------------------------------------------------------------

# 48. Documents

Metadata no banco:

-   tenant;
-   project;
-   classification;
-   storage reference;
-   filename;
-   content type;
-   size;
-   owner/uploader;
-   created_at.

Binário em Storage.

------------------------------------------------------------------------

# 49. Evidence

Evidence deve ser uma entidade/relação de primeira classe quando
necessário.

Pode conectar:

``` text
Risk → Document
Decision → Document
Status → Document
Milestone → External Reference
```

------------------------------------------------------------------------

# 50. Data classification

Aplicar classificação definida em:

``` text
/docs/00-foundation/data-classification.md
```

A classificação influencia:

-   access;
-   export;
-   logging;
-   AI context;
-   retention;
-   storage.

------------------------------------------------------------------------

# 51. Confidential data

Dados confidenciais devem possuir políticas explícitas.

Exemplo:

``` text
documents.confidential.view
```

O fato de usuário poder ver o Project não implica acesso a todo
documento confidencial.

------------------------------------------------------------------------

# 52. Audit Log

Audit Event deve ser append-oriented.

Conceitos:

-   tenant;
-   actor;
-   action;
-   resource_type;
-   resource_id;
-   timestamp;
-   reason;
-   before/after ou delta quando apropriado;
-   correlation ID;
-   metadata segura.

------------------------------------------------------------------------

# 53. Audit immutability

Usuários comuns não alteram Audit Events.

Administradores também não devem possuir edição arbitrária de histórico.

------------------------------------------------------------------------

# 54. Audit payload

Não registrar:

-   passwords;
-   API keys;
-   BYOK secrets;
-   tokens;
-   conteúdo sensível desnecessário.

Auditabilidade não justifica vazamento de segredo.

------------------------------------------------------------------------

# 55. Technical logs

Logs técnicos não devem ser persistidos como Audit Events por padrão.

Os dois sistemas possuem ciclos e propósitos diferentes.

------------------------------------------------------------------------

# 56. Analytics events

Analytics pode armazenar eventos como:

``` text
StatusPublished
DashboardViewed
DecisionMade
CopilotQueryCompleted
```

Preferencialmente sem copiar conteúdo de negócio desnecessário.

------------------------------------------------------------------------

# 57. Event schema

Eventos analíticos devem possuir versão.

Exemplo:

``` text
event_name
event_version
occurred_at
tenant_id
actor_id
properties
```

------------------------------------------------------------------------

# 58. Derived data

Dados derivados podem incluir:

-   KPI;
-   counts;
-   aggregations;
-   dashboard projections;
-   attention scores.

Toda derivação deve possuir fonte conhecida.

------------------------------------------------------------------------

# 59. Recomputability

Sempre que possível, projeções derivadas devem poder ser reconstruídas a
partir das fontes.

Isso reduz risco de inconsistência permanente.

------------------------------------------------------------------------

# 60. Materialized views

Podem ser usadas futuramente quando:

-   query é cara;
-   dados são read-heavy;
-   freshness aceitável;
-   estratégia de refresh é clara.

Não são requisito automático do MVP.

------------------------------------------------------------------------

# 61. Cache data

Cache nunca deve virar fonte oficial.

Deve ser descartável/reconstruível.

------------------------------------------------------------------------

# 62. My Day data

Preferência inicial:

``` text
query/projection from source entities
```

em vez de uma tabela duplicando todos os itens.

Se performance exigir materialização, preservar rastreabilidade.

------------------------------------------------------------------------

# 63. Dashboard data

Mesma regra:

``` text
Operational Sources
      ↓
Projection
      ↓
Dashboard
```

------------------------------------------------------------------------

# 64. Time Machine

Time Machine consulta Snapshots.

Não tenta reconstruir o passado apenas com `updated_at`.

------------------------------------------------------------------------

# 65. Report data

Relatórios podem usar:

``` text
Current State
```

ou:

``` text
Published Snapshot
```

O relatório deve deixar claro qual base temporal utiliza.

------------------------------------------------------------------------

# 66. AI context data

Context builder deve recuperar apenas:

-   Tenant autorizado;
-   Scope autorizado;
-   dados necessários;
-   classificação permitida.

------------------------------------------------------------------------

# 67. AI context minimization

Não enviar para o provider:

``` text
SELECT * FROM tenant
```

quando a pergunta exige apenas:

``` text
Project X Risks
```

------------------------------------------------------------------------

# 68. AI generated content

Conteúdo gerado por IA pode ser:

``` text
ephemeral
draft
stored artifact
```

A persistência depende do use case.

Não salvar automaticamente todo prompt/resposta como dado de negócio.

------------------------------------------------------------------------

# 69. AI telemetry

Pode registrar:

-   provider;
-   model;
-   latency;
-   token usage;
-   success/failure;
-   use case;
-   Tenant;
-   cost estimate.

Evitar armazenar prompt completo quando não necessário.

------------------------------------------------------------------------

# 70. BYOK data

Configuração deve separar:

``` text
Provider Metadata
```

de:

``` text
Secret Credential
```

Secret deve usar mecanismo seguro de armazenamento.

Nunca retornar valor completo após gravação.

------------------------------------------------------------------------

# 71. Import staging

Importações devem utilizar staging lógico ou físico.

``` text
Uploaded File
   ↓
Parsed Rows
   ↓
Validation Results
   ↓
Preview
   ↓
Confirmed Import
```

Evitar inserir diretamente antes de validação.

------------------------------------------------------------------------

# 72. Import row errors

Registrar erros por linha/campo quando possível.

Exemplo:

``` text
row_number
field
error_code
message
```

Sem expor dados sensíveis indevidamente.

------------------------------------------------------------------------

# 73. Import idempotency

Quando necessário, evitar duplicação em retry.

Estratégias:

-   import batch ID;
-   external key;
-   deduplication key;
-   unique constraint.

------------------------------------------------------------------------

# 74. External IDs

Integrações podem precisar:

``` text
external_system
external_entity_type
external_id
```

Não usar external ID como primary key interna.

------------------------------------------------------------------------

# 75. Sync metadata

Possíveis campos:

``` text
last_synced_at
sync_status
external_version
sync_error
```

Manter separados do estado de negócio quando apropriado.

------------------------------------------------------------------------

# 76. Source authority data

Quando campo é sincronizado, deve ser possível saber sua autoridade.

Evitar conflitos silenciosos entre:

``` text
Local edit
External sync
```

------------------------------------------------------------------------

# 77. Data lifecycle

Cada categoria deve considerar:

``` text
Create
Use
Update
Publish
Archive
Retain
Delete
```

Regras exatas serão definidas por domínio/compliance.

------------------------------------------------------------------------

# 78. Retention

Retention não deve ser uma regra global única.

Exemplos:

-   Audit;
-   Snapshots;
-   documents;
-   analytics;
-   technical logs;
-   temporary imports;

podem possuir períodos distintos.

------------------------------------------------------------------------

# 79. Temporary data

Dados temporários devem possuir cleanup.

Exemplos:

-   upload staging;
-   generated exports;
-   temporary AI artifacts;
-   failed import artifacts.

------------------------------------------------------------------------

# 80. Data privacy

Aplicar princípios:

-   minimization;
-   purpose limitation;
-   access control;
-   retention;
-   secure deletion quando aplicável;
-   traceability.

------------------------------------------------------------------------

# 81. LGPD

O produto deve permitir evolução compatível com obrigações aplicáveis de
LGPD.

Detalhamento jurídico/operacional não é definido apenas por arquitetura,
mas o modelo não deve impedir:

-   identificação de dados pessoais;
-   acesso controlado;
-   retention;
-   deletion/anonymization quando legalmente aplicável.

------------------------------------------------------------------------

# 82. PII

Evitar duplicar PII em múltiplas tabelas.

Referenciar identidade quando possível.

------------------------------------------------------------------------

# 83. Data encryption

Usar mecanismos de criptografia fornecidos pela infraestrutura para:

-   data in transit;
-   data at rest.

Segredos exigem proteção adicional apropriada.

------------------------------------------------------------------------

# 84. Database constraints

Usar constraints para proteger invariantes simples.

Exemplos:

-   non-null;
-   unique;
-   foreign key;
-   check;
-   valid ranges.

Não depender apenas do frontend.

------------------------------------------------------------------------

# 85. Domain constraints

Regras complexas continuam na camada de domínio/aplicação.

Banco e domínio podem trabalhar em defesa em profundidade.

------------------------------------------------------------------------

# 86. Tenant-safe foreign keys

O modelo físico deve impedir, quando viável, relações cross-tenant
acidentais.

Exemplo:

um Risk do Tenant A não pode referenciar Project do Tenant B.

Estratégias serão detalhadas no schema.

------------------------------------------------------------------------

# 87. Indexing

Índices serão definidos com base em queries.

Prováveis dimensões:

``` text
tenant_id
project_id
portfolio_id
status
owner_id
due_date
published_at
created_at
```

Evitar indexação indiscriminada.

------------------------------------------------------------------------

# 88. Composite indexes

Queries tenant-scoped frequentemente podem se beneficiar de índices
começando por:

``` text
tenant_id
```

A ordem depende do padrão real de consulta.

------------------------------------------------------------------------

# 89. Pagination

Listas potencialmente grandes devem possuir paginação.

Preferir estratégia apropriada à ordenação e volume.

Cursor pagination pode ser usada onde fizer sentido.

------------------------------------------------------------------------

# 90. Sorting

Ordenações devem ser determinísticas.

Quando campos podem empatar, usar tie-breaker consistente.

------------------------------------------------------------------------

# 91. Search

MVP pode utilizar capacidades PostgreSQL.

Possibilidades:

-   `ILIKE` controlado;
-   full-text search;
-   trigram quando necessário.

Elasticsearch/OpenSearch somente com necessidade comprovada.

------------------------------------------------------------------------

# 92. JSONB

JSONB é útil para:

-   Snapshot payload;
-   metadata flexível;
-   provider-specific configuration;
-   extensões controladas.

Não usar JSONB para evitar modelagem relacional de dados centrais.

------------------------------------------------------------------------

# 93. Enumerations

Estados importantes precisam de vocabulário controlado.

Podem ser implementados por:

-   DB enum;
-   constrained text;
-   reference table.

A escolha deve considerar migrations e extensibilidade.

------------------------------------------------------------------------

# 94. Status state machines

Estados do fluxo padrão MVP:

```text
Draft → Published → Superseded (quando corrigido por nova publicação)
```

`Under Review`/`PMO Review` não são estados obrigatórios no MVP. Toda transição deve ser explícita, autorizada no servidor e versionada; valores arbitrários são rejeitados.

# 95. Optimistic concurrency

Entidades com conflito provável podem usar:

``` text
version
```

ou mecanismo equivalente.

Exemplos:

-   Status Draft;
-   Decision;
-   Baseline.

------------------------------------------------------------------------

# 96. Database transactions

Casos que exigem atomicidade devem usar transações.

Principal:

``` text
Status Publication
```

Também podem incluir:

-   Risk materialization;
-   Decision + derived Action;
-   approved Baseline version;
-   batch import chunks.

------------------------------------------------------------------------

# 97. Transaction size

Evitar transações longas envolvendo:

-   LLM calls;
-   SMTP;
-   external APIs;
-   file processing.

Executar side effects externos depois do commit quando possível.

------------------------------------------------------------------------

# 98. Outbox pattern

Se consistência entre commit e dispatch assíncrono se tornar crítica,
avaliar transactional outbox.

Não é obrigatório introduzir no primeiro momento sem necessidade.

Candidato a ADR futuro.

------------------------------------------------------------------------

# 99. Data migration

Toda alteração de schema:

``` text
Migration
  ↓
Version Control
  ↓
Review
  ↓
Test
  ↓
Deploy
```

------------------------------------------------------------------------

# 100. Destructive migrations

Mudanças destrutivas devem possuir plano.

Preferir:

``` text
Expand
Migrate
Verify
Contract
```

quando necessário para deploy seguro.

------------------------------------------------------------------------

# 101. Backfill

Novos campos derivados ou obrigatórios podem exigir backfill.

Backfill deve ser:

-   idempotente quando possível;
-   observável;
-   testado;
-   tenant-safe.

------------------------------------------------------------------------

# 102. Seed data

Seeds podem conter:

-   default Roles;
-   Permissions;
-   system taxonomies;
-   development/demo data.

Nunca incluir segredo real.

------------------------------------------------------------------------

# 103. Demo data

Dados de demonstração devem ser sintéticos.

Devem representar cenários como:

``` text
Green Project
Amber Project
Red Project
Critical Risk
Overdue Action
Pending Decision
```

------------------------------------------------------------------------

# 104. Backup

A estratégia deve cobrir:

-   PostgreSQL;
-   Storage;
-   critical configuration.

Detalhamento operacional ficará em Deployment/DevOps.

------------------------------------------------------------------------

# 105. Restore

Backup só é útil se restore for possível.

Devem existir procedimentos/testes de recuperação compatíveis com
criticidade.

------------------------------------------------------------------------

# 106. RPO/RTO

Targets formais serão definidos em NFR/DevOps conforme maturidade e SLA.

Não inventar números antes de requisitos de negócio.

------------------------------------------------------------------------

# 107. Data observability

Monitorar:

-   DB errors;
-   connection health;
-   slow queries;
-   storage failures;
-   migration failures;
-   job/data pipeline failures;
-   integrity anomalies.

------------------------------------------------------------------------

# 108. Data quality monitoring

Possíveis checks:

-   orphan records;
-   missing owners;
-   invalid dates;
-   stale Status;
-   inconsistent RAG;
-   missing Snapshot;
-   cross-tenant relation attempts.

------------------------------------------------------------------------

# 109. Snapshot integrity check

Invariante:

``` text
Published Status
     ↓
Exactly one valid official Snapshot
```

conforme modelo final.

------------------------------------------------------------------------

# 110. Referential integrity

Preferir FK real quando a relação é relacional e estável.

Evitar depender exclusivamente de validação na aplicação.

------------------------------------------------------------------------

# 111. Historical references

Entidades históricas podem precisar preservar display values além de IDs
quando a semântica futura puder mudar.

Exemplo:

um Snapshot deve continuar mostrando contexto publicado mesmo se o nome
atual do Project mudar.

------------------------------------------------------------------------

# 112. De-normalization

Aceitável quando:

-   melhora leitura crítica;
-   reduz custo relevante;
-   existe fonte clara;
-   existe estratégia de sincronização/rebuild.

Não desnormalizar por conveniência prematura.

------------------------------------------------------------------------

# 113. Data warehouse

Não faz parte do MVP.

Analytics operacional pode começar sobre infraestrutura atual ou
mecanismo leve apropriado.

Warehouse dedicado só entra quando volume/BI exigir.

------------------------------------------------------------------------

# 114. Vector database

Não é requisito automático para IA.

Se retrieval semântico for necessário, avaliar:

-   PostgreSQL/pgvector;
-   solução externa;
-   requisitos de segurança;
-   volume;
-   custo.

A decisão pertence à AI/Data Architecture futura.

------------------------------------------------------------------------

# 115. Graph database

Não é necessário para Dependencies iniciais.

PostgreSQL suporta relações suficientes para o MVP.

------------------------------------------------------------------------

# 116. Event sourcing

O PMO Control não adotará Event Sourcing completo no MVP.

Histórico oficial é resolvido principalmente por:

``` text
Operational State
+
Audit Events
+
Published Snapshots
```

------------------------------------------------------------------------

# 117. Por que não Event Sourcing agora

Evita:

-   complexidade;
-   replay concerns;
-   schema evolution adicional;
-   curva operacional;
-   custo de desenvolvimento.

Pode ser reavaliado apenas com necessidade real.

------------------------------------------------------------------------

# 118. Data access patterns prioritários

A modelagem deve otimizar inicialmente:

-   My Day;
-   Project Control Center;
-   Project Dashboard;
-   Portfolio Dashboard;
-   Executive Portfolio;
-   Status workflow;
-   Time Machine;
-   Report Builder.

------------------------------------------------------------------------

# 119. My Day query patterns

Exemplos:

``` text
tenant + user + overdue Actions
tenant + scope + critical Risks
tenant + scope + critical Issues
tenant + scope + stale Status
tenant + user + pending Decisions
tenant + scope + upcoming Milestones
```

------------------------------------------------------------------------

# 120. Portfolio query patterns

Exemplos:

``` text
tenant + portfolio + active Projects
tenant + portfolio + RAG
tenant + portfolio + critical Risks
tenant + portfolio + pending Decisions
tenant + portfolio + upcoming Milestones
```

------------------------------------------------------------------------

# 121. Time Machine query patterns

``` text
tenant + project + publication sequence
tenant + project + published_at
```

Comparação usa dois Snapshots autorizados.

------------------------------------------------------------------------

# 122. Reporting query patterns

Relatórios devem declarar:

``` text
Current
```

ou:

``` text
Snapshot / As-of
```

para evitar mistura temporal.

------------------------------------------------------------------------

# 123. Data contract com Specs

Cada Spec funcional deverá declarar, quando aplicável:

-   entities;
-   reads;
-   writes;
-   state transitions;
-   data policies;
-   audit events;
-   retention implications;
-   Snapshot implications.

------------------------------------------------------------------------

# 124. Data contract com APIs

APIs não devem expor automaticamente o schema físico.

DTO/contracts podem diferir das tabelas.

Isso permite evolução interna.

------------------------------------------------------------------------

# 125. Data contract com IA

AI Context DTO deve ser explícito.

Não entregar objetos ORM completos para prompts.

------------------------------------------------------------------------

# 126. Data contract com integrações

Adapters traduzem:

``` text
External Model
      ↓
Canonical/Internal Contract
      ↓
Domain
```

Evitar contaminar entidades internas com formatos específicos de
providers.

------------------------------------------------------------------------

# 127. Data architecture decisions que exigem ADR

Candidatos:

1.  estratégia de Tenant isolation;
2.  RLS;
3.  Snapshot storage model;
4.  BYOK secret storage;
5.  transactional outbox, se adotado;
6.  search/vector strategy quando necessária;
7.  analytics architecture quando crescer.

------------------------------------------------------------------------

# 128. Invariantes de dados

1.  Todo dado tenant-scoped pertence inequivocamente a um Tenant.
2.  Nenhuma relação cross-tenant inválida é permitida.
3.  Published Snapshot é imutável.
4.  Baseline não é sobrescrita silenciosamente.
5.  Forecast e Actual possuem semânticas distintas.
6.  Risk materializado preserva relação com Issue.
7.  Decision history relevante é preservado.
8.  Audit não armazena secrets.
9.  Dashboard não é fonte.
10. Cache não é fonte.
11. AI recebe apenas contexto autorizado.
12. External IDs não substituem IDs internos.
13. Migrations são versionadas.
14. Published history sobrevive à evolução do estado atual.
15. Dados financeiros usam tipos apropriados.
16. Operações críticas usam atomicidade adequada.

------------------------------------------------------------------------

# 129. Próximo detalhamento

O modelo físico, tabelas, campos, constraints e relacionamentos serão
aprofundados em:

``` text
/docs/06-data/
```

Este documento permanece como arquitetura e princípios de dados.

------------------------------------------------------------------------

# 130. Referências

-   `/docs/02-architecture/README.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/01-product/mvp-scope.md`
-   `/docs/04-specs/`
-   `/docs/06-data/`

------------------------------------------------------------------------

# 131. Status

**Documento:** Data Architecture\
**Status:** Approved\
**Responsabilidade:** definir os princípios de persistência, tenancy,
integridade, estado atual, histórico publicado, auditoria, projeções,
documentos, IA e evolução do schema do PMO Control.
