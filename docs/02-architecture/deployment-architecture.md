# PMO Control --- Deployment Architecture

**Documento:** `deployment-architecture.md`\
**Camada:** Architecture\
**Status:** Approved\
**Tipo:** Arquitetura de deployment, ambientes, runtime, configuração,
observabilidade e recuperação

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a arquitetura de deployment do PMO Control.

Ele estabelece como o sistema será entregue, configurado, executado e
operado no MVP, cobrindo:

-   topologia de runtime;
-   ambientes;
-   CI/CD;
-   Vercel;
-   Supabase;
-   Inngest;
-   SMTP;
-   providers de IA;
-   configuração e secrets;
-   migrations;
-   observabilidade;
-   backups e recovery;
-   rollback;
-   segurança operacional;
-   evolução de infraestrutura.

------------------------------------------------------------------------

# 2. Princípio central

``` text
Simple to deploy.
Safe to change.
Observable in production.
Recoverable when something fails.
```

A infraestrutura deve acompanhar a necessidade real do produto.

------------------------------------------------------------------------

# 3. Stack do MVP

``` text
Application
Next.js + TypeScript

Hosting / Runtime
Vercel

Database
Supabase PostgreSQL

Authentication
Supabase Auth

Object Storage
Supabase Storage

Background Workflows
Inngest

Source Control
GitHub

E-mail
SMTP configurável

AI
BYOK per Tenant
```

------------------------------------------------------------------------

# 4. Componentes fora do MVP

Não introduzir sem evidência:

``` text
Kubernetes
Redis
Kafka
RabbitMQ
Elasticsearch
Neo4j
Firebase
```

A ausência desses componentes é uma decisão de simplicidade, não
limitação arquitetural permanente.

------------------------------------------------------------------------

# 5. Topologia inicial

``` text
                    ┌───────────────┐
                    │    Browser    │
                    └───────┬───────┘
                            │ HTTPS
                            ▼
                    ┌───────────────┐
                    │    Vercel     │
                    │ Next.js App   │
                    └───┬───┬───┬───┘
                        │   │   │
          ┌─────────────┘   │   └──────────────┐
          ▼                 ▼                  ▼
 ┌────────────────┐  ┌────────────┐    ┌─────────────┐
 │    Supabase    │  │  Inngest   │    │ AI Provider │
 │ DB/Auth/Storage│  │   Jobs     │    │   BYOK      │
 └────────────────┘  └────────────┘    └─────────────┘
          │
          │
          └──────────────────────┐
                                 ▼
                          ┌────────────┐
                          │ SMTP / APIs│
                          └────────────┘
```

------------------------------------------------------------------------

# 6. Deployment unit

O MVP possui uma aplicação principal implantável.

``` text
PMO Control Web Application
```

Módulos internos não possuem deploy independente.

Isso é coerente com o monólito modular.

------------------------------------------------------------------------

# 7. Ambientes

Arquitetura deve prever pelo menos:

``` text
Development
Preview/Test
Production
```

Ambientes adicionais podem surgir conforme maturidade.

------------------------------------------------------------------------

# 8. Development

Objetivos:

-   desenvolvimento local;
-   testes;
-   migrations;
-   debugging;
-   mocks;
-   integração com serviços não produtivos.

Nunca depender de credenciais Production.

------------------------------------------------------------------------

# 9. Preview/Test

Objetivos:

-   validar Pull Requests;
-   acceptance;
-   integração;
-   regressão;
-   demonstrações controladas.

Preview não deve compartilhar indiscriminadamente dados ou secrets de
Production.

------------------------------------------------------------------------

# 10. Production

Ambiente oficial.

Requisitos:

-   configuração controlada;
-   migrations revisadas;
-   secrets protegidos;
-   observabilidade;
-   backup/recovery;
-   acesso restrito.

------------------------------------------------------------------------

# 11. Environment isolation

Regra:

``` text
Environment A credentials
≠
Environment B credentials
```

Separar, quando aplicável:

-   database;
-   Auth;
-   Storage;
-   Inngest;
-   SMTP;
-   AI credentials;
-   integration credentials.

------------------------------------------------------------------------

# 12. GitHub

GitHub é o sistema de controle de versão.

Recomendações:

