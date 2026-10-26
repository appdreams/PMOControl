# PMO Control --- Integration Architecture

**Documento:** `integration-architecture.md`\
**Camada:** Architecture\
**Status:** Approved\
**Tipo:** Arquitetura de integrações, adapters, sincronização, webhooks
e source authority

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a arquitetura de integrações do PMO Control.

O objetivo é permitir que o produto se conecte progressivamente aos
sistemas onde a execução, documentos, comunicação e dados financeiros já
existem, sem transformar integrações em acoplamentos diretos com o
domínio.

A arquitetura cobre:

-   princípios de integração;
-   adapters;
-   contracts;
-   source authority;
-   autenticação e credenciais;
-   sincronização;
-   webhooks;
-   polling;
-   imports e exports;
-   idempotência;
-   retries;
-   conflitos;
-   observabilidade;
-   segurança;
-   evolução para novos providers.

------------------------------------------------------------------------

# 2. Princípio central

``` text
Integrate without contaminating the domain.
```

O modelo interno do PMO Control não deve se tornar uma cópia do modelo
de Jira, Azure DevOps, Microsoft Project ou qualquer outro sistema
externo.

------------------------------------------------------------------------

# 3. Objetivo de negócio

Integrações devem reduzir:

``` text
Duplicate Update
Manual Re-entry
Data Collection
Status Chasing
```

e aumentar:

``` text
Freshness
Traceability
Automation
Governance Context
```

------------------------------------------------------------------------

# 4. Integração não é requisito para o Core Governance Loop

O MVP deve funcionar com dados inseridos diretamente no PMO Control.

``` text
External Integration Failure
≠
Core PMO Failure
```

Integrações ampliam produtividade; não são a única forma de o domínio
existir.

------------------------------------------------------------------------

# 5. Arquitetura conceitual

``` text
PMO Control Domain
        │
        ▼
Integration Contract
        │
        ▼
Integration Service
        │
        ▼
Provider Adapter
        │
        ▼
External System
```

------------------------------------------------------------------------

# 6. Anti-Corruption Layer

Adapters atuam como uma Anti-Corruption Layer.

Responsabilidade:

``` text
External Model
      ↓
Translate
      ↓
Internal Contract
```

Isso impede que conceitos específicos de provider se espalhem pelo
domínio.

------------------------------------------------------------------------

# 7. Providers candidatos

Possíveis integrações futuras:

## Execução

-   Jira;
-   Azure DevOps;
-   GitHub;
-   Microsoft Project.

## Documentos

-   SharePoint;
-   OneDrive;
-   Google Drive.

## Comunicação

-   Microsoft Teams;
-   Slack;
-   SMTP/e-mail.

## Financeiro

-   ERP/corporate financial systems.

A ordem depende de demanda comprovada.

------------------------------------------------------------------------

# 8. Integration Registry

Cada integração configurada deve possuir registro conceitual contendo:

-   Tenant;
-   provider;
-   status;
-   authentication type;
-   scopes;
-   configuration;
-   source authority;
-   last successful sync;
-   health;
-   secret reference.

------------------------------------------------------------------------

# 9. Tenant ownership

Toda integração pertence a um Tenant.

``` text
Integration A
      ↓
Tenant A only
```

Credenciais e dados não podem ser reutilizados entre Tenants sem
configuração explícita.

------------------------------------------------------------------------

# 10. Provider Adapter

Exemplos:

``` text
JiraAdapter
AzureDevOpsAdapter
GitHubAdapter
SharePointAdapter
```

O adapter encapsula:

-   API format;
-   authentication details;
-   pagination;
-   provider errors;
-   rate limits;
-   provider-specific mapping.

------------------------------------------------------------------------

# 11. Integration Contract

O contrato interno deve utilizar linguagem do PMO Control.

Exemplo conceitual:

``` text
ExternalWorkItem
ExternalProject
ExternalDocument
ExternalActualCost
```

e não objetos SDK específicos atravessando toda a aplicação.

------------------------------------------------------------------------

# 12. Source Authority

Toda integração precisa declarar autoridade.

Pergunta:

> **Qual sistema é a fonte oficial deste dado?**

Exemplo:

``` text
Jira
= source for execution task status

PMO Control
= source for governance Risk
```

