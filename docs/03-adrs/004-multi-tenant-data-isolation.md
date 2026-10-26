# ADR-004 --- Multi-Tenant Data Isolation

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Adotar banco relacional compartilhado com isolamento
lógico forte por Tenant, utilizando ownership explícito, `tenant_id`,
autorização server-side, queries tenant-scoped, constraints, RLS quando
apropriado e testes automatizados de isolamento.

------------------------------------------------------------------------

## 1. Context

O PMO Control é um SaaS multi-tenant.

Uma mesma plataforma atenderá diferentes organizações, cada uma
contendo:

-   usuários;
-   Memberships;
-   Portfolios;
-   Projects;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Financial data;
-   Documents;
-   Status;
-   Snapshots;
-   integrações;
-   configurações;
-   AI/BYOK.

O isolamento entre clientes é uma propriedade de segurança crítica.

------------------------------------------------------------------------

## 2. Problem

É necessário decidir como armazenar dados de múltiplos Tenants
garantindo:

``` text
Tenant A data
≠
Tenant B data
```

sem introduzir complexidade operacional desnecessária no MVP.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   segurança;
-   simplicidade operacional;
-   custo;
-   escalabilidade inicial;
-   facilidade de migrations;
-   relatórios internos;
-   observabilidade;
-   desenvolvimento;
-   backup/recovery;
-   capacidade de testar isolamento;
-   evolução futura.

------------------------------------------------------------------------

## 4. Decision

Adotar inicialmente:

``` text
Shared PostgreSQL
+
Shared Schema
+
Explicit Tenant Ownership
+
tenant_id on tenant-owned data
+
Application Authorization
+
Tenant-scoped Queries
+
Database Constraints
+
RLS where appropriate
+
Automated Isolation Tests
```

------------------------------------------------------------------------

## 5. Tenant as Security Boundary

Tenant não é apenas filtro funcional.

É uma fronteira de segurança.

Toda operação tenant-scoped deve resolver e validar o Tenant antes de
acessar recursos.

------------------------------------------------------------------------

## 6. Explicit Ownership

Entidades relevantes devem possuir ownership explícito.

Exemplo:

``` text
Project
tenant_id = Tenant A
```

Mesmo quando Tenant pode ser inferido por relações, `tenant_id`
explícito poderá ser mantido em entidades estratégicas para:

-   segurança;
-   queries;
-   constraints;
-   performance;
-   observabilidade.

A modelagem física final será definida em `/docs/06-data/`.

------------------------------------------------------------------------

## 7. Tenant Context

O contexto não deve confiar apenas em:

``` text
tenant_id
```

enviado pelo browser.

Fluxo:

``` text
Authenticated User
      ↓
Membership
      ↓
Authorized Tenant Context
      ↓
Scoped Operation
```

------------------------------------------------------------------------

## 8. Query Rule

Queries tenant-owned devem ser tenant-scoped.

Conceitualmente:

``` text
WHERE tenant_id = authorized_tenant_id
```

além das demais regras de autorização.

------------------------------------------------------------------------

## 9. Defense in Depth

Nenhuma camada isolada é considerada suficiente.

``` text
Application Authorization
        +
Tenant-scoped Queries
        +
Database Constraints
        +
RLS
        +
Automated Tests
```

------------------------------------------------------------------------

## 10. Cross-Tenant Access

Tentativa de acessar recurso de outro Tenant deve resultar em:

``` text
DENIED
```

sem revelar desnecessariamente a existência do recurso.

------------------------------------------------------------------------

## 11. IDOR / BOLA

IDs não concedem acesso.

``` text
/project/{uuid}
```

não pode ser buscado apenas pelo UUID.

É necessário validar Tenant, Scope e Permission.

------------------------------------------------------------------------

## 12. Foreign Keys

Quando apropriado, constraints devem ajudar a impedir relações
inconsistentes entre Tenants.

Exemplo conceitual:

``` text
Project(Tenant A)
cannot reference
Portfolio(Tenant B)
```

A implementação física pode usar chaves compostas, constraints ou outra
estratégia segura.

------------------------------------------------------------------------

## 13. Unique Constraints

Unicidade deve considerar Tenant quando o conceito for tenant-local.

Exemplo:

``` text
UNIQUE (tenant_id, project_code)
```

quando `project_code` só precisa ser único dentro da organização.