-   protected main branch;
-   Pull Requests;
-   code review;
-   CI checks;
-   secret scanning;
-   dependency alerts;
-   tagged releases quando apropriado.

------------------------------------------------------------------------

# 13. Branch strategy

Preferir fluxo simples.

Exemplo:

``` text
feature/*
   ↓
Pull Request
   ↓
main
   ↓
Production
```

Evitar complexidade de branching sem necessidade.

------------------------------------------------------------------------

# 14. Continuous Integration

Pipeline deve validar pelo menos:

``` text
Install
Lint
Type Check
Unit Tests
Integration Tests
Build
Security Checks
```

Testes adicionais entram conforme maturidade.

------------------------------------------------------------------------

# 15. Security gates

Para mudanças relevantes:

-   dependency scan;
-   secret scan;
-   authorization tests;
-   tenant isolation tests;
-   migration validation.

------------------------------------------------------------------------

# 16. Continuous Deployment

Fluxo conceitual:

``` text
GitHub
  ↓
CI
  ↓
Preview Deployment
  ↓
Validation
  ↓
Merge
  ↓
Production Deployment
```

------------------------------------------------------------------------

# 17. Vercel

Responsabilidades principais:

-   aplicação Next.js;
-   build;
-   deploy;
-   edge/CDN capabilities quando aplicáveis;
-   environment variables;
-   preview deployments.

------------------------------------------------------------------------

# 18. Runtime placement

Código que exige:

-   secrets;
-   privileged database access;
-   AI keys;
-   integration credentials;

deve executar exclusivamente no servidor.

------------------------------------------------------------------------

# 19. Client bundle

Nunca incluir:

-   Supabase service-role secret;
-   BYOK;
-   SMTP password;
-   integration tokens;
-   private signing secrets.

------------------------------------------------------------------------

# 20. Supabase

No MVP fornece:

``` text
PostgreSQL
Auth
Storage
```

A configuração deve ser tratada como infraestrutura crítica.

------------------------------------------------------------------------

# 21. Database connectivity

Conexões devem considerar:

-   limites do ambiente serverless;
-   pooling quando necessário;
-   timeout;
-   observabilidade;
-   least privilege.

A configuração concreta dependerá das capacidades atuais do provider.

------------------------------------------------------------------------

# 22. Database migrations

Toda mudança de schema:

``` text
Code Change
   ↓
Migration
   ↓
Version Control
   ↓
CI/Test
   ↓
Controlled Deployment
```

------------------------------------------------------------------------

# 23. Migration rule

Production não deve depender de alterações manuais não versionadas no
schema.

------------------------------------------------------------------------

# 24. Migration compatibility

Mudanças críticas devem considerar compatibilidade entre versão de
aplicação e schema durante rollout.

Preferir quando necessário:

``` text
Expand
  ↓
Deploy compatible code
  ↓
Backfill
  ↓
Verify
  ↓
Contract
```

------------------------------------------------------------------------

# 25. Destructive migrations

Exigem cuidado especial.

Antes de remover coluna/tabela:

-   verificar uso;
-   migrar dados;
-   remover dependência de código;
-   validar;
-   somente então destruir.

------------------------------------------------------------------------

# 26. Backfills

Backfills grandes não devem necessariamente rodar dentro da migration
transacional.

Podem usar job controlado.

Devem ser:

-   idempotentes quando possível;
-   observáveis;
-   tenant-safe;
-   retomáveis.

------------------------------------------------------------------------

# 27. Supabase Auth deployment concerns

Configurações por ambiente incluem:

-   redirect URLs;
-   e-mail templates;
-   provider settings;
-   session policies;
-   allowed origins.

------------------------------------------------------------------------

# 28. Storage

Buckets e policies devem ser definidos por ambiente.

Production documents não devem aparecer em Preview/Test.

------------------------------------------------------------------------

# 29. Inngest

Inngest executa:

-   background jobs;
-   retries;
-   scheduled workflows;
-   async integration processing;
-   notifications;
-   AI/report processing.

------------------------------------------------------------------------

# 30. Job deployment

Functions/workflows devem ser versionados junto da aplicação quando
possível.

Mudanças precisam considerar jobs ainda em execução.

------------------------------------------------------------------------

# 31. Job compatibility

