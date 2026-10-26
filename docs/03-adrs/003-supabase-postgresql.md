# ADR-003 --- Supabase + PostgreSQL

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Adotar Supabase, com PostgreSQL, Auth e Storage, como
plataforma de dados inicial do PMO Control.

------------------------------------------------------------------------

## 1. Context

O PMO Control é um SaaS multi-tenant de governança de projetos com forte
necessidade de:

-   integridade relacional;
-   transações;
-   isolamento entre Tenants;
-   autorização;
-   histórico;
-   Snapshots imutáveis;
-   Audit;
-   documentos e Evidence;
-   consultas operacionais;
-   dashboards;
-   relatórios;
-   evolução futura para busca semântica.

O MVP deve reduzir complexidade operacional sem sacrificar consistência,
segurança e capacidade de evolução.

------------------------------------------------------------------------

## 2. Problem

É necessário escolher a plataforma principal para:

``` text
Transactional Database
Authentication
Object Storage
```

e estabelecer qual tecnologia será a fonte transacional primária.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   modelo relacional;
-   ACID transactions;
-   constraints;
-   indexes;
-   SQL;
-   Row Level Security;
-   maturidade do PostgreSQL;
-   managed infrastructure;
-   Auth integrado;
-   Storage integrado;
-   baixo overhead operacional;
-   compatibilidade com Next.js;
-   possibilidade de evolução;
-   portabilidade razoável dos dados.

------------------------------------------------------------------------

## 4. Decision

Adotar no MVP:

``` text
Supabase
├── PostgreSQL
├── Auth
└── Storage
```

O PostgreSQL será a principal fonte transacional do PMO Control.

------------------------------------------------------------------------

## 5. PostgreSQL Role

PostgreSQL armazenará, entre outros:

-   Tenants;
-   Memberships;
-   Portfolios;
-   Projects;
-   Milestones;
-   Deliverables;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Dependencies;
-   Status;
-   Snapshots;
-   Financial records;
-   Resource allocations;
-   document metadata;
-   Audit;
-   integration metadata;
-   AI configuration metadata.

------------------------------------------------------------------------

## 6. Relational Model

O domínio possui relações e invariantes que favorecem banco relacional.

Exemplo:

``` text
Tenant
  ↓
Portfolio
  ↓
Project
  ├── Milestones
  ├── Deliverables
  ├── Risks
  ├── Issues
  ├── Actions
  └── Decisions
```

------------------------------------------------------------------------

## 7. Transactional Integrity

Casos como publicação de Status exigem consistência.

``` text
Validate
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

PostgreSQL é adequado para esse boundary.

------------------------------------------------------------------------

## 8. Supabase Auth

Supabase Auth será utilizado inicialmente para identidade e sessões.

Ele responde principalmente:

``` text
Who is the user?
```

Não substitui o modelo de autorização de negócio.

------------------------------------------------------------------------

## 9. Authentication ≠ Authorization

Após autenticação:

``` text
User
 ↓
Membership
 ↓
Role
 ↓
Scope
 ↓
Permission
 ↓
Data Policy
 ↓
Workflow Rule
```

O authorization model permanece responsabilidade do PMO Control.

------------------------------------------------------------------------

## 10. Supabase Storage

Storage será usado para objetos como:

-   documentos;
-   anexos;
-   Evidence files;
-   report artifacts quando necessário.

Metadata de negócio permanece no PostgreSQL.

------------------------------------------------------------------------

## 11. Binary vs Metadata

``` text
PostgreSQL
→ metadata, ownership, classification, relations

Storage
→ binary object
```

Essa separação permite governança e consultas sem depender do conteúdo
binário.

------------------------------------------------------------------------

## 12. Public Buckets

Documentos de negócio não devem ser públicos por conveniência.

Downloads precisam respeitar autorização.

Signed URLs podem ser utilizadas quando apropriado.

------------------------------------------------------------------------

## 13. Multi-Tenancy

A plataforma utilizará banco compartilhado com isolamento lógico forte.

``` text
Shared PostgreSQL
+
Explicit Tenant Ownership
+
Application Authorization
+
Tenant-scoped Queries
+
Constraints
+
RLS where appropriate
+
Isolation Tests
```

Detalhado nos ADR-004 e ADR-005.

------------------------------------------------------------------------

## 14. Row Level Security

PostgreSQL/Supabase oferece RLS, que será usada como defesa adicional
onde apropriado.

RLS não substitui:

-   application authorization;
-   permissions;
-   workflow rules;
-   data policies.

------------------------------------------------------------------------

## 15. Database as Source of Truth

PostgreSQL é fonte de verdade para estado transacional interno.

Dashboards, relatórios e AI context são derivados.

``` text
Operational Data
      ↓
