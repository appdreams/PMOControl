# ADR-011 --- Vercel Deployment

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Adotar Vercel como plataforma inicial de deployment e
runtime da aplicação web Next.js do PMO Control, integrada ao GitHub e
aos serviços gerenciados definidos na arquitetura do MVP.

------------------------------------------------------------------------

## 1. Context

O PMO Control será desenvolvido inicialmente com:

``` text
Next.js
TypeScript
Supabase/PostgreSQL/Auth/Storage
Inngest
SMTP
AI Gateway + BYOK
```

A solução precisa de uma plataforma de deployment que reduza overhead
operacional e permita ao time concentrar esforço no produto, domínio,
segurança e governança.

Como o frontend e os principais entry points server-side serão
construídos em Next.js, Vercel possui aderência natural ao stack
inicial.

------------------------------------------------------------------------

## 2. Problem

É necessário definir onde a aplicação Next.js será:

-   construída;
-   publicada;
-   executada;
-   configurada;
-   observada;
-   promovida entre ambientes.

A decisão deve equilibrar:

-   velocidade;
-   simplicidade;
-   segurança;
-   escalabilidade;
-   custo;
-   portabilidade;
-   operação.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   compatibilidade com Next.js;
-   integração GitHub;
-   deployments automatizados;
-   Preview environments;
-   managed runtime;
-   HTTPS;
-   environment configuration;
-   baixa carga operacional;
-   escalabilidade inicial;
-   rollback/deployment history;
-   boa experiência de desenvolvimento.

------------------------------------------------------------------------

## 4. Decision

Adotar:

``` text
GitHub
   ↓
CI / Quality Gates
   ↓
Vercel
   ↓
Next.js Application
```

como pipeline principal de deployment da aplicação web.

------------------------------------------------------------------------

## 5. Vercel Responsibility

Vercel será responsável inicialmente por:

-   build da aplicação;
-   hosting;
-   Next.js runtime;
-   routing;
-   HTTPS;
-   deployment;
-   Preview environments;
-   Production deployment;
-   environment variables apropriadas;
-   platform-level runtime telemetry disponível.

------------------------------------------------------------------------

## 6. What Vercel Is Not

Vercel não será:

-   banco de dados;
-   durable workflow engine;
-   object storage principal;
-   source of truth;
-   secret store de BYOK por Tenant;
-   message broker.

Essas responsabilidades permanecem separadas.

------------------------------------------------------------------------

## 7. Initial Topology

``` text
Browser
   ↓
Vercel / Next.js
   ↓
Application / Domain
   ├── Supabase
   ├── Inngest
   ├── SMTP
   ├── AI Providers
   └── Integration Providers
```

------------------------------------------------------------------------

## 8. GitHub as Source

Código-fonte e migrations versionadas permanecem no GitHub.

Production não é a fonte de configuração lógica do sistema.

------------------------------------------------------------------------

## 9. Branch / Pull Request Flow

Fluxo recomendado:

``` text
Feature Branch
    ↓
Pull Request
    ↓
Automated Checks
    ↓
Preview
    ↓
Review
    ↓
Merge
    ↓
Production Deployment
```

A política concreta pode evoluir conforme tamanho do time.

------------------------------------------------------------------------

## 10. Preview Environments

Preview deployments serão usados para:

-   validar UI;
-   testar integração;
-   validar mudanças;
-   revisar features.

Preview não deve usar dados ou credentials de Production
indiscriminadamente.

------------------------------------------------------------------------

## 11. Environment Isolation

Ambientes mínimos:

``` text
Development
Preview/Test
Production
```

Cada ambiente deve possuir configuração e credenciais próprias.

------------------------------------------------------------------------

## 12. Production Data

Production data não deve ser copiada para Preview sem processo explícito
de sanitização e autorização.

------------------------------------------------------------------------

## 13. Environment Variables

Variáveis de ambiente podem armazenar configuração de infraestrutura
adequada.

Exemplos:

-   Supabase endpoint;
-   server-side platform credentials;
-   Inngest configuration;
-   SMTP configuration;
-   feature-level infrastructure settings.

------------------------------------------------------------------------

## 14. Tenant Secrets

BYOK e integration credentials específicas de Tenant não devem ser
tratadas como variáveis globais de deployment.

São dados secretos tenant-scoped e exigem storage apropriado.

------------------------------------------------------------------------

## 15. Client vs Server Variables

Somente configuração explicitamente pública pode ser exposta ao browser.

Secrets permanecem server-side.

------------------------------------------------------------------------

## 16. Build-Time vs Runtime

Configuração deve distinguir:

``` text
Build-time configuration
```

de:

``` text
Runtime configuration
```

para evitar secrets incorporados indevidamente ao bundle.

------------------------------------------------------------------------

## 17. Server-Side Authorization

Deploy em Vercel não altera o princípio:

``` text
Browser is not a security boundary.
```

Autorização sensível continua server-side.

------------------------------------------------------------------------

## 18. Serverless Runtime

A aplicação deve ser projetada considerando características do runtime
gerenciado:

-   requests limitados;
-   stateless execution;
-   connection management;
-   external service calls;
-   cold/warm execution behavior;
-   provider limits.

------------------------------------------------------------------------

## 19. Stateless Application

Estado de negócio não deve depender da memória local da instância.

Fonte persistente:

``` text
PostgreSQL
```

------------------------------------------------------------------------

## 20. Local Filesystem

Não utilizar filesystem efêmero do runtime como armazenamento
persistente.

Arquivos de negócio usam Supabase Storage ou solução definida
posteriormente.

------------------------------------------------------------------------

## 21. Long-Running Work

Tarefas longas não devem permanecer presas a request web.

Preferência:

``` text
Request
 ↓
Persist Intent/State
 ↓
Inngest
 ↓
Background Workflow
```

------------------------------------------------------------------------

## 22. Database Connections

Acesso ao PostgreSQL deve respeitar estratégia compatível com ambiente
serverless/managed.

Connection pooling e limites do provider precisam ser considerados.

------------------------------------------------------------------------

## 23. Critical Transactions

Transações críticas continuam no PostgreSQL.

Vercel apenas hospeda o entry point/application logic.

------------------------------------------------------------------------

## 24. Status Publication

Fluxo crítico:

``` text
Vercel Request
    ↓
Application Use Case
    ↓
PostgreSQL Transaction
    ↓
Publication + Snapshot + Audit
    ↓
Commit
```

Efeitos pós-commit podem usar Inngest.

------------------------------------------------------------------------

## 25. Deployment Atomicity

Nova versão deve ser promovida de forma controlada.

Evitar situação em que application code incompatível seja publicado
antes de migrations necessárias.

------------------------------------------------------------------------

## 26. Migration Compatibility

Preferência:

``` text
Expand
 ↓
Deploy Compatible Code
 ↓
Backfill / Verify
 ↓
Contract
```

------------------------------------------------------------------------

## 27. Database Migrations

Migrations são executadas por processo controlado.

Não depender de edição manual de Production.

------------------------------------------------------------------------

## 28. Backward Compatibility

Durante deployment, pode existir breve período com versões diferentes de
código/jobs.

Mudanças de schema e event payloads devem considerar compatibilidade.

------------------------------------------------------------------------

## 29. Inngest Compatibility

Workflows existentes podem continuar executando durante deployment.

Mudanças precisam considerar runs em andamento.

------------------------------------------------------------------------

## 30. Rollback

Rollback de aplicação não significa automaticamente rollback de database
migration.

Por isso migrations destrutivas exigem cautela.

------------------------------------------------------------------------

## 31. CI Quality Gates

Antes de Production, executar conforme maturidade:

-   lint;
-   type check;
-   unit tests;
-   integration tests;
-   authorization tests;
-   tenant isolation tests;
-   build;
-   migration validation;
-   security checks.

------------------------------------------------------------------------

## 32. Security Gate

Falha em testes críticos de:

``` text
Tenant Isolation
Authorization
RLS
Snapshot Integrity
```

deve bloquear release.

------------------------------------------------------------------------

## 33. Secrets

Secrets de infraestrutura devem utilizar mecanismos seguros da
plataforma/processo.

Nunca versionar secrets no Git.

------------------------------------------------------------------------

## 34. Secret Rotation

Arquitetura deve permitir rotação de credentials sem alteração de
código.

------------------------------------------------------------------------

## 35. Production Access

Acesso administrativo a Production segue least privilege.

------------------------------------------------------------------------

## 36. Deployment Permissions

Nem todo desenvolvedor precisa necessariamente possuir permissão para
alterar Production diretamente.

------------------------------------------------------------------------

## 37. Auditability

Deployments precisam ser rastreáveis a:

-   commit;
-   actor/process;
-   timestamp;
-   version.

------------------------------------------------------------------------

## 38. Observability

A solução deve permitir acompanhar:

-   request errors;
-   latency;
-   deployment failures;
-   server-side exceptions;
-   external dependency failures;
-   correlation IDs.

------------------------------------------------------------------------

## 39. Application Logging

Logs devem ser estruturados quando apropriado e não conter:

-   passwords;
-   BYOK;
-   access tokens;
-   confidential document contents.