Não remover imediatamente handlers necessários para eventos já
enfileirados.

Quando relevante, versionar event schema/handler.

------------------------------------------------------------------------

# 32. Job idempotency

Retries são esperados.

Toda operação com side effect precisa considerar duplicação.

------------------------------------------------------------------------

# 33. Job concurrency

Configurar limites quando necessário para:

-   Tenant;
-   integration;
-   provider;
-   resource.

Evitar que um Tenant monopolize processamento.

------------------------------------------------------------------------

# 34. Scheduled workflows

Exemplos:

-   overdue detection;
-   Status reminders;
-   integration reconciliation;
-   cleanup;
-   future digests.

------------------------------------------------------------------------

# 35. SMTP

SMTP deve ser configurável por ambiente.

Credenciais ficam server-side.

------------------------------------------------------------------------

# 36. E-mail failure

Falha de e-mail não deve invalidar operação de negócio já confirmada.

``` text
Decision created
      ↓
Email failed
      ↓
Decision remains valid
      ↓
Retry notification
```

------------------------------------------------------------------------

# 37. AI providers

Providers externos são dependências não críticas para core correctness.

Arquitetura:

``` text
Application
   ↓
AI Gateway
   ↓
Tenant Configuration
   ↓
Provider
```

------------------------------------------------------------------------

# 38. AI provider deployment configuration

Separar:

-   application-level provider capabilities;
-   Tenant BYOK;
-   model policy;
-   feature enablement.

------------------------------------------------------------------------

# 39. BYOK

Segredos de Tenant não devem ser tratados como environment variables
globais quando cada Tenant possui chave própria.

Precisam de armazenamento seguro tenant-scoped.

------------------------------------------------------------------------

# 40. Integration credentials

Mesmo princípio do BYOK:

``` text
Tenant-specific credentials
```

não pertencem a arquivos `.env` globais.

------------------------------------------------------------------------

# 41. Environment variables

Adequadas para:

-   application configuration;
-   service endpoints;
-   environment-specific service credentials;
-   signing/config secrets.

Não para dados dinâmicos de Tenant.

------------------------------------------------------------------------

# 42. Configuration hierarchy

Conceitualmente:

``` text
Code Defaults
      ↓
Environment Configuration
      ↓
Tenant Configuration
      ↓
Feature/Module Configuration
```

Regras devem definir quais níveis podem sobrescrever outros.

------------------------------------------------------------------------

# 43. Secrets management

Secrets devem:

-   permanecer fora do Git;
-   ser acessíveis somente ao runtime necessário;
-   ser rotacionáveis;
-   não aparecer em logs;
-   possuir ownership claro.

------------------------------------------------------------------------

# 44. Secret rotation

Planejar rotação para:

-   service credentials;
-   SMTP;
-   signing secrets;
-   provider credentials.

Rotação deve minimizar downtime.

------------------------------------------------------------------------

# 45. Configuration validation

Aplicação deve validar configuração essencial no startup/build quando
apropriado.

Falhar cedo é preferível a comportamento indefinido.

------------------------------------------------------------------------

# 46. Feature flags

Podem apoiar:

-   staged rollout;
-   Tenant pilots;
-   experimental AI;
-   connector beta;
-   migration.

------------------------------------------------------------------------

# 47. Feature flag safety

Flag não substitui autorização.

``` text
Feature Enabled
≠
User Authorized
```

------------------------------------------------------------------------

# 48. Observability

Três dimensões principais:

``` text
Logs
Metrics
Traces/Correlation
```

A solução concreta pode evoluir.

------------------------------------------------------------------------

# 49. Structured logging

Logs estruturados devem incluir quando seguro:

``` text
timestamp
level
environment
service
module
operation
request_id
correlation_id
tenant_id
user_id
job_id
error_code
```

------------------------------------------------------------------------

# 50. Log redaction

Nunca registrar:

-   passwords;
-   API keys;
-   access tokens;
-   refresh tokens;
-   BYOK;
-   integration secrets;
-   confidential payloads sem necessidade.

------------------------------------------------------------------------

# 51. Correlation IDs

Permitem rastrear:

``` text
HTTP Request
  ↓
Domain Operation
  ↓
Database
  ↓
Job
  ↓
External Provider
```

------------------------------------------------------------------------

