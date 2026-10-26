# ADR-005 --- Row Level Security (RLS)

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Utilizar PostgreSQL Row Level Security como camada
adicional de defesa para dados tenant-scoped e sensíveis, sem substituir
a autorização server-side da aplicação.

------------------------------------------------------------------------

## 1. Context

O PMO Control adota, conforme ADR-004:

``` text
Shared PostgreSQL
+
Shared Schema
+
Explicit Tenant Ownership
```

Nesse modelo, diferentes organizações compartilham a mesma
infraestrutura de dados.

A segurança não pode depender exclusivamente de cada query da aplicação
lembrar corretamente de aplicar `tenant_id`.

PostgreSQL oferece **Row Level Security (RLS)** para restringir quais
linhas podem ser acessadas ou modificadas conforme políticas executadas
no banco.

------------------------------------------------------------------------

## 2. Problem

É necessário decidir qual papel RLS terá na arquitetura.

As principais alternativas são:

1.  não utilizar RLS;
2.  utilizar RLS como única camada de autorização;
3.  utilizar RLS como defesa adicional em conjunto com autorização da
    aplicação.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   prevenção de vazamento cross-tenant;
-   defense in depth;
-   proteção contra IDOR/BOLA;
-   segurança de acesso direto ao banco via APIs autorizadas;
-   redução do impacto de erro de query;
-   compatibilidade com Supabase/PostgreSQL;
-   testabilidade;
-   clareza de responsabilidade;
-   manutenção.

------------------------------------------------------------------------

## 4. Decision

Adotar:

``` text
Application Authorization
        +
Tenant-scoped Queries
        +
Database Constraints
        +
Row Level Security
        +
Automated Security Tests
```

RLS será uma camada adicional de segurança.

------------------------------------------------------------------------

## 5. RLS Is Not the Authorization Model

Regra central:

``` text
RLS
≠
Complete Business Authorization
```

O modelo de autorização continua sendo:

``` text
Tenant
+
Role
+
Scope
+
Permission
+
Data Policy
+
Workflow Rule
```

RLS reforça parte dessas restrições no nível de dados.

------------------------------------------------------------------------

## 6. Responsibility Split

### Application

Responsável por:

-   autenticar;
-   resolver Tenant;
-   resolver Role/Scope;
-   verificar Permission;
-   aplicar Data Policy;
-   aplicar Workflow Rule;
-   executar use case.

### Database / RLS

Responsável por reforçar:

-   row ownership;
-   Tenant boundary;
-   acesso a determinadas linhas;
-   operações permitidas conforme contexto disponível.

------------------------------------------------------------------------

## 7. Why Not RLS Only

RLS não deve concentrar toda a lógica porque regras como:

``` text
status.update.publish
projects.{projectId}.rag-evaluations.override
baseline.change
decision.approve
```

dependem de contexto de negócio e workflow.

Colocar tudo em policies tornaria regras complexas, difíceis de testar e
excessivamente acopladas ao banco.

------------------------------------------------------------------------

## 8. Tenant Isolation

Para tabelas tenant-scoped, a policy deve impedir acesso a linhas fora
do Tenant autorizado.

Conceitualmente:

``` text
row.tenant_id
=
authorized_tenant_id
```

------------------------------------------------------------------------

## 9. SELECT Policies

Leitura deve considerar Tenant e, quando necessário, outras restrições.

RLS não implica automaticamente que todo usuário do Tenant possa ler
toda linha.

------------------------------------------------------------------------

## 10. INSERT Policies

Insert deve impedir criação de recurso em Tenant arbitrário.

O browser não escolhe livremente `tenant_id`.

------------------------------------------------------------------------

## 11. UPDATE Policies

Update deve garantir que:

-   linha pertence ao contexto autorizado;
-   alteração não transfira ownership indevidamente;
-   demais regras de negócio continuem na aplicação.

------------------------------------------------------------------------

## 12. DELETE Policies

Delete deve ser restritivo.

Recursos governados podem utilizar:

-   archive;
-   domain state;
-   soft delete;

em vez de hard delete.

------------------------------------------------------------------------

## 13. Tenant ID Mutation

Alterar `tenant_id` de recurso existente deve ser proibido na maioria
dos casos.