------------------------------------------------------------------------

## 40. Correlation

Fluxos distribuídos podem usar:

``` text
correlation_id
```

através de:

-   request;
-   database operation;
-   job;
-   integration;
-   AI call.

------------------------------------------------------------------------

## 41. Health

A aplicação deve distinguir dependências críticas de degradáveis.

------------------------------------------------------------------------

## 42. Critical Dependency

Exemplo:

``` text
PostgreSQL unavailable
```

pode impedir operações centrais.

------------------------------------------------------------------------

## 43. Degradable Dependency

Exemplo:

``` text
AI provider unavailable
```

não deve derrubar o core.

------------------------------------------------------------------------

## 44. Graceful Degradation

UI deve comunicar indisponibilidade parcial quando apropriado.

------------------------------------------------------------------------

## 45. Regions

A região de deployment deve considerar proximidade do banco e requisitos
de residência de dados.

A configuração concreta dependerá das opções disponíveis e requisitos
comerciais.

------------------------------------------------------------------------

## 46. Latency

Evitar distância desnecessária entre application runtime e database.

------------------------------------------------------------------------

## 47. Data Residency

Se clientes exigirem residência/região específica, a topologia poderá
precisar evoluir.

------------------------------------------------------------------------

## 48. Scaling

Vercel fornece scaling gerenciado do runtime web dentro dos limites da
plataforma.

Escalar application runtime não resolve automaticamente gargalos no
banco ou providers externos.

------------------------------------------------------------------------

## 49. Performance Strategy

Antes de adicionar infraestrutura:

``` text
Measure
 ↓
Optimize
 ↓
Index
 ↓
Reduce Payload
 ↓
Cache if justified
 ↓
Scale selectively
```

------------------------------------------------------------------------

## 50. CDN / Caching

Caching só deve ser aplicado quando semanticamente seguro.

Dados tenant-specific e permission-sensitive não podem vazar por cache
compartilhado incorreto.

------------------------------------------------------------------------

## 51. Cache Key

Se cache futuro contiver dados de Tenant, a chave deve considerar
contexto suficiente.

------------------------------------------------------------------------

## 52. Public Assets

Assets realmente públicos podem aproveitar caching/CDN agressivo.

------------------------------------------------------------------------

## 53. Private Data

Dados privados não devem ser transformados em public static assets.

------------------------------------------------------------------------

## 54. Option A --- Vercel

### Vantagens

-   integração forte com Next.js;
-   Preview deployments;
-   managed infrastructure;
-   baixa operação;
-   Git integration;
-   rápida entrega.

### Desvantagens

-   platform limits;
-   vendor dependency;
-   custo pode crescer;
-   workloads específicos podem exigir outra infraestrutura.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 55. Option B --- Self-Managed VM

### Vantagens

-   controle total.

### Desvantagens

-   patching;
-   scaling;
-   reverse proxy;
-   TLS;
-   deployment;
-   monitoring;
-   maior operação.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 56. Option C --- Kubernetes

### Vantagens

-   alto controle;
-   workload orchestration;
-   portability.

### Desvantagens

-   complexidade operacional muito superior;
-   desnecessário para MVP;
-   exige observabilidade e expertise adicionais.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 57. Option D --- Other Managed Container Platform

### Vantagens

-   maior flexibilidade de runtime.

### Desvantagens

-   menor benefício imediato para stack Next.js atual;
-   mais configuração.

### Resultado

**Not selected initially.**

Pode ser reavaliado se workload exigir.

------------------------------------------------------------------------

## 58. Consequences --- Positive

-   menor overhead;
-   deployment rápido;
-   Preview environments;
-   boa integração com Next.js;
-   escala inicial gerenciada;
-   menor esforço DevOps.

------------------------------------------------------------------------

## 59. Consequences --- Negative

-   dependência da plataforma;
-   runtime limits;
-   custo pode aumentar;
-   workloads longos precisam sair do request;
-   arquitetura precisa respeitar serverless constraints.

------------------------------------------------------------------------

## 60. Mitigations

-   domínio desacoplado;
-   PostgreSQL externo como source of truth;
-   Inngest para background;
-   adapters para providers;
-   standard web/runtime patterns;
-   observability;
-   migrations portáveis.

------------------------------------------------------------------------

## 61. Vendor Lock-in

O sistema não deve depender desnecessariamente de APIs proprietárias da
Vercel dentro do domínio.

------------------------------------------------------------------------

## 62. Portability

A aplicação Next.js deve permanecer razoavelmente migrável para outro
runtime compatível se necessário.

------------------------------------------------------------------------

## 63. Backup

Vercel deployment não substitui estratégia de backup de banco/Storage.