------------------------------------------------------------------------

# 13. Authority por campo

Source authority pode variar por campo.

Exemplo:

``` text
Project.name          → PMO Control
Project.actualProgress → Azure DevOps
Project.RAG           → PMO Control
```

Essa configuração deve ser explícita quando suportada.

------------------------------------------------------------------------

# 14. Modos de autoridade

Possíveis:

``` text
PMO_CONTROL
EXTERNAL
MANUAL_REVIEW
DERIVED
```

Evitar ownership implícito.

------------------------------------------------------------------------

# 15. Direção de sincronização

Cada mapping deve declarar:

``` text
Inbound
Outbound
Bidirectional
```

Bidirectional sync deve ser exceção e possuir conflict policy clara.

------------------------------------------------------------------------

# 16. Preferência inicial

Sempre que possível:

``` text
External execution data
      ↓
PMO Control governance
```

é mais simples e seguro que sincronização bidirecional ampla.

------------------------------------------------------------------------

# 17. Mapping

Mapping conecta conceitos externos a internos.

Exemplo:

``` text
Jira Epic
   ↓
Deliverable

Jira Due Date
   ↓
forecast_date
```

O mapping deve ser versionável/configurável quando necessário.

------------------------------------------------------------------------

# 18. External identifiers

Persistir:

``` text
provider
external_entity_type
external_id
internal_entity_id
```

quando necessário.

External ID nunca substitui o ID interno.

------------------------------------------------------------------------

# 19. Sync metadata

Possíveis atributos:

``` text
last_synced_at
last_success_at
sync_status
external_version
last_error_code
```

Separar metadata de integração do estado de negócio sempre que possível.

------------------------------------------------------------------------

# 20. Estratégias de sincronização

Possíveis:

1.  webhook;
2.  polling;
3.  scheduled sync;
4.  user-triggered sync;
5.  import;
6.  outbound event.

Escolher conforme capacidade do provider e necessidade.

------------------------------------------------------------------------

# 21. Webhook-first quando apropriado

Se provider possuir webhook confiável:

``` text
External Change
      ↓
Webhook
      ↓
Validation
      ↓
Async Processing
```

pode reduzir polling.

------------------------------------------------------------------------

# 22. Polling

Polling é adequado quando:

-   provider não oferece webhook;
-   webhook não cobre evento;
-   reconciliação periódica é necessária.

Frequência deve considerar:

-   freshness;
-   rate limits;
-   cost;
-   volume.

------------------------------------------------------------------------

# 23. Reconciliation

Mesmo com webhook, pode existir reconciliação periódica.

Objetivo:

-   detectar eventos perdidos;
-   corrigir drift;
-   validar consistência.

------------------------------------------------------------------------

# 24. Webhook runtime

``` text
External Provider
      ↓
Webhook Endpoint
      ↓
Signature Verification
      ↓
Replay Protection
      ↓
Schema Validation
      ↓
Integration Resolution
      ↓
Idempotency
      ↓
Queue/Workflow
      ↓
Mapping
      ↓
Domain/Application Command
```

------------------------------------------------------------------------

# 25. Webhook acknowledgment

Endpoint deve responder rapidamente quando possível.

Processamento pesado deve ocorrer assíncronamente após validação
inicial.

------------------------------------------------------------------------

# 26. Webhook security

Aplicar quando disponível:

-   signature;
-   timestamp;
-   secret;
-   IP restrictions quando justificadas;
-   replay protection;
-   schema validation.

------------------------------------------------------------------------

# 27. Idempotência

Eventos externos podem ser entregues mais de uma vez.

``` text
Same External Event
      ↓
Same Business Effect Once
```

Usar:

-   event ID;
-   deduplication key;
-   external version;
-   unique constraint;
-   processing record.

------------------------------------------------------------------------

# 28. Ordering

Eventos podem chegar fora de ordem.

Quando provider fornece versão/timestamp confiável, usar para evitar
regressão de estado.

------------------------------------------------------------------------

# 29. At-least-once assumption

Arquitetura deve assumir que entrega externa/assíncrona pode ser:

``` text
At Least Once
```

e projetar consumidores idempotentes.

------------------------------------------------------------------------

# 30. Sync pipeline