Derived Views / Queries / Context
```

------------------------------------------------------------------------

## 16. Current vs Historical State

O banco armazenará tanto:

``` text
Current Operational State
```

quanto:

``` text
Published Historical Snapshots
```

sem confundir os dois conceitos.

------------------------------------------------------------------------

## 17. JSONB

JSONB pode ser utilizado quando adequado, por exemplo:

-   Snapshot payload;
-   provider metadata;
-   flexible configuration;
-   versioned payloads.

Não será usado como desculpa para evitar modelagem relacional de
entidades centrais.

------------------------------------------------------------------------

## 18. Search

Busca inicial deve aproveitar PostgreSQL.

Não adicionar Elasticsearch/OpenSearch sem necessidade comprovada.

------------------------------------------------------------------------

## 19. Semantic Retrieval

Se busca semântica se tornar necessária, `pgvector` é candidato natural
antes de introduzir um vector database separado.

A decisão final depende do use case e será registrada posteriormente se
necessário.

------------------------------------------------------------------------

## 20. Option A --- Supabase + PostgreSQL

### Vantagens

-   PostgreSQL maduro;
-   ACID;
-   SQL;
-   constraints;
-   RLS;
-   managed database;
-   Auth;
-   Storage;
-   integração rápida;
-   menor overhead operacional;
-   boa adequação ao domínio.

### Desvantagens

-   dependência de plataforma gerenciada;
-   limites específicos de plano/provider;
-   necessidade de governar corretamente service-role access;
-   algumas funcionalidades criam acoplamento ao Supabase.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 21. Option B --- Managed PostgreSQL + Separate Auth/Storage

### Vantagens

-   menor acoplamento a plataforma única;
-   componentes escolhidos individualmente.

### Desvantagens

-   mais serviços;
-   mais integração;
-   mais configuração;
-   mais operação;
-   pouco benefício para o MVP.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 22. Option C --- Firebase

### Vantagens

-   experiência gerenciada;
-   rápido início;
-   Auth e Storage.

### Desvantagens

O domínio do PMO Control favorece:

-   relações;
-   transações;
-   consultas estruturadas;
-   constraints;
-   histórico;
-   SQL.

PostgreSQL possui melhor aderência ao modelo.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 23. Option D --- NoSQL as Primary Database

### Problema

Entidades de governança possuem relações fortes e integridade
referencial.

A flexibilidade de schema não compensa a perda de naturalidade
relacional para o core.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 24. Option E --- Multiple Databases from Day One

Exemplo:

``` text
PostgreSQL
+
Redis
+
Elasticsearch
+
Vector DB
```

### Problema

Adiciona sincronização, operação, custos e múltiplas fontes de falha
antes de existir necessidade.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 25. Consequences --- Positive

### 25.1 Simplicidade

Uma plataforma cobre banco, Auth e Storage.

### 25.2 Integridade

PostgreSQL oferece constraints e transactions.

### 25.3 Segurança

RLS pode complementar o authorization model.

### 25.4 Histórico

Boa adequação a Snapshots e Audit.

### 25.5 Evolução

PostgreSQL suporta crescimento considerável antes de exigir novas
tecnologias.

------------------------------------------------------------------------

## 26. Consequences --- Negative

### 26.1 Platform Dependency

Parte da solução depende de capacidades do Supabase.

### 26.2 Operational Limits

Planos/quotas/limites podem exigir evolução futura.

### 26.3 Privileged Credentials

Service-role credentials exigem proteção rigorosa.

### 26.4 RLS Complexity

Policies incorretas podem criar vulnerabilidades ou bloquear acesso
legítimo.

------------------------------------------------------------------------

## 27. Mitigations

-   manter domínio independente do SDK quando razoável;
-   migrations SQL versionadas;
-   adapters/repositories apropriados;
-   exportabilidade dos dados;
-   automated tenant isolation tests;
-   secrets server-side;
-   observabilidade;
-   ADRs para decisões específicas de RLS/isolamento.

------------------------------------------------------------------------

## 28. Security Implications

A plataforma armazenará dados potencialmente sensíveis.

Aplicar:

-   TLS;
-   least privilege;
-   secure secrets;
-   RLS;
-   application authorization;
-   controlled Storage access;
-   Audit;
-   environment isolation.

------------------------------------------------------------------------

## 29. Service Role

Credenciais privilegiadas:

``` text
Server Only
```

Nunca no browser.

Seu uso deve ser limitado e não funcionar como atalho universal para
contornar authorization.

------------------------------------------------------------------------

## 30. Storage Security

Arquivos devem possuir:

-   Tenant ownership;
-   metadata;
-   classification;
-   authorized access;
-   controlled signed URLs quando usadas.

------------------------------------------------------------------------

## 31. Data Classification

As políticas devem respeitar:

``` text
/docs/00-foundation/data-classification.md
```

especialmente para:

-   Financial;
-   confidential documents;
-   personal data;
-   credentials.

------------------------------------------------------------------------

## 32. Backup and Recovery

A solução deve possuir estratégia para:

-   database backups;
-   restore;
-   Storage recovery quando aplicável;
-   validation.

RPO/RTO serão definidos conforme requisitos comerciais e operacionais.

------------------------------------------------------------------------

## 33. Migration Strategy

Schema será alterado por migrations versionadas.

Preferência para mudanças complexas:

``` text
Expand
 ↓
