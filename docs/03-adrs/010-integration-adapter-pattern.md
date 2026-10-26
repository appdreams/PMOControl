# ADR-010 --- Integration Adapter Pattern

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Isolar integrações externas através de contratos internos
e adapters específicos por provider, utilizando um Anti-Corruption Layer
para impedir que modelos, SDKs e semânticas externas contaminem o
domínio do PMO Control.

------------------------------------------------------------------------

## 1. Context

O PMO Control precisa integrar-se progressivamente a sistemas externos.

Exemplos:

-   SMTP;
-   Jira;
-   Azure DevOps;
-   GitHub;
-   Microsoft Project;
-   SharePoint;
-   Google Drive;
-   Teams;
-   Slack;
-   sistemas financeiros;
-   identity providers;
-   AI providers.

Cada plataforma possui:

-   autenticação própria;
-   APIs próprias;
-   modelos de dados próprios;
-   limites;
-   webhooks;
-   paginação;
-   erros;
-   versionamento;
-   semântica específica.

O domínio do PMO Control não deve depender diretamente dessas
particularidades.

------------------------------------------------------------------------

## 2. Problem

Sem uma fronteira arquitetural clara, módulos de negócio tenderiam a
chamar diretamente SDKs externos.

Exemplo indesejado:

``` text
Project Domain
    ↓
Jira SDK
```

Isso criaria:

-   forte acoplamento;
-   vendor lock-in;
-   testes difíceis;
-   regras duplicadas;
-   modelos externos vazando para o domínio;
-   substituição de provider custosa.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   desacoplamento;
-   testabilidade;
-   multi-provider;
-   source authority;
-   segurança;
-   resiliência;
-   observabilidade;
-   evolução;
-   normalização de erros;
-   controle de sync;
-   prevenção de corrupção do domínio.

------------------------------------------------------------------------

## 4. Decision

Adotar:

``` text
Domain / Application
        ↓
Internal Integration Contract
        ↓
Adapter
        ↓
External Provider
```

------------------------------------------------------------------------

## 5. Anti-Corruption Layer

Adapters funcionam como Anti-Corruption Layer.

Eles traduzem:

``` text
External Model
↔
PMO Control Model
```

sem fazer o domínio falar a linguagem do provider.

------------------------------------------------------------------------

## 6. Internal Contracts

Application layer depende de contratos internos.

Exemplo conceitual:

``` text
IssueTracker
DocumentProvider
NotificationProvider
SourceControlProvider
AIProvider
```

Não de SDK concreto.

------------------------------------------------------------------------

## 7. Provider Adapter

Exemplos:

``` text
JiraAdapter
AzureDevOpsAdapter
GitHubAdapter
SMTPAdapter
SharePointAdapter
```

Cada um encapsula detalhes específicos.

------------------------------------------------------------------------

## 8. Domain Independence

Entidades como:

``` text
Project
Risk
Issue
Action
Decision
Milestone
```

não devem importar tipos do Jira, Azure DevOps ou outros providers.

------------------------------------------------------------------------

## 9. External IDs

IDs externos ficam separados dos IDs internos.

Exemplo:

``` text
Internal Project ID
External System
External Entity Type
External Entity ID
```

------------------------------------------------------------------------

## 10. Mapping

Mappings precisam ser explícitos.

Não usar external ID como primary key interna.

------------------------------------------------------------------------

## 11. Source Authority

Toda integração deve declarar autoridade.

Exemplos:

``` text
PMO Control → authoritative
External System → authoritative
Bidirectional → explicit conflict policy
```

------------------------------------------------------------------------

## 12. No Implicit Bidirectional Sync

Sincronização bidirecional não será assumida automaticamente.

Ela aumenta significativamente:

-   conflitos;
-   loops;
-   versioning;
-   ownership ambiguity.

------------------------------------------------------------------------

## 13. Inbound Flow

``` text
External Provider
      ↓
Webhook / Poll
      ↓
Adapter
      ↓
Validate
      ↓
Map
      ↓
Application Use Case
      ↓
Domain Rules
      ↓
Persist
```

------------------------------------------------------------------------

## 14. Outbound Flow