``` text
Fetch/Receive
    ↓
Authenticate
    ↓
Validate
    ↓
Normalize
    ↓
Resolve Mapping
    ↓
Resolve Authority
    ↓
Detect Conflict
    ↓
Apply
    ↓
Audit/Telemetry
```

------------------------------------------------------------------------

# 31. Aplicação de dados externos

Dados externos não devem ser escritos diretamente no banco por adapters.

Preferência:

``` text
Adapter
  ↓
Application Use Case
  ↓
Domain Validation
  ↓
Persistence
```

------------------------------------------------------------------------

# 32. External data is untrusted

Mesmo provider autenticado pode retornar:

-   conteúdo inválido;
-   campos inesperados;
-   strings maliciosas;
-   datas inválidas;
-   IDs ausentes.

Validar antes de persistir.

------------------------------------------------------------------------

# 33. Conflict detection

Conflito ocorre quando:

``` text
Local changed
+
External changed
+
Both claim authority
```

A arquitetura deve detectar em vez de sobrescrever silenciosamente.

------------------------------------------------------------------------

# 34. Conflict policies

Possíveis:

``` text
External Wins
PMO Control Wins
Newest Valid Version Wins
Manual Review
Field-specific Authority
```

Política deve ser explícita.

------------------------------------------------------------------------

# 35. Manual review

Para conflitos de governança sensíveis:

``` text
Conflict
   ↓
Pending Review
   ↓
Authorized User
   ↓
Resolution
```

é preferível a merge automático inseguro.

------------------------------------------------------------------------

# 36. Outbound synchronization

Fluxo:

``` text
Domain Change
    ↓
Integration Eligibility
    ↓
Outbound Mapping
    ↓
Async Job
    ↓
Provider Adapter
    ↓
External API
```

Falha externa não deve desfazer automaticamente mudança local já
confirmada, salvo transação distribuída explicitamente projetada.

------------------------------------------------------------------------

# 37. Distributed transactions

Não usar transação distribuída entre PMO Control e providers externos no
MVP.

Preferir:

``` text
Local Commit
   ↓
Async External Effect
   ↓
Retry / Compensation / Manual Resolution
```

------------------------------------------------------------------------

# 38. Integration state

Estado de sincronização deve ser visível quando relevante.

Exemplos:

``` text
Synced
Pending
Failed
Conflict
Disconnected
```

------------------------------------------------------------------------

# 39. Retry policy

Retries devem ser aplicados a falhas transitórias:

-   timeout;
-   temporary network error;
-   rate limit;
-   provider 5xx.

Não repetir indefinidamente:

-   invalid credentials;
-   permission denied;
-   invalid mapping;
-   deleted external resource.

------------------------------------------------------------------------

# 40. Backoff

Usar exponential backoff/jitter quando apropriado.

Respeitar headers de rate limit/retry do provider.

------------------------------------------------------------------------

# 41. Dead-letter / failed operations

Após tentativas configuradas:

``` text
Failed Integration Operation
```

deve ficar observável e recuperável.

Não desaparecer silenciosamente.

------------------------------------------------------------------------

# 42. Reprocessing

Operações falhas devem permitir retry seguro.

Idempotência precisa impedir efeitos duplicados.

------------------------------------------------------------------------

# 43. Rate limits

Adapters devem compreender limites do provider.

Controles:

-   throttling;
-   batching;
-   caching apropriado;
-   backoff;
-   scheduling.

------------------------------------------------------------------------

# 44. Pagination

Adapters devem encapsular paginação externa.

O domínio não deve saber se provider usa:

``` text
page
offset
cursor
continuationToken
```

------------------------------------------------------------------------

# 45. API versioning externo

Adapters devem isolar versões de API.

Mudança:

``` text
Jira API vX → vY
```

deve impactar prioritariamente o adapter.

------------------------------------------------------------------------

# 46. Provider capability matrix

Cada provider pode declarar capacidades:

``` text
read_projects
read_work_items
write_work_items
webhooks
documents
comments
users
```

Use cases verificam capability antes de usar.

------------------------------------------------------------------------

# 47. Authentication methods

Possíveis:

-   OAuth 2.0;
-   API token;
-   PAT;
-   service account;
-   webhook secret.

Cada provider define seu método.