# 52. Error tracking

Erros inesperados devem ser capturados com:

-   stack no ambiente protegido;
-   environment;
-   release/version;
-   correlation;
-   context seguro.

------------------------------------------------------------------------

# 53. Metrics

Monitorar inicialmente:

-   request latency;
-   error rate;
-   database errors;
-   job success/failure;
-   job latency;
-   AI provider errors;
-   integration errors;
-   notification failures.

------------------------------------------------------------------------

# 54. Business-critical technical metrics

Especial atenção a:

``` text
Status Publication Success
Snapshot Creation Integrity
Cross-tenant Denials/Anomalies
Audit Write Failures
```

------------------------------------------------------------------------

# 55. Health checks

Health deve distinguir dependências.

Exemplo:

``` text
Application healthy
Database healthy
AI degraded
SMTP degraded
```

Não marcar todo produto indisponível porque IA está fora.

------------------------------------------------------------------------

# 56. Dependency criticality

Classificação conceitual:

## Critical

-   application runtime;
-   database;
-   authentication essencial.

## Important

-   Storage para funções documentais;
-   background processing para jobs.

## Degradable

-   AI;
-   SMTP;
-   external connectors.

O impacto exato depende do use case.

------------------------------------------------------------------------

# 57. Graceful degradation

Exemplos:

``` text
AI down
→ core PMO works

SMTP down
→ operation succeeds, notification retries

Jira down
→ local state remains, sync marked degraded
```

------------------------------------------------------------------------

# 58. Alerting

Alertas devem priorizar impacto.

Exemplos:

-   Production unavailable;
-   database failures;
-   publication failures;
-   cross-tenant anomaly;
-   persistent job failures;
-   credential expiration;
-   backup failure.

------------------------------------------------------------------------

# 59. Alert fatigue

Não alertar equipe por todo erro isolado.

Usar thresholds/contexto conforme maturidade.

------------------------------------------------------------------------

# 60. Release identification

Cada deployment deve permitir identificar:

-   commit;
-   build;
-   release/version;
-   deployment time.

Isso facilita troubleshooting.

------------------------------------------------------------------------

# 61. Rollback

Aplicação deve permitir rollback para release anterior quando seguro.

Rollback de código não garante rollback de schema.

------------------------------------------------------------------------

# 62. Database rollback

Evitar depender de downgrade destrutivo de migration.

Preferir forward fix quando schema já foi utilizado em Production.

------------------------------------------------------------------------

# 63. Release strategy

MVP pode usar rollout simples.

Evoluções futuras:

-   staged rollout;
-   canary;
-   feature flags;
-   Tenant pilot.

Não introduzir complexidade antes de necessidade.

------------------------------------------------------------------------

# 64. Zero-downtime aspirations

Mudanças devem minimizar downtime.

Especialmente migrations precisam evitar locks longos e
incompatibilidade.

Targets formais serão definidos posteriormente.

------------------------------------------------------------------------

# 65. Backups

Backups devem cobrir:

-   PostgreSQL;
-   documentos críticos;
-   configurações necessárias.

Capacidades específicas do provider devem ser validadas no momento da
implantação.

------------------------------------------------------------------------

# 66. Backup is not recovery

Um backup só é útil quando:

``` text
Restore has been validated.
```

------------------------------------------------------------------------

# 67. Recovery strategy

Fluxo:

``` text
Incident
  ↓
Assess
  ↓
Contain
  ↓
Select Recovery Point
  ↓
Restore
  ↓
Validate Integrity
  ↓
Resume
  ↓
Post-Incident Review
```

------------------------------------------------------------------------

# 68. RPO e RTO

Valores não devem ser inventados.

Serão definidos com base em:

-   SLA;
-   criticidade;
-   plano comercial;
-   custo;
-   expectativas dos clientes.

------------------------------------------------------------------------

# 69. Disaster recovery

No MVP, utilizar prioritariamente capacidades gerenciadas dos providers.

Arquitetura multi-region sofisticada só entra com requisito real.

------------------------------------------------------------------------

# 70. Storage recovery

Documentos precisam de estratégia coerente com:

-   retention;
-   deletion;
-   provider backup capabilities;
-   metadata consistency.

------------------------------------------------------------------------

# 71. Snapshot recovery