``` text
Domain/Application Event
      ↓
Integration Workflow
      ↓
Internal Contract
      ↓
Adapter
      ↓
External Provider
```

------------------------------------------------------------------------

## 15. Adapter Does Not Bypass Domain

Adapter não escreve diretamente em tabelas de negócio para
"simplificar".

Alterações passam por use cases apropriados.

------------------------------------------------------------------------

## 16. Validation

Payload externo é untrusted input.

Validar:

-   schema;
-   types;
-   required fields;
-   identifiers;
-   Tenant mapping;
-   allowed values.

------------------------------------------------------------------------

## 17. Tenant Ownership

Toda configuração de integração é tenant-scoped.

``` text
Integration
tenant_id
provider
configuration
credential_reference
```

------------------------------------------------------------------------

## 18. Credential Isolation

Credential do Tenant A não pode ser usada pelo Tenant B.

------------------------------------------------------------------------

## 19. Secret Handling

Tokens/secrets:

-   server-side only;
-   encrypted appropriately;
-   never logged;
-   never exposed to browser unnecessarily;
-   referenced, not copied into job payloads.

------------------------------------------------------------------------

## 20. Authentication Methods

Adapters podem encapsular:

-   API key;
-   OAuth;
-   service account;
-   webhook secret;
-   future enterprise auth.

------------------------------------------------------------------------

## 21. Webhooks

Webhook flow:

``` text
Receive
 ↓
Verify Authenticity
 ↓
Check Replay/Idempotency
 ↓
Resolve Integration/Tenant
 ↓
Validate Payload
 ↓
Queue/Process
```

------------------------------------------------------------------------

## 22. Webhook Authenticity

Quando provider suportar:

-   signature;
-   secret;
-   timestamp;
-   challenge;

devem ser validados.

------------------------------------------------------------------------

## 23. Replay Protection

Eventos repetidos precisam ser detectados quando necessário.

------------------------------------------------------------------------

## 24. Idempotency

Integrações assumem delivery duplicado.

Handlers relevantes devem ser idempotentes.

------------------------------------------------------------------------

## 25. Pagination

Adapter encapsula paginação externa.

Application layer não deve conhecer detalhes desnecessários como cursor
específico do provider.

------------------------------------------------------------------------

## 26. Rate Limits

Adapter normaliza rate-limit handling.

Pode fornecer:

-   retry metadata;
-   backoff hints;
-   normalized error.

------------------------------------------------------------------------

## 27. Errors

Erro externo deve ser traduzido.

Exemplo:

``` text
ProviderUnauthorized
ProviderRateLimited
ProviderUnavailable
ProviderValidationError
ProviderNotFound
```

------------------------------------------------------------------------

## 28. No Provider Exceptions in Domain

Exceptions específicas de SDK não devem atravessar até o domínio.

------------------------------------------------------------------------

## 29. Retry

Falhas transitórias podem ser reprocessadas via Inngest.

------------------------------------------------------------------------

## 30. Permanent Failure

Credencial revogada ou configuração inválida deve produzir estado
observável e ação administrativa.

------------------------------------------------------------------------

## 31. Integration Status

Configuração pode possuir estados como:

``` text
Connected
Degraded
Authentication Failed
Disabled
```

------------------------------------------------------------------------

## 32. Health Check

Quando apropriado, integração pode possuir health check controlado.

------------------------------------------------------------------------

## 33. Sync State

Pode ser necessário armazenar:

-   last successful sync;
-   last attempt;
-   cursor/checkpoint;
-   error;
-   external version.

------------------------------------------------------------------------

## 34. Checkpoints

Polling incremental deve preservar checkpoint seguro quando provider
suportar.

------------------------------------------------------------------------

## 35. Conflict Resolution

Para integração bidirecional futura, cada campo/recurso deve possuir
política explícita.

Exemplos:

``` text
External Wins
PMO Control Wins
Manual Resolution
Version-based
```

------------------------------------------------------------------------

## 36. Loop Prevention

Sync bidirecional deve evitar:

``` text
A updates B
→ B webhook updates A
→ A updates B
→ ...
```

------------------------------------------------------------------------

## 37. Data Minimization

Importar apenas dados necessários ao use case.

------------------------------------------------------------------------

## 38. Data Classification