------------------------------------------------------------------------

# 48. Credential storage

Secrets ficam em armazenamento seguro server-side.

Nunca:

-   browser storage;
-   Git;
-   plain logs;
-   analytics.

------------------------------------------------------------------------

# 49. OAuth

Fluxo conceitual:

``` text
Tenant Admin
    ↓
Connect Provider
    ↓
Authorization Redirect
    ↓
Callback
    ↓
State Validation
    ↓
Token Exchange
    ↓
Secure Token Storage
```

------------------------------------------------------------------------

# 50. OAuth token refresh

Refresh deve ser:

-   server-side;
-   observable;
-   tenant-bound;
-   safely retried.

Falha permanente deve marcar integração como requerendo reconexão.

------------------------------------------------------------------------

# 51. Least privilege

Solicitar apenas scopes necessários.

Não pedir acesso de escrita se integração é read-only.

------------------------------------------------------------------------

# 52. Revocation

Tenant Admin deve poder desconectar integração.

Processo:

``` text
Disable
Revoke provider token when supported
Remove/disable secret
Stop jobs
Audit
```

------------------------------------------------------------------------

# 53. Integration configuration

Configurações podem incluir:

-   project mapping;
-   field mapping;
-   sync direction;
-   frequency;
-   authority;
-   filters;
-   notification policy.

------------------------------------------------------------------------

# 54. Configuration validation

Antes de ativar:

-   validar credentials;
-   validar resource;
-   validar permissions;
-   validar mappings mínimos.

------------------------------------------------------------------------

# 55. Integration health

Estado resumido:

``` text
Healthy
Degraded
Disconnected
Error
```

Pode considerar:

-   credential validity;
-   last success;
-   failure rate;
-   webhook health;
-   backlog.

------------------------------------------------------------------------

# 56. Observability

Registrar:

``` text
tenant_id
integration_id
provider
operation
correlation_id
duration
result
error category
retry count
```

Sem secrets.

------------------------------------------------------------------------

# 57. Metrics

Possíveis:

-   sync success rate;
-   sync latency;
-   webhook processing time;
-   retry rate;
-   conflict rate;
-   provider error rate;
-   stale integration count;
-   records synchronized.

------------------------------------------------------------------------

# 58. Logs

Logs devem permitir troubleshooting sem expor payload completo
desnecessariamente.

Aplicar redaction.

------------------------------------------------------------------------

# 59. Audit

Eventos auditáveis:

-   integration connected;
-   disconnected;
-   credentials replaced;
-   authority changed;
-   mapping changed;
-   manual conflict resolution;
-   privileged outbound action.

------------------------------------------------------------------------

# 60. Correlation

Fluxo externo deve preservar correlation ID quando possível:

``` text
Webhook
  ↓
Job
  ↓
Domain Command
  ↓
Audit
```

------------------------------------------------------------------------

# 61. Jira integration

Possível uso:

-   Projects;
-   Epics;
-   Issues;
-   status;
-   dates;
-   progress;
-   assignments.

Não assumir equivalência direta entre Jira Issue e PMO Control Issue.

------------------------------------------------------------------------

# 62. Jira semantic distinction

``` text
Jira Issue
```

é work item genérico.

``` text
PMO Control Issue
```

é problema de governança materializado.

O adapter precisa traduzir explicitamente.

------------------------------------------------------------------------

# 63. Azure DevOps integration

Possíveis fontes:

-   work items;
-   iterations;
-   epics/features;
-   delivery progress;
-   repositories/pipelines quando relevante.

A integração deve focar governança, não replicar todo Azure DevOps.

------------------------------------------------------------------------

# 64. GitHub integration

Possíveis sinais:

-   repository activity;
-   issues;
-   pull requests;
-   releases;
-   workflow status.

Somente quando úteis para Project governance.

------------------------------------------------------------------------

# 65. Microsoft Project

Possíveis:

-   schedule;
-   tasks;
-   milestones;
-   dependencies;
-   baseline/forecast dates.

Source authority deve ser especialmente clara para Schedule.

------------------------------------------------------------------------

# 66. SharePoint / OneDrive / Google Drive

Objetivo principal:

``` text
Document/Evidence reference
```

Evitar copiar todos os arquivos se link seguro/referência for
suficiente.