------------------------------------------------------------------------

## 14. Global Entities

Nem toda entidade pertence diretamente a um Tenant.

Exemplos possíveis:

-   platform-level plans;
-   global provider catalog;
-   system metadata.

Essas entidades precisam de classificação explícita como platform-owned.

------------------------------------------------------------------------

## 15. User Identity

User global e Tenant Membership são conceitos diferentes.

``` text
User
  ↓
Membership Tenant A
  ↓
Membership Tenant B
```

O mesmo usuário pode participar de múltiplos Tenants.

------------------------------------------------------------------------

## 16. Membership

Membership estabelece relação do usuário com Tenant.

Role/Scope/Permissions são avaliados sobre essa relação e seus grants.

------------------------------------------------------------------------

## 17. Same User, Different Access

Exemplo:

``` text
User Paulo
├── Tenant A → PMO Admin
└── Tenant B → Viewer
```

A sessão do usuário não implica Role global de negócio.

------------------------------------------------------------------------

## 18. Platform Admin

Platform Admin não possui acesso automático aos dados de negócio dos
Tenants.

Acesso excepcional deve ser:

-   explícito;
-   autorizado;
-   temporário quando possível;
-   justificado;
-   auditado.

------------------------------------------------------------------------

## 19. Option A --- Shared Database + Shared Schema

### Vantagens

-   simplicidade;
-   custo;
-   migrations centralizadas;
-   operações mais simples;
-   boa utilização de recursos;
-   adequada ao MVP.

### Desvantagens

-   erro de query pode causar risco cross-tenant;
-   exige disciplina rigorosa;
-   RLS/constraints/tests tornam-se críticos.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 20. Option B --- Schema per Tenant

### Vantagens

-   separação lógica adicional.

### Desvantagens

-   migrations multiplicadas;
-   schema proliferation;
-   operação mais complexa;
-   tooling mais difícil;
-   pouco benefício para o estágio inicial.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 21. Option C --- Database per Tenant

### Vantagens

-   isolamento físico superior;
-   backup/restore individual mais direto em alguns cenários;
-   compliance específico.

### Desvantagens

-   provisioning;
-   migrations em massa;
-   connection management;
-   custo;
-   observabilidade;
-   operação;
-   maior complexidade.

### Resultado

**Rejected as default MVP model.**

------------------------------------------------------------------------

## 22. Enterprise Isolation Future

Database-per-Tenant ou deployment dedicado pode ser reavaliado para:

-   compliance;
-   contractual isolation;
-   data residency;
-   very large Tenant;
-   premium enterprise requirement.

Não será default sem necessidade.

------------------------------------------------------------------------

## 23. Consequences --- Positive

-   operação simples;
-   custo eficiente;
-   migrations únicas;
-   analytics operacionais mais fáceis;
-   desenvolvimento mais rápido;
-   compatível com PostgreSQL/Supabase;
-   escala inicial adequada.

------------------------------------------------------------------------

## 24. Consequences --- Negative

-   maior impacto potencial de bug de autorização;
-   necessidade de testes rigorosos;
-   risco de query sem filtro;
-   restore individual por Tenant pode ser mais complexo;
-   políticas RLS exigem cuidado.

------------------------------------------------------------------------

## 25. Mitigations

-   authorization centralizado;
-   tenant-aware repositories/query helpers;
-   RLS;
-   constraints;
-   code review;
-   negative tests;
-   automated cross-tenant suite;
-   observability;
-   secure administrative access.

------------------------------------------------------------------------

## 26. Authorization Relationship

Tenant isolation responde:

> "De qual organização é este dado?"

Authorization responde:

> "Este ator pode executar esta ação sobre este dado?"

As duas verificações são necessárias.

------------------------------------------------------------------------

## 27. Data Policy

Mesmo dentro do Tenant, nem todo dado é visível para todos.

Exemplo:

``` text
Tenant Access
+
Project Access
+
financial.view
```

pode ser necessário para orçamento.

------------------------------------------------------------------------

## 28. Workflow Rule

Mesmo ator autorizado ao Project pode ser impedido de alterar um recurso
por seu estado.

Exemplo:

``` text
Published Snapshot
→ immutable
```

------------------------------------------------------------------------

## 29. RLS Relationship

RLS será detalhada no ADR-005.