Antes de sincronizar dados sensíveis, respeitar classificação e política
do Tenant.

------------------------------------------------------------------------

## 39. Documents

Integrações documentais precisam distinguir:

``` text
Metadata
Binary
Link/Reference
```

e definir o que será copiado ou apenas referenciado.

------------------------------------------------------------------------

## 40. External Deletion

Exclusão externa não implica automaticamente exclusão interna.

Política deve ser definida por integração.

------------------------------------------------------------------------

## 41. Audit

Operações relevantes podem registrar:

-   provider;
-   integration;
-   direction;
-   resource;
-   actor/system;
-   result;
-   timestamp.

------------------------------------------------------------------------

## 42. Observability

Registrar metadata segura:

``` text
tenant_id
integration_id
provider
operation
correlation_id
duration
result
```

------------------------------------------------------------------------

## 43. Sensitive Logging

Nunca registrar:

-   access tokens;
-   refresh tokens;
-   passwords;
-   full secrets.

------------------------------------------------------------------------

## 44. Inngest Relationship

Processos longos/retryable usam Inngest quando apropriado.

``` text
Integration Event
      ↓
Inngest
      ↓
Adapter
```

------------------------------------------------------------------------

## 45. Synchronous Integration

Operação síncrona só quando experiência realmente exigir resposta
imediata e provider possuir confiabilidade adequada.

------------------------------------------------------------------------

## 46. Graceful Degradation

Falha de integração externa não deve derrubar o core do PMO Control.

------------------------------------------------------------------------

## 47. Source of Truth

PostgreSQL continua fonte de verdade interna para estado governado pelo
PMO Control.

Integrações não criam automaticamente uma segunda verdade interna.

------------------------------------------------------------------------

## 48. Option A --- Direct SDK Calls

### Vantagens

-   rápido inicialmente.

### Desvantagens

-   acoplamento;
-   difícil teste;
-   vendor-specific logic espalhada;
-   migração difícil.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 49. Option B --- Generic Universal Integration Layer

Criar abstração única capaz de representar qualquer provider.

### Vantagens

-   aparência de padronização.

### Desvantagens

-   lowest common denominator;
-   abstração artificial;
-   esconde capabilities úteis;
-   complexidade prematura.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 50. Option C --- Internal Contracts + Provider Adapters

### Vantagens

-   domínio protegido;
-   testável;
-   extensível;
-   provider-specific behavior isolado;
-   permite capabilities específicas.

### Desvantagens

-   mais código;
-   mapping;
-   manutenção por adapter.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 51. Capability Model

Contracts podem declarar capabilities.

Exemplo:

``` text
canReadIssues
canCreateIssues
supportsWebhooks
supportsIncrementalSync
```

------------------------------------------------------------------------

## 52. Provider-Specific Features

Feature específica pode existir sem contaminar o core, desde que isolada
atrás de boundary explícito.

------------------------------------------------------------------------

## 53. Testing Strategy

Cada adapter deve possuir:

-   contract tests;
-   mapping tests;
-   error normalization tests;
-   auth failure tests;
-   pagination tests;
-   rate-limit tests;
-   idempotency tests quando aplicável.

------------------------------------------------------------------------

## 54. Mocking

Application tests devem conseguir substituir adapter real por fake/test
implementation.

------------------------------------------------------------------------

## 55. Sandbox

Quando provider possuir sandbox/test environment, utilizá-lo para
integração real controlada.

------------------------------------------------------------------------

## 56. Contract Evolution

Mudança de API externa não deve obrigar mudança de domínio se semântica
interna não mudou.

------------------------------------------------------------------------

## 57. API Versioning

Adapter encapsula versões do provider.

------------------------------------------------------------------------

## 58. Deprecation

Se provider descontinuar endpoint:

``` text
Update Adapter
```

preferencialmente sem alterar use case.

------------------------------------------------------------------------

## 59. Configuration

Settings deve armazenar configuração por Tenant de forma segura e
auditável.

------------------------------------------------------------------------

## 60. Enable / Disable

Tenant deve poder desabilitar integração sem remover dados históricos
relacionados.

------------------------------------------------------------------------

## 61. Import/Export