Mover dado entre Tenants não é update comum.

------------------------------------------------------------------------

## 14. Parent-Child Integrity

RLS não substitui constraints.

Exemplo:

``` text
Deliverable Tenant A
```

não deve conseguir referenciar:

``` text
Project Tenant B
```

mesmo que aplicação tenha bug.

------------------------------------------------------------------------

## 15. Defense-in-Depth Example

``` text
User requests Project B
        ↓
Application detects Tenant mismatch
        ↓
DENY
```

Se a aplicação falhar:

``` text
Database RLS
        ↓
DENY
```

Esse é o objetivo.

------------------------------------------------------------------------

## 16. Supabase Auth Context

Quando a operação utilizar sessão Supabase apropriada, claims/context
podem apoiar policies.

A estrutura exata das policies será definida em `/docs/07-security/` e
`/docs/06-data/`.

------------------------------------------------------------------------

## 17. Claims

Não colocar arbitrariamente toda autorização dinâmica em JWT claims.

Claims podem ficar stale.

Regras altamente dinâmicas podem exigir consulta a dados atuais.

------------------------------------------------------------------------

## 18. Service Role

Credenciais privilegiadas podem bypassar RLS dependendo da configuração.

Portanto:

``` text
Service Role
=
High Privilege
```

Seu uso deve ser limitado.

------------------------------------------------------------------------

## 19. Service Role Is Not a Shortcut

Não utilizar service-role em todas as operações server-side apenas para
evitar policies.

Isso eliminaria parte importante da defesa em profundidade.

------------------------------------------------------------------------

## 20. Privileged Operations

Algumas operações internas podem exigir contexto privilegiado.

Nesses casos:

``` text
Authenticate/Authorize
      ↓
Privileged Operation
      ↓
Explicit Scope
      ↓
Audit
```

------------------------------------------------------------------------

## 21. Background Jobs

Jobs podem não possuir sessão de usuário tradicional.

Devem carregar contexto explícito:

-   Tenant;
-   actor/system identity;
-   operation;
-   resource.

O job não recebe acesso global irrestrito por padrão.

------------------------------------------------------------------------

## 22. System Actor

Operações automatizadas podem usar identidade conceitual de sistema.

Mesmo assim precisam de:

-   Tenant boundary;
-   purpose;
-   limited privileges;
-   Audit quando relevante.

------------------------------------------------------------------------

## 23. Platform Admin

Platform Admin não deve receber bypass universal implícito.

Acesso excepcional a dados de Tenant deve seguir política específica e
Audit.

------------------------------------------------------------------------

## 24. Option A --- No RLS

### Vantagens

-   policies mais simples;
-   toda autorização fica na aplicação.

### Desvantagens

-   erro de query pode causar vazamento;
-   menos defense in depth;
-   maior impacto de IDOR/BOLA.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 25. Option B --- RLS as Complete Authorization

### Vantagens

-   enforcement centralizado no banco.

### Desvantagens

-   workflow rules complexas;
-   permissions dinâmicas difíceis;
-   policies difíceis de compreender;
-   alto acoplamento;
-   lógica de negócio deslocada para banco.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 26. Option C --- Application Authorization + RLS

### Vantagens

-   defense in depth;
-   domínio continua explícito;
-   banco protege row boundary;
-   reduz impacto de bugs;
-   adequada ao Supabase.

### Desvantagens

-   duas camadas precisam ser mantidas;
-   testes mais complexos;
-   risco de divergência entre aplicação e policies.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 27. Policy Design Principle

Policies devem ser:

-   simples;
-   explícitas;
-   previsíveis;
-   testáveis;
-   tenant-safe.

Evitar transformar SQL policies em um segundo sistema completo de
negócio.

------------------------------------------------------------------------

## 28. Default Deny

Quando RLS estiver habilitada:

``` text
No valid policy
→ No access
```

Esse comportamento é desejável.

------------------------------------------------------------------------

## 29. Sensitive Tables

Prioridade alta para proteção de:

-   Projects;
-   Financial;
-   Resources;
-   Documents;
-   Status;
-   Snapshots;
-   Audit views;
-   integration configuration;
-   AI configuration metadata.