------------------------------------------------------------------------

# 67. External document reference

Pode armazenar:

-   provider;
-   external ID;
-   title;
-   URL/reference;
-   metadata;
-   classification;
-   last validated access.

Acesso ainda depende de policy.

------------------------------------------------------------------------

# 68. Teams / Slack

Casos:

-   notification;
-   Decision request;
-   reminder;
-   summary;
-   future controlled actions.

Evitar transformar canal de chat em source of truth de governança.

------------------------------------------------------------------------

# 69. E-mail

SMTP é integração inicial simples.

E-mail é canal de comunicação, não fonte oficial de estado.

Links levam ao PMO Control para ação governada.

------------------------------------------------------------------------

# 70. Financial systems

Integração financeira pode importar:

-   Actual;
-   Budget;
-   Forecast inputs;
-   cost center references.

PMO Control continua sendo ferramenta de governança, não ledger
contábil.

------------------------------------------------------------------------

# 71. User mapping

Sistemas externos podem possuir identidades diferentes.

Possíveis estratégias:

-   e-mail verified mapping;
-   explicit mapping;
-   external user ID relation.

Não mapear automaticamente por nome.

------------------------------------------------------------------------

# 72. Project mapping

Um Project interno pode mapear:

``` text
1 → 1 external project
```

ou futuramente:

``` text
1 → N external sources
```

O modelo não deve assumir 1:1 universal.

------------------------------------------------------------------------

# 73. Multi-source integration

Exemplo:

``` text
Project ERP
 ├── Azure DevOps → execution
 ├── SharePoint → Evidence
 └── ERP → Actual costs
```

Source authority resolve responsabilidades.

------------------------------------------------------------------------

# 74. Canonical data

Não criar um "canonical mega-model" contendo todos os campos de todos os
providers.

Criar contratos internos focados nos use cases.

------------------------------------------------------------------------

# 75. Import/Export relationship

Import/Export é uma forma de integração desacoplada.

Pode ser primeira opção antes de API real.

Exemplo:

``` text
Excel Import
```

pode validar demanda antes de construir connector complexo.

------------------------------------------------------------------------

# 76. Import security

Arquivos são não confiáveis.

Pipeline:

``` text
Upload
 ↓
Validate
 ↓
Parse
 ↓
Map
 ↓
Preview
 ↓
Confirm
 ↓
Apply
```

------------------------------------------------------------------------

# 77. Import authority

Import não deve sobrescrever campo governado sem regra explícita.

------------------------------------------------------------------------

# 78. Export security

Export respeita:

``` text
Tenant
Role
Scope
Permission
Data Policy
```

e pode gerar Audit Event.

------------------------------------------------------------------------

# 79. Integration jobs

Inngest é o mecanismo inicial para:

-   sync;
-   retry;
-   scheduled reconciliation;
-   webhook processing;
-   outbound operations.

------------------------------------------------------------------------

# 80. Job idempotency

Cada job deve ter chave/estratégia apropriada.

Exemplo:

``` text
integration_id + external_event_id
```

------------------------------------------------------------------------

# 81. Job payload minimization

Passar IDs e metadata mínima quando possível.

Buscar dados sensíveis no servidor durante execução autorizada.

------------------------------------------------------------------------

# 82. Concurrency

Evitar dois syncs concorrentes incompatíveis da mesma integração.

Pode exigir:

-   concurrency key;
-   lock;
-   version check;
-   provider cursor control.

------------------------------------------------------------------------

# 83. Incremental sync

Preferir incremental quando provider suporta.

Exemplo:

``` text
updated_since
cursor
change token
```

em vez de full scan frequente.

------------------------------------------------------------------------

# 84. Full reconciliation

Ainda pode existir periodicamente para detectar drift.

------------------------------------------------------------------------

# 85. Deletes externos

Definir política.

Possíveis:

``` text
Archive local mapping
Mark external missing
Manual review
Delete derived record
```

Nunca apagar histórico governado automaticamente sem regra.

------------------------------------------------------------------------

# 86. External rename

Mudança de nome externo não deve alterar identidade.

Usar external ID estável.

------------------------------------------------------------------------

# 87. Schema evolution externo

Adapters devem tolerar campos adicionais e detectar breaking changes.