Migrate
 ↓
Verify
 ↓
Contract
```

------------------------------------------------------------------------

## 34. Production Changes

Evitar mudanças manuais de schema em Production fora do processo
controlado.

------------------------------------------------------------------------

## 35. Data Portability

PostgreSQL reduz risco de lock-in estrutural comparado a um modelo de
dados proprietário.

Entretanto, Auth/Storage e APIs específicas do Supabase ainda exigiriam
migração caso o provider fosse substituído.

------------------------------------------------------------------------

## 36. Performance

Antes de adicionar infraestrutura:

``` text
Measure
 ↓
Optimize Query
 ↓
Index
 ↓
Pagination
 ↓
Background Work
 ↓
Materialization/Cache if justified
```

------------------------------------------------------------------------

## 37. Connection Management

A aplicação serverless deve utilizar estratégia de conexão compatível
com os limites do provider.

A configuração concreta será definida no deployment/implementation.

------------------------------------------------------------------------

## 38. Observability

Monitorar:

-   connection pressure;
-   slow queries;
-   errors;
-   locks;
-   storage failures;
-   Auth failures;
-   capacity trends.

------------------------------------------------------------------------

## 39. Testing Implications

Testes críticos:

-   constraints;
-   migrations;
-   tenant isolation;
-   RLS;
-   transaction rollback;
-   Snapshot integrity;
-   Storage authorization;
-   Auth/session integration.

------------------------------------------------------------------------

## 40. Local Development

Desenvolvimento deve possuir ambiente não produtivo próprio.

Production data não deve ser copiada indiscriminadamente.

------------------------------------------------------------------------

## 41. Environment Isolation

``` text
Development
≠
Preview/Test
≠
Production
```

com configuração e credenciais separadas.

------------------------------------------------------------------------

## 42. Revisit Triggers

Reavaliar se:

1.  requisitos regulatórios exigirem outra topologia;
2.  região/residência de dados exigir mudança;
3.  limites da plataforma bloquearem escala;
4.  custo tornar-se inadequado;
5.  disponibilidade/SLA exigir arquitetura diferente;
6.  workload específico exigir banco especializado;
7.  necessidade operacional justificar separação de Auth/Storage/DB.

------------------------------------------------------------------------

## 43. Non-Triggers

Não substituir PostgreSQL/Supabase apenas porque:

-   outro banco está em tendência;
-   NoSQL parece mais escalável;
-   microservices foram introduzidos;
-   existe tecnologia especializada disponível.

------------------------------------------------------------------------

## 44. Migration Path

Se for necessário sair do Supabase:

``` text
Inventory Platform Dependencies
      ↓
Preserve PostgreSQL Schema/Data
      ↓
Replace Auth Boundary
      ↓
Migrate Storage
      ↓
Replace Platform-specific APIs
      ↓
Validate
      ↓
Cut Over
```

A independência do domínio reduz o impacto.

------------------------------------------------------------------------

## 45. Relationship with ADR-004

ADR-003 escolhe a plataforma.

ADR-004 define como os dados multi-tenant serão isolados dentro dessa
arquitetura.

------------------------------------------------------------------------

## 46. Relationship with ADR-005

ADR-005 define especificamente o papel de Row Level Security.

------------------------------------------------------------------------

## 47. Relationship with ADR-007

PostgreSQL será responsável pela persistência transacional dos Snapshots
imutáveis definidos no ADR-007.

------------------------------------------------------------------------

## 48. Relationship with ADR-011

A topologia inicial será:

``` text
Vercel
  ↓
Supabase
```

com Inngest e demais serviços externos conforme arquitetura.

------------------------------------------------------------------------

## 49. References

-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/02-architecture/deployment-architecture.md`
-   `/docs/03-adrs/001-modular-monolith.md`
-   `/docs/03-adrs/002-nextjs-typescript.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 50. Decision Summary

``` text
Decision:
Use Supabase with PostgreSQL, Auth and Storage
as the initial data platform.

Why:
The PMO Control domain benefits strongly from relational
integrity, transactions, SQL and managed infrastructure,
while Supabase reduces MVP operational complexity.

Constraint:
Supabase Auth does not replace business authorization,
and privileged credentials remain server-side.

Revisit:
Only when measurable compliance, scale, cost,
regional or operational requirements justify change.
```

------------------------------------------------------------------------

**ADR:** ADR-003\
**Status:** Accepted