Published Snapshots são dados críticos.

Recovery deve preservar:

-   sequência;
-   publicação;
-   Audit relation;
-   integridade histórica.

------------------------------------------------------------------------

# 72. Audit recovery

Audit é crítico para governança.

Procedimentos de restore não devem criar história inconsistente sem
registro operacional.

------------------------------------------------------------------------

# 73. Security operational access

Acesso Production deve seguir least privilege.

Evitar credenciais compartilhadas.

------------------------------------------------------------------------

# 74. Production database access

Acesso humano direto deve ser excepcional.

Mudanças normais acontecem via:

-   application;
-   migration;
-   controlled admin tooling.

------------------------------------------------------------------------

# 75. Break-glass access

Futuro acesso emergencial pode utilizar processo:

``` text
Explicit Request
   ↓
Temporary Privilege
   ↓
Reason
   ↓
Audit
   ↓
Revocation
```

------------------------------------------------------------------------

# 76. Platform Admin deployment boundary

Platform Admin não deve possuir acesso automático ao banco de todos os
clientes apenas por interface.

Operações de plataforma precisam de APIs/policies controladas.

------------------------------------------------------------------------

# 77. Data residency

No início, região de deployment deve ser escolhida conscientemente.

Evolução enterprise pode exigir:

-   regional deployments;
-   contractual residency;
-   provider-specific region choices.

------------------------------------------------------------------------

# 78. Timezone

Persistir timestamps de forma consistente, preferencialmente
UTC/timezone-aware.

UI converte para timezone apropriado.

------------------------------------------------------------------------

# 79. Clock dependency

Operações como:

-   deadlines;
-   publication time;
-   Audit;
-   scheduled jobs;

dependem de relógio confiável.

------------------------------------------------------------------------

# 80. Performance

Monitorar antes de escalar infraestrutura.

Ordem preferencial:

``` text
Measure
 ↓
Optimize Query
 ↓
Index
 ↓
Reduce Payload
 ↓
Background Work
 ↓
Cache
 ↓
Scale
```

------------------------------------------------------------------------

# 81. Database performance

Monitorar:

-   slow queries;
-   locks;
-   connection pressure;
-   index usage;
-   query volume.

------------------------------------------------------------------------

# 82. Serverless considerations

Evitar assumir processo permanente em memória.

Estado durável pertence a:

-   database;
-   Storage;
-   workflow system.

------------------------------------------------------------------------

# 83. Long-running work

Não manter requests HTTP abertos para workloads extensos quando
background job for apropriado.

Exemplos:

-   large import;
-   report generation;
-   integration reconciliation;
-   long AI processing.

------------------------------------------------------------------------

# 84. Caching

Não há Redis no MVP.

Usar capacidades nativas/HTTP/framework quando adequadas e seguras.

Adicionar cache distribuído apenas com necessidade medida.

------------------------------------------------------------------------

# 85. Search infrastructure

PostgreSQL inicialmente.

Adicionar Elasticsearch/OpenSearch somente com requisitos comprovados.

------------------------------------------------------------------------

# 86. Messaging infrastructure

Inngest atende workflows/eventos assíncronos iniciais.

Kafka/RabbitMQ entram apenas se padrões de volume, ordering ou
integração justificarem.

------------------------------------------------------------------------

# 87. Scalability

O sistema deve crescer inicialmente usando:

-   managed services;
-   efficient queries;
-   indexes;
-   stateless application runtime;
-   async jobs;
-   provider scaling.

------------------------------------------------------------------------

# 88. Service extraction

Se futuramente um módulo exigir escala independente, poderá ser
extraído.

Critérios:

-   stable boundary;
-   independent load;
-   operational need;
-   team ownership;
-   measurable benefit.

------------------------------------------------------------------------

# 89. Cost management

Monitorar custos por:

-   Vercel;
-   Supabase;
-   Inngest;
-   Storage;
-   e-mail;
-   AI;
-   integrations.

------------------------------------------------------------------------

# 90. Tenant cost attribution

Quando possível, registrar consumo tenant-aware para:

-   AI;
-   Storage;
-   heavy jobs;
-   future integrations.

Útil para planos comerciais e capacity planning.

------------------------------------------------------------------------

# 91. AI cost