Neste ADR, RLS é definida como uma camada de defesa adicional, não como
única solução de isolamento.

------------------------------------------------------------------------

## 30. Storage Isolation

Arquivos também são tenant-scoped.

Metadata e policies devem impedir que Tenant A obtenha arquivo de Tenant
B.

------------------------------------------------------------------------

## 31. Signed URLs

Uma signed URL só pode ser gerada após autorização.

A URL não é o mecanismo primário de autorização de negócio.

------------------------------------------------------------------------

## 32. Background Jobs

Todo job tenant-scoped deve carregar/resolver contexto explícito.

``` text
job
tenant_id
resource_id
```

não significa autorização irrestrita.

------------------------------------------------------------------------

## 33. Internal Services

Serviços internos não devem receber bypass universal apenas porque são
"internos".

Least privilege continua válido.

------------------------------------------------------------------------

## 34. Integrations

Cada integração pertence a um Tenant.

``` text
Integration Credential A
→ Tenant A only
```

Mapping e sync precisam preservar essa fronteira.

------------------------------------------------------------------------

## 35. AI

Regra:

``` text
AI Context
≤
Authorized Tenant Context
```

Nenhum retrieval pode misturar dados de Tenants.

------------------------------------------------------------------------

## 36. Vector / Semantic Data

Se embeddings forem introduzidos:

-   tenant_id;
-   source;
-   classification;
-   Scope;

devem participar do modelo de isolamento.

------------------------------------------------------------------------

## 37. Cache

Qualquer cache futuro precisa incluir Tenant na chave quando contiver
dados tenant-specific.

Nunca reutilizar resposta entre Tenants por chave incompleta.

------------------------------------------------------------------------

## 38. Reports and Exports

Export deve respeitar:

``` text
Tenant
+
Scope
+
Permission
+
Data Policy
```

e pode gerar Audit Event.

------------------------------------------------------------------------

## 39. Audit

Audit Events devem registrar Tenant para operações tenant-scoped.

Isso permite investigação e rastreabilidade.

------------------------------------------------------------------------

## 40. Logs

Logs podem incluir `tenant_id` como metadata segura quando apropriado,
sem incluir conteúdo sensível desnecessário.

------------------------------------------------------------------------

## 41. Cross-Tenant Testing

Teste obrigatório:

``` text
Actor from Tenant A
attempts Tenant B resource
→ DENIED
```

------------------------------------------------------------------------

## 42. Required Isolation Test Categories

Cobrir pelo menos:

-   Projects;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Financial;
-   Resources;
-   Documents;
-   Snapshots;
-   Reports;
-   Exports;
-   AI;
-   integrations;
-   jobs.

------------------------------------------------------------------------

## 43. CRUD Negative Tests

Para entidades relevantes:

``` text
READ denied
CREATE relation denied
UPDATE denied
DELETE denied
```

quando recurso/parent pertence a outro Tenant.

------------------------------------------------------------------------

## 44. Enumeration Resistance

Respostas não devem permitir facilmente enumerar recursos de outros
Tenants.

Quando apropriado:

``` text
Not Found / Access Denied
```

sem metadata adicional.

------------------------------------------------------------------------

## 45. Database Constraints Testing

Testes devem tentar criar relações cross-tenant inválidas e confirmar
rejeição quando a modelagem permitir enforcement no banco.

------------------------------------------------------------------------

## 46. Migration Safety

Migrations devem preservar `tenant_id`, constraints e policies.

Mudança de schema não pode remover silenciosamente isolamento.

------------------------------------------------------------------------

## 47. Backfill Safety

Backfills precisam ser tenant-safe.

Nunca executar update amplo sem condição correta por conveniência.

------------------------------------------------------------------------

## 48. Import Safety

Import deve resolver Tenant no contexto autorizado.

Linhas do arquivo não podem escolher arbitrariamente outro Tenant.

------------------------------------------------------------------------

## 49. Public API Future

Tokens/API clients futuros devem possuir Tenant e Scope explícitos.

------------------------------------------------------------------------

## 50. Support Access

Fluxo futuro recomendado:

``` text
Support Request
      ↓
Explicit Tenant Authorization
      ↓
Temporary Scoped Access
      ↓
Audit
      ↓
Revocation
```

------------------------------------------------------------------------

## 51. Backup and Restore

Shared database torna restore por Tenant mais complexo.