Import/export de arquivos também segue boundary de validação/mapping,
ainda que não seja API integration.

------------------------------------------------------------------------

## 62. Future Integration Registry

Pode existir registry interno:

``` text
Provider
Capabilities
Auth Type
Status
Configuration Schema
```

sem tornar o domínio dependente dele.

------------------------------------------------------------------------

## 63. Public API

Uma futura API pública do PMO Control é uma interface externa distinta
dos adapters outbound/inbound de providers.

------------------------------------------------------------------------

## 64. Webhook Outbound

Futuros webhooks do PMO Control devem possuir:

-   signing;
-   retries;
-   idempotency semantics;
-   event version;
-   observability.

------------------------------------------------------------------------

## 65. Security Review

Nova integração exige análise de:

-   data exposure;
-   credentials;
-   scopes;
-   webhook security;
-   Tenant isolation;
-   retention;
-   provider terms;
-   failure modes.

------------------------------------------------------------------------

## 66. Least Privilege

Solicitar ao provider apenas scopes necessários.

------------------------------------------------------------------------

## 67. OAuth

OAuth future flow deve vincular callback ao Tenant e usuário/contexto
corretos com state/anti-CSRF apropriado.

------------------------------------------------------------------------

## 68. Revocation

Credential revogada deve impedir novas operações e gerar estado claro.

------------------------------------------------------------------------

## 69. Reconciliation

Integrações críticas podem possuir job de reconciliation para detectar
divergências.

------------------------------------------------------------------------

## 70. Eventual Consistency

Integrações assíncronas podem ser eventualmente consistentes.

UI deve comunicar estados como:

``` text
Syncing
Last synced at
Sync failed
```

quando relevante.

------------------------------------------------------------------------

## 71. Architecture Invariants

1.  Domain não importa SDK externo.
2.  External IDs não são primary keys internas.
3.  Payload externo é untrusted.
4.  Tenant é resolvido antes de persistência.
5.  Credential é tenant-scoped.
6.  Secrets não aparecem em logs/jobs.
7.  Adapter não bypassa Domain/Application.
8.  Source authority é explícita.
9.  Bidirectional sync não é implícita.
10. Retryable operations são idempotentes quando necessário.
11. External failure não derruba o core.
12. Provider errors são normalizados.
13. Least privilege é aplicado.
14. Integration changes são observáveis.

------------------------------------------------------------------------

## 72. Revisit Triggers

Reavaliar se:

1.  quantidade de integrações justificar plataforma dedicada;
2.  enterprise integration hub se tornar requisito;
3.  volume exigir streaming especializado;
4.  ETL/ELT massivo virar caso central;
5.  integração marketplace exigir SDK/plugin architecture;
6.  requisitos de workflow ultrapassarem adapters atuais.

------------------------------------------------------------------------

## 73. Non-Triggers

Não introduzir ESB/iPaaS próprio apenas porque existem várias
integrações.

A complexidade deve acompanhar necessidade real.

------------------------------------------------------------------------

## 74. Relationship with ADR-008

Inngest executa workflows assíncronos; adapters encapsulam providers.

São responsabilidades diferentes.

------------------------------------------------------------------------

## 75. Relationship with ADR-009

AI Gateway aplica o mesmo princípio de adapter, especializado para
modelos de IA.

------------------------------------------------------------------------

## 76. Relationship with ADR-012

Adapter Pattern permite integração limpa sem exigir infraestrutura
distribuída prematura.

------------------------------------------------------------------------

## 77. References

-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/integration-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/03-adrs/008-inngest-background-workflows.md`
-   `/docs/03-adrs/009-ai-gateway-byok.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 78. Decision Summary

``` text
Decision:
Integrate external systems through internal contracts
and provider-specific adapters.

Architecture:
Domain/Application
→ Internal Contract
→ Adapter
→ External Provider

Why:
Protect the PMO Control domain from vendor-specific
models, SDKs, errors and lifecycle changes.

Core Rules:
Explicit source authority.
Tenant-scoped credentials.
Validated external input.
No direct provider writes to business tables.

Revisit:
When integration scale or enterprise requirements
justify a broader integration platform.
```

------------------------------------------------------------------------

**ADR:** ADR-010\
**Status:** Accepted