------------------------------------------------------------------------

## 30. Audit Table

Audit possui características especiais.

Usuários comuns não devem editar registros de Audit.

RLS/policies devem reforçar append/read rules conforme função.

------------------------------------------------------------------------

## 31. Snapshot Tables

Published Snapshots são imutáveis.

Policies não devem permitir update/delete comum.

------------------------------------------------------------------------

## 32. Financial Data

Mesmo dentro do Tenant:

``` text
financial.view
```

pode ser necessário.

RLS pode reforçar parte do acesso, mas permission check permanece na
aplicação.

------------------------------------------------------------------------

## 33. Confidential Documents

Document metadata e Storage policies precisam trabalhar em conjunto.

RLS no metadata não protege sozinho o objeto binário.

------------------------------------------------------------------------

## 34. Storage Policies

Supabase Storage deve possuir policies equivalentes ao modelo de
Tenant/ownership.

Acesso ao objeto não deve ser público por padrão.

------------------------------------------------------------------------

## 35. Signed URL Flow

``` text
Request File
   ↓
Application Authorization
   ↓
Storage Policy / Server Access
   ↓
Short-lived Signed URL
```

------------------------------------------------------------------------

## 36. Views

Views precisam ser analisadas cuidadosamente para não contornar policies
ou expor linhas indevidas.

------------------------------------------------------------------------

## 37. Functions / RPC

Database functions devem possuir:

-   security semantics explícitas;
-   Tenant validation;
-   controlled privileges.

Especial atenção a `SECURITY DEFINER`.

------------------------------------------------------------------------

## 38. SECURITY DEFINER

Só usar quando necessário.

Uma função privilegiada pode se tornar bypass de RLS.

Exige:

-   revisão;
-   restricted inputs;
-   safe search path;
-   explicit authorization;
-   tests.

------------------------------------------------------------------------

## 39. Migrations

Toda nova tabela tenant-scoped deve responder:

1.  possui `tenant_id`?
2.  RLS deve estar habilitada?
3.  quais policies?
4.  quais constraints?
5.  quais testes negativos?

------------------------------------------------------------------------

## 40. Migration Checklist

``` text
Create Table
   ↓
Add Tenant Ownership
   ↓
Add Constraints
   ↓
Enable RLS
   ↓
Create Policies
   ↓
Add Indexes
   ↓
Run Isolation Tests
```

------------------------------------------------------------------------

## 41. Test Strategy

Testar:

-   authorized read;
-   unauthorized read;
-   cross-tenant read;
-   cross-tenant update;
-   cross-tenant delete;
-   invalid insert;
-   privileged path;
-   job path;
-   Storage access.

------------------------------------------------------------------------

## 42. Negative Tests Are Mandatory

Não basta testar que Tenant A vê seus dados.

É necessário testar explicitamente:

``` text
Tenant A
cannot see
Tenant B
```

------------------------------------------------------------------------

## 43. Policy Regression

Mudança em policy deve rodar suite completa de isolamento relevante.

------------------------------------------------------------------------

## 44. Deployment Gate

Falha em teste RLS/cross-tenant deve bloquear release.

------------------------------------------------------------------------

## 45. Observability

RLS denials relevantes podem alimentar métricas/logs seguros.

Não logar dados confidenciais para explicar denial.

------------------------------------------------------------------------

## 46. Debugging

Problemas de acesso devem ser distinguíveis entre:

``` text
Authentication Failure
Application Authorization Denial
RLS Denial
Resource Not Found
```

internamente, sem revelar detalhes indevidos ao usuário.

------------------------------------------------------------------------

## 47. Performance

Policies podem impactar queries.

Devem ser analisadas com:

-   indexes;
-   query plans;
-   tenant filters;
-   joins.

Segurança não será removida para "resolver" performance.

------------------------------------------------------------------------

## 48. Indexing

Colunas usadas em policies e filtros tenant-scoped devem possuir índices
apropriados conforme query patterns.

------------------------------------------------------------------------

## 49. Policy Complexity Budget

Se uma policy se tornar excessivamente complexa, reavaliar divisão de
responsabilidade.

Preferência:

``` text
RLS protects row boundary.
Application handles rich business authorization.
```

------------------------------------------------------------------------

## 50. Caching

Cache não pode contornar RLS.

Dados obtidos sob um contexto de Tenant não devem ser entregues a outro
Tenant.

------------------------------------------------------------------------

## 51. Exports

Mesmo se query interna usa acesso privilegiado para gerar export:

``` text
Requested Scope
```

deve ser explicitamente autorizado antes da consulta.

------------------------------------------------------------------------

## 52. AI Retrieval

AI context builder não pode usar acesso privilegiado para buscar dados
além do usuário.

RLS pode ser uma camada adicional de proteção no retrieval.

------------------------------------------------------------------------

## 53. Integrations

Sync jobs devem operar somente sobre Tenant associado à integração.

------------------------------------------------------------------------

## 54. Import

Import deve persistir dados sob Tenant já resolvido pela operação
autorizada.

Não confiar em `tenant_id` vindo da planilha.

------------------------------------------------------------------------

## 55. Support / Break-glass

Se suporte privilegiado precisar bypass controlado:

-   explicit approval;
-   reason;
-   limited duration;
-   scope;
-   Audit;
-   revocation.

------------------------------------------------------------------------

## 56. Consequences --- Positive

-   reduz impacto de bug de query;
-   reforça isolamento;
-   protege acesso direto via APIs compatíveis;
-   complementa authorization;
-   melhora postura de segurança SaaS.

------------------------------------------------------------------------

## 57. Consequences --- Negative

-   maior complexidade de banco;
-   debugging adicional;
-   policies podem divergir do código;
-   risco de performance se mal projetadas;
-   privileged paths exigem cuidado.

------------------------------------------------------------------------

## 58. Mitigations

-   policies simples;
-   documentação;
-   migrations versionadas;
-   automated tests;
-   code review;
-   centralized authorization;
-   observability;
-   poucos privileged paths.

------------------------------------------------------------------------

## 59. Revisit Triggers

Reavaliar estratégia se:

1.  arquitetura mudar para database-per-Tenant;
2.  modelo de autorização exigir abordagem diferente;
3.  limitações de RLS se tornarem bloqueadoras;
4.  performance demonstrar problema estrutural;
5.  provider/database mudar.

Reavaliar não significa remover automaticamente RLS.

------------------------------------------------------------------------

## 60. Relationship with ADR-004

ADR-004 define:

``` text
Multi-Tenant Isolation Strategy
```

ADR-005 define:

``` text
Database Row-Level Defense
```

------------------------------------------------------------------------

## 61. Relationship with ADR-006

ADR-006 é a fonte para autorização de negócio.

RLS não deve contradizer esse modelo.

------------------------------------------------------------------------

## 62. Relationship with ADR-003

A escolha de PostgreSQL/Supabase torna RLS uma capacidade nativa
disponível para defense in depth.

------------------------------------------------------------------------

## 63. Architecture Invariants

1.  RLS não substitui authorization.
2.  Tenant-owned data não fica aberto por padrão.
3.  Service-role não vai para browser.
4.  Privileged access é exceção.
5.  Cross-tenant negative tests são obrigatórios.
6.  Policies devem ser simples e testáveis.
7.  Published Snapshot não recebe update comum.
8.  Audit não recebe edição comum.
9.  Storage exige proteção equivalente.
10. Falha de RLS test bloqueia release.

------------------------------------------------------------------------

## 64. References

-   `/docs/00-foundation/permission-model.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/03-adrs/003-supabase-postgresql.md`
-   `/docs/03-adrs/004-multi-tenant-data-isolation.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 65. Decision Summary

``` text
Decision:
Use PostgreSQL Row Level Security as an additional
defense layer for tenant-scoped and sensitive data.

Model:
Application Authorization
+ Tenant-scoped Queries
+ Constraints
+ RLS
+ Automated Tests

Constraint:
RLS does not replace the PMO Control authorization model.

Why:
It reduces the blast radius of application mistakes
and strengthens multi-tenant isolation.

Revisit:
If the tenancy model, database platform or security
architecture materially changes.
```

------------------------------------------------------------------------

**ADR:** ADR-005\
**Status:** Accepted