------------------------------------------------------------------------

# 88. Contract tests

Criar testes por adapter.

Podem incluir:

-   mapping;
-   pagination;
-   errors;
-   rate limits;
-   webhook validation;
-   idempotency.

------------------------------------------------------------------------

# 89. Sandbox/test accounts

Quando providers permitirem, usar ambientes/contas de teste.

Não depender de Production para testes automatizados.

------------------------------------------------------------------------

# 90. Mock adapters

Desenvolvimento/testes devem poder utilizar adapters simulados.

Isso reduz dependência de APIs externas.

------------------------------------------------------------------------

# 91. Integration feature flags

Novos connectors podem ser ativados por:

-   environment;
-   Tenant;
-   plan;
-   beta group.

------------------------------------------------------------------------

# 92. Rollout

Fluxo recomendado:

``` text
Internal
 ↓
Pilot Tenant
 ↓
Limited Availability
 ↓
General Availability
```

para integrações relevantes.

------------------------------------------------------------------------

# 93. Integration catalog

Futuro Settings pode mostrar:

``` text
Available
Connected
Needs Attention
Coming Later
```

Não implica marketplace no MVP.

------------------------------------------------------------------------

# 94. Connector SDK

Não construir framework/SDK público de connectors antes de existirem
padrões repetidos suficientes.

Primeiro implementar alguns adapters reais.

Depois extrair abstrações comprovadas.

------------------------------------------------------------------------

# 95. Public API

Uma API pública futura pode ser outro canal de integração.

Ela deve possuir:

-   versioning;
-   auth;
-   rate limiting;
-   Tenant isolation;
-   permissions;
-   Audit para operações sensíveis.

------------------------------------------------------------------------

# 96. Webhook outbound

PMO Control poderá futuramente emitir eventos:

``` text
StatusPublished
RiskEscalated
DecisionMade
ActionOverdue
```

para sistemas autorizados.

------------------------------------------------------------------------

# 97. Event payload

Payload externo deve ser minimizado.

Preferir:

``` text
event
resource_id
tenant-safe metadata
link
```

em vez de enviar conteúdo confidencial desnecessário.

------------------------------------------------------------------------

# 98. Delivery signing

Webhooks outbound devem possuir assinatura/verificação quando
implementados.

------------------------------------------------------------------------

# 99. Integration and AI

Dados de integrações só podem entrar no contexto de IA após:

-   normalização;
-   autorização;
-   classificação;
-   source tracking.

------------------------------------------------------------------------

# 100. Untrusted external content and AI

Texto vindo de Jira, documentos ou chat pode conter prompt injection.

Tratar como:

``` text
Untrusted Business Data
```

------------------------------------------------------------------------

# 101. Integration freshness

Dados sincronizados devem permitir identificar recência.

Exemplo:

``` text
last_synced_at
```

O Copilot e dashboards podem sinalizar stale data.

------------------------------------------------------------------------

# 102. Offline provider

Quando provider estiver indisponível:

-   mostrar último estado conhecido;
-   indicar sync issue;
-   preservar operação local quando possível;
-   retry.

------------------------------------------------------------------------

# 103. Circuit breaker

Pode ser adotado quando falhas repetidas causarem impacto operacional.

Não é requisito inicial para todo adapter.

------------------------------------------------------------------------

# 104. Bulkheads

Se volume crescer, integrações de alto custo podem receber
limites/concurrency separados para não degradar o core.

------------------------------------------------------------------------

# 105. Data residency

Providers externos podem ter implicações de região/residência.

Avaliar em contextos enterprise/compliance quando necessário.

------------------------------------------------------------------------

# 106. Provider terms

Antes de integração comercial, considerar:

-   API terms;
-   quotas;
-   retention;
-   data use;
-   security;
-   licensing.

------------------------------------------------------------------------

# 107. LGPD/privacy

Integração não autoriza coleta indiscriminada.

Aplicar:

-   minimização;
-   finalidade;
-   classificação;
-   retention;
-   controlled access.

------------------------------------------------------------------------

# 108. Failure taxonomy

Categorias:

``` text
AUTHENTICATION
AUTHORIZATION
RATE_LIMIT
TIMEOUT
NETWORK
PROVIDER_5XX
INVALID_PAYLOAD
MAPPING
CONFLICT
NOT_FOUND
CONFIGURATION
UNKNOWN
```