BYOK reduz exposição direta, mas ainda medir:

-   requests;
-   tokens;
-   latency;
-   errors.

------------------------------------------------------------------------

# 92. Capacity planning

Não estimar infraestrutura apenas por número de usuários.

Considerar:

-   Projects;
-   records;
-   Status publications;
-   documents;
-   jobs;
-   reports;
-   AI requests;
-   integration volume.

------------------------------------------------------------------------

# 93. Deployment security

Pipeline deve impedir:

-   secret leakage;
-   unauthorized deploy;
-   unreviewed production changes quando políticas exigirem;
-   accidental environment crossover.

------------------------------------------------------------------------

# 94. Dependency security

CI deve considerar:

-   dependency vulnerabilities;
-   lockfile integrity;
-   outdated critical packages;
-   malicious package risk.

------------------------------------------------------------------------

# 95. Build provenance

Conforme maturidade, registrar origem do build e artefatos.

Pode evoluir para controles de supply chain mais rigorosos.

------------------------------------------------------------------------

# 96. Preview security

Preview URLs podem conter funcionalidades sensíveis.

Não assumir que URL difícil de adivinhar é autenticação.

------------------------------------------------------------------------

# 97. Demo environments

Dados devem ser sintéticos.

Nunca usar dados reais de clientes sem autorização e proteção
apropriada.

------------------------------------------------------------------------

# 98. Testing in pipeline

Camadas:

``` text
Unit
Domain
Integration
Database
Authorization
Tenant Isolation
API
E2E
```

------------------------------------------------------------------------

# 99. Deployment gate

Antes de Production, verificar no mínimo:

-   build;
-   migrations;
-   tests;
-   security-critical tests;
-   configuration;
-   environment readiness.

------------------------------------------------------------------------

# 100. Smoke tests

Após deployment:

-   login;
-   authorized navigation;
-   Project read;
-   critical API;
-   Status workflow core;
-   database connectivity.

------------------------------------------------------------------------

# 101. Publication smoke/integration test

Deve existir teste confiável do fluxo:

``` text
Draft
 ↓
Publish
 ↓
Snapshot
 ↓
Audit
 ↓
Dashboard/History visibility
```

------------------------------------------------------------------------

# 102. Tenant isolation deployment gate

Cross-tenant test deve fazer parte dos controles críticos.

Meta:

``` text
100% pass
```

------------------------------------------------------------------------

# 103. Roll-forward

Quando migration já foi aplicada e rollback é arriscado:

``` text
Fix Forward
```

pode ser estratégia preferida.

------------------------------------------------------------------------

# 104. Maintenance

Manutenção planejada deve ser comunicável e, quando possível, minimizar
indisponibilidade.

------------------------------------------------------------------------

# 105. Status page

Não é requisito obrigatório do primeiro MVP, mas pode ser adotada
conforme maturidade comercial.

------------------------------------------------------------------------

# 106. Operational runbooks

A pasta `/docs/12-devops/` deverá conter runbooks para:

-   deployment;
-   migration;
-   rollback;
-   backup;
-   restore;
-   incident;
-   secret rotation;
-   failed jobs.

------------------------------------------------------------------------

# 107. Incident response

Arquitetura precisa permitir:

``` text
Detect
Identify Release
Trace Request
Inspect Logs
Assess Tenant Impact
Contain
Recover
Verify
```

------------------------------------------------------------------------

# 108. Tenant impact analysis

Logs/correlation devem permitir determinar quais Tenants foram afetados
sem expor dados indevidamente.

------------------------------------------------------------------------

# 109. Observability retention

Logs e metrics terão retention apropriada ao custo e necessidade.

Não armazenar indefinidamente sem motivo.

------------------------------------------------------------------------

# 110. Audit retention

Audit possui política diferente de technical logs.

Não misturar ciclos de retenção.

------------------------------------------------------------------------

# 111. Configuration drift

Configuração de Production deve ser rastreável.

Mudanças manuais críticas devem ser minimizadas e auditadas quando
possível.

------------------------------------------------------------------------

# 112. Infrastructure as Code

No MVP, adotar IaC onde trouxer valor e for suportado pela stack.

Não criar camada complexa apenas por formalidade.

Com crescimento, IaC deve aumentar reprodutibilidade.