Procedimentos futuros devem considerar:

-   full restore;
-   point-in-time recovery;
-   selective logical recovery;
-   integrity validation.

------------------------------------------------------------------------

## 52. Tenant Deletion

Exclusão de Tenant será operação altamente sensível.

Deve considerar:

-   retention;
-   legal requirements;
-   documents;
-   Audit;
-   backups;
-   asynchronous cleanup.

Não deve ser simples cascade irreversível sem processo governado.

------------------------------------------------------------------------

## 53. Tenant Archival

Arquivamento pode ser preferível a exclusão imediata.

Política será detalhada posteriormente.

------------------------------------------------------------------------

## 54. Performance

`tenant_id` participará frequentemente de:

-   filters;
-   indexes;
-   composite indexes;
-   unique constraints.

O desenho físico será otimizado conforme query patterns.

------------------------------------------------------------------------

## 55. Indexing

Exemplo conceitual:

``` text
(tenant_id, project_id, status)
(tenant_id, owner_id, due_date)
```

Índices reais serão definidos em `/docs/06-data/`.

------------------------------------------------------------------------

## 56. Observability

Monitorar:

-   authorization denials;
-   unusual cross-tenant attempts;
-   RLS denials;
-   admin/support access;
-   tenant-specific failure patterns.

------------------------------------------------------------------------

## 57. Security Incident

Qualquer confirmação de vazamento cross-tenant deve ser tratada como
incidente de alta severidade.

------------------------------------------------------------------------

## 58. Deployment Gate

Suite de isolamento deve ser tratada como gate crítico de release.

Objetivo:

``` text
Cross-Tenant Isolation Tests = 100% PASS
```

------------------------------------------------------------------------

## 59. Revisit Triggers

Reavaliar shared-schema se:

1.  cliente exigir isolamento físico;
2.  compliance/regulação exigir;
3.  data residency variar por Tenant;
4.  restore individual tornar-se requisito crítico;
5.  large Tenant causar noisy-neighbor relevante;
6.  SLA exigir isolamento operacional;
7.  economics justificarem deployment dedicado.

------------------------------------------------------------------------

## 60. Non-Triggers

Não migrar para database-per-Tenant apenas por:

-   crescimento do número de tabelas;
-   percepção de que é "mais enterprise";
-   preferência técnica sem requisito;
-   medo abstrato sem evidência.

------------------------------------------------------------------------

## 61. Migration Path

Se Tenant dedicado for necessário:

``` text
Identify Tenant
      ↓
Provision Dedicated Data Plane
      ↓
Export Tenant-scoped Data
      ↓
Validate Referential Integrity
      ↓
Migrate Storage/Secrets
      ↓
Switch Routing
      ↓
Validate
```

A presença consistente de `tenant_id` facilita essa evolução.

------------------------------------------------------------------------

## 62. Architecture Fitness

A decisão permanece saudável se:

-   nenhuma query tenant-owned opera sem contexto;
-   cross-tenant tests permanecem verdes;
-   RLS/constraints reforçam isolamento;
-   incidentes de leakage permanecem zero;
-   operação continua simples;
-   performance permanece adequada.

------------------------------------------------------------------------

## 63. Relationship with ADR-003

ADR-003 escolhe Supabase/PostgreSQL.

ADR-004 define o modelo de isolamento dos dados nessa plataforma.

------------------------------------------------------------------------

## 64. Relationship with ADR-005

ADR-005 detalha o papel de RLS dentro da estratégia defense-in-depth.

------------------------------------------------------------------------

## 65. Relationship with ADR-006

ADR-006 define autorização além da fronteira Tenant.

``` text
Tenant Isolation
≠
Complete Authorization
```

------------------------------------------------------------------------

## 66. References

-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/03-adrs/003-supabase-postgresql.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 67. Decision Summary

``` text
Decision:
Use a shared PostgreSQL/shared-schema multi-tenant model
with explicit tenant ownership and defense in depth.

Controls:
Application Authorization
+ Tenant-scoped Queries
+ Constraints
+ RLS
+ Automated Isolation Tests

Why:
It provides the best MVP balance of security,
operational simplicity, cost and evolvability.

Revisit:
When compliance, residency, SLA, scale or contractual
requirements justify stronger physical isolation.
```

------------------------------------------------------------------------

**ADR:** ADR-004\
**Status:** Accepted