------------------------------------------------------------------------

## 64. Disaster Recovery

Recovery envolve múltiplos componentes:

``` text
Source Code
Database
Storage
Secrets
Configuration
Jobs
External Integrations
```

------------------------------------------------------------------------

## 65. Availability

SLA comercial futuro deve considerar a cadeia completa, não apenas
Vercel.

------------------------------------------------------------------------

## 66. Cost Monitoring

Monitorar:

-   build usage;
-   bandwidth;
-   runtime;
-   function execution;
-   logs/observability;
-   related managed services.

------------------------------------------------------------------------

## 67. Preview Cost

Preview environments também consomem recursos e precisam de governança
quando o time crescer.

------------------------------------------------------------------------

## 68. Testing

Cobrir:

-   production build;
-   environment configuration;
-   server/client secret separation;
-   database connectivity;
-   Inngest integration;
-   auth callbacks;
-   external callbacks/webhooks;
-   deployment compatibility.

------------------------------------------------------------------------

## 69. Release Checklist

Antes de Production:

``` text
Tests Green
Migrations Safe
Secrets Configured
Tenant Isolation Green
Authorization Green
Build Green
Critical Integrations Checked
Rollback Considered
```

------------------------------------------------------------------------

## 70. Revisit Triggers

Reavaliar Vercel se:

1.  runtime limits bloquearem workloads;
2.  custo tornar-se desproporcional;
3.  compliance exigir outra infraestrutura;
4.  regional deployment não atender requisitos;
5.  workloads exigirem containers persistentes;
6.  networking privado tornar-se requisito;
7.  enterprise SLA exigir topologia diferente;
8.  escala demonstrar benefício econômico/técnico de migração.

------------------------------------------------------------------------

## 71. Non-Triggers

Não migrar apenas porque:

-   Kubernetes parece mais enterprise;
-   containers são mais tradicionais;
-   equipe deseja controlar servidores;
-   arquitetura cresceu em número de módulos.

------------------------------------------------------------------------

## 72. Migration Path

Se necessário:

``` text
Preserve Domain/Application Boundaries
      ↓
Externalize Platform-specific Configuration
      ↓
Validate Next.js Runtime Compatibility
      ↓
Provision New Runtime
      ↓
Configure Secrets/Networking
      ↓
Deploy
      ↓
Validate
      ↓
Cut Over
```

------------------------------------------------------------------------

## 73. Architecture Invariants

1.  PostgreSQL permanece source of truth.
2.  Vercel não armazena estado persistente de negócio em
    memória/filesystem.
3.  Secrets não chegam ao browser.
4.  Tenant credentials não são env vars globais.
5.  Long-running work usa background workflow.
6.  Preview e Production são isolados.
7.  Production data não é copiada indiscriminadamente.
8.  Migrations são versionadas.
9.  Security tests bloqueiam release.
10. Provider failure degradável não derruba o core.
11. Cache não pode causar cross-tenant leakage.
12. Deployment é rastreável a código/versionamento.

------------------------------------------------------------------------

## 74. Relationship with ADR-002

ADR-002 define Next.js + TypeScript.

ADR-011 define Vercel como runtime/deployment inicial dessa aplicação.

------------------------------------------------------------------------

## 75. Relationship with ADR-003

Supabase/PostgreSQL permanece plataforma de dados externa ao runtime
Vercel.

------------------------------------------------------------------------

## 76. Relationship with ADR-008

Inngest executa workloads assíncronos que não devem depender do ciclo de
vida de requests Vercel.

------------------------------------------------------------------------

## 77. Relationship with ADR-012

Vercel faz parte da estratégia de utilizar serviços gerenciados antes de
introduzir infraestrutura distribuída autogerenciada.

------------------------------------------------------------------------

## 78. References

-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/deployment-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/03-adrs/002-nextjs-typescript.md`
-   `/docs/03-adrs/003-supabase-postgresql.md`
-   `/docs/03-adrs/008-inngest-background-workflows.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 79. Decision Summary

``` text
Decision:
Deploy the PMO Control Next.js application on Vercel.

Pipeline:
GitHub
→ Quality Gates
→ Preview
→ Production

Supporting Services:
Supabase
Inngest
SMTP
AI/Integration Providers

Why:
Vercel provides the best initial balance of Next.js
compatibility, delivery speed and low operational overhead.

Constraint:
Persistent business state remains outside the runtime,
and long-running work is delegated to background workflows.

Revisit:
When measured cost, compliance, regional, networking,
runtime or SLA requirements justify another platform.
```

------------------------------------------------------------------------

**ADR:** ADR-011\
**Status:** Accepted