------------------------------------------------------------------------

# 113. Provider lock-in

Serviços gerenciados são aceitos quando aceleram o MVP.

Mitigar lock-in onde importa:

-   domínio independente;
-   adapters;
-   migrations;
-   exportabilidade de dados;
-   provider abstractions.

------------------------------------------------------------------------

# 114. Portability

Não é objetivo tornar cada componente substituível em horas.

Objetivo é evitar acoplamento desnecessário do domínio.

------------------------------------------------------------------------

# 115. Deployment evolution

Possível evolução:

``` text
MVP Managed Stack
      ↓
Measured Bottlenecks
      ↓
Targeted Optimization
      ↓
Specialized Services
      ↓
Distributed Architecture only when justified
```

------------------------------------------------------------------------

# 116. Triggers para reavaliar Vercel/Supabase

Somente com evidências como:

-   hard platform limit;
-   compliance;
-   regional requirement;
-   cost curve;
-   workload incompatibility;
-   operational control requirement.

------------------------------------------------------------------------

# 117. Não gatilhos

Não migrar porque:

-   "empresa grande usa Kubernetes";
-   "microservices são mais profissionais";
-   "Kafka é padrão enterprise";
-   "tal banco está em alta".

------------------------------------------------------------------------

# 118. Architecture decisions candidatas a ADR

1.  Vercel deployment;
2.  Supabase platform;
3.  environment strategy;
4.  database migration strategy;
5.  Inngest workflows;
6.  secret management;
7.  observability stack;
8.  backup/recovery strategy;
9.  future IaC strategy.

------------------------------------------------------------------------

# 119. Deployment invariants

1.  Production secrets nunca chegam ao browser.
2.  Ambientes possuem configuração isolada.
3.  Schema changes são versionadas.
4.  Deploy é rastreável a código/release.
5.  Core não depende da disponibilidade da IA.
6.  E-mail não participa da transação de negócio.
7.  Jobs com side effects são idempotentes.
8.  Falhas de integração são recuperáveis.
9.  Published Snapshot é dado crítico.
10. Audit é dado crítico.
11. Production access segue least privilege.
12. Backups precisam de estratégia de restore.
13. Cross-tenant tests são deployment-critical.
14. Complexidade de infraestrutura exige evidência.
15. Managed services são preferidos no MVP.
16. Rollback de código não pressupõe rollback de banco.
17. Tenant-specific secrets não ficam em `.env` global.
18. Observabilidade faz parte da arquitetura, não é pós-MVP.

------------------------------------------------------------------------

# 120. Relação com `/docs/12-devops/`

Este documento define arquitetura.

A pasta:

``` text
/docs/12-devops/
```

deverá detalhar:

-   CI/CD;
-   environments;
-   Vercel;
-   Supabase;
-   migrations;
-   Inngest;
-   observability;
-   backup;
-   restore;
-   rollback;
-   incident runbooks;
-   secrets;
-   release process.

------------------------------------------------------------------------

# 121. Relação com outras camadas

Deployment Architecture implementa decisões de:

``` text
System Architecture
Data Architecture
Security Architecture
AI Architecture
Integration Architecture
```

sem alterar suas regras.

------------------------------------------------------------------------

# 122. Critério de conclusão arquitetural

A arquitetura de deployment é adequada ao MVP quando:

-   aplicação pode ser implantada de forma repetível;
-   ambientes estão separados;
-   secrets estão protegidos;
-   migrations são controladas;
-   jobs são observáveis;
-   falhas externas degradam graciosamente;
-   Production é monitorável;
-   dados críticos possuem estratégia de recuperação;
-   deployment não introduz infraestrutura desnecessária.

------------------------------------------------------------------------

# 123. Referências

-   `/docs/02-architecture/README.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/02-architecture/ai-architecture.md`
-   `/docs/02-architecture/integration-architecture.md`
-   `/docs/01-product/mvp-scope.md`
-   `/docs/12-devops/`

------------------------------------------------------------------------

# 124. Status

**Documento:** Deployment Architecture\
**Status:** Approved\
**Responsabilidade:** definir a topologia de deployment, ambientes,
CI/CD, runtime, configuração, secrets, migrations, observabilidade,
resiliência e recuperação do PMO Control.