------------------------------------------------------------------------

# 109. User-facing errors

Não mostrar stack/provider internals desnecessários.

Exemplo:

> "A sincronização com Azure DevOps falhou por credencial expirada.
> Reconecte a integração."

é melhor que erro técnico bruto.

------------------------------------------------------------------------

# 110. Operations dashboard futuro

Pode mostrar:

-   integrations healthy;
-   failed jobs;
-   sync lag;
-   conflicts;
-   disconnected credentials;
-   rate limit issues.

------------------------------------------------------------------------

# 111. Integration SLOs

Não inventar SLOs antes de requisitos reais.

Definir após conhecer:

-   criticidade;
-   provider limits;
-   customer expectation;
-   sync mode.

------------------------------------------------------------------------

# 112. MVP integration scope

O Core MVP não depende de connectors completos.

Prioridade:

``` text
Import/Export
SMTP
AI Provider
```

e connectors corporativos entram conforme roadmap/demanda.

------------------------------------------------------------------------

# 113. Critério para nova integração

Antes de construir:

1.  qual persona precisa?
2.  qual trabalho manual reduz?
3.  qual dado será integrado?
4.  quem é source of truth?
5.  read ou write?
6.  qual volume?
7.  qual risco?
8.  qual manutenção esperada?
9.  qual métrica melhora?
10. existe alternativa por import?

------------------------------------------------------------------------

# 114. Métricas de valor

Uma integração deve idealmente melhorar:

-   Status Freshness;
-   Manual Re-entry Rate;
-   Parallel Control Rate;
-   Portfolio Consolidation Time;
-   data completeness.

Não medir sucesso apenas por "connector instalado".

------------------------------------------------------------------------

# 115. Architecture decisions candidatas a ADR

1.  Integration Adapter Pattern;
2.  credential storage;
3.  webhook processing;
4.  sync metadata model;
5.  source authority representation;
6.  conflict strategy;
7.  outbound event delivery;
8.  public API strategy;
9.  transactional outbox, se necessário.

------------------------------------------------------------------------

# 116. Invariantes de integração

1.  Toda integração pertence a Tenant.
2.  Secrets permanecem server-side.
3.  External ID não é ID interno.
4.  Provider model não invade o domínio.
5.  Source authority é explícita.
6.  Bidirectional sync exige conflict policy.
7.  External data é não confiável.
8.  Webhooks são autenticados/validados quando suportado.
9.  Consumers são idempotentes.
10. Retries não duplicam efeitos.
11. Falha externa não corrompe estado local.
12. Integração não amplia autorização.
13. Export respeita Data Policy.
14. Dados externos enviados à IA continuam sujeitos a autorização.
15. Sync possui observabilidade.
16. Mudanças sensíveis de configuração são auditadas.
17. Integrações são adicionadas por valor comprovado.
18. Core Governance Loop funciona sem connector corporativo.

------------------------------------------------------------------------

# 117. Relação com `/docs/10-integrations/`

Este documento define a arquitetura.

A pasta:

``` text
/docs/10-integrations/
```

deverá detalhar:

-   provider specs;
-   authentication;
-   mappings;
-   sync direction;
-   source authority;
-   webhook contracts;
-   errors;
-   retries;
-   test strategy;
-   operational runbooks.

------------------------------------------------------------------------

# 118. Relação com Specs

Features que dependem de integração devem declarar:

-   provider;
-   required capability;
-   source authority;
-   fallback;
-   failure behavior;
-   authorization;
-   Audit;
-   freshness expectations.

------------------------------------------------------------------------

# 119. Referências

-   `/docs/02-architecture/README.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/02-architecture/ai-architecture.md`
-   `/docs/01-product/roadmap.md`
-   `/docs/04-specs/028-import-export/`
-   `/docs/10-integrations/`

------------------------------------------------------------------------

# 120. Status

**Documento:** Integration Architecture\
**Status:** Approved\
**Responsabilidade:** definir como o PMO Control se conecta a sistemas
externos por meio de contracts e adapters seguros, preservando source
authority, isolamento, idempotência, observabilidade e independência do
domínio.
