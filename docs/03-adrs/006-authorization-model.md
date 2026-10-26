# ADR-006 --- Authorization Model

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Adotar autorização contextual baseada em Tenant + Role +
Scope + Permission + Data Policy + Workflow Rule, com deny by default e
enforcement server-side.

------------------------------------------------------------------------

## 1. Context

O PMO Control possui diferentes tipos de usuários e diferentes níveis de
responsabilidade sobre dados de governança.

Exemplos:

-   Platform Admin;
-   Tenant Admin;
-   PMO Admin;
-   PMO;
-   Project Manager;
-   Contributor;
-   Executive;
-   Viewer.

Um mesmo usuário pode possuir responsabilidades diferentes em diferentes
Tenants, Portfolios ou Projects.

Além disso, algumas operações são sensíveis:

``` text
status.update.publish
baseline.change
projects.{projectId}.rag-evaluations.override
decision.approve
financial.view
financial.edit
documents.confidential.view
report.export
```

RBAC simples por papel global não é suficiente.

------------------------------------------------------------------------

## 2. Problem

É necessário definir como o sistema decide:

> **Quem pode fazer o quê, sobre qual recurso, em qual contexto e em
> qual estado?**

A solução deve ser segura sem transformar toda autorização em regras ad
hoc espalhadas pelo código.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   multi-tenancy;
-   least privilege;
-   diferentes níveis de escopo;
-   permissões sensíveis;
-   segregação de funções;
-   workflows;
-   proteção de dados;
-   auditabilidade;
-   capacidade de evolução;
-   clareza para Specs;
-   testabilidade.

------------------------------------------------------------------------

## 4. Decision

O acesso efetivo será calculado por:

``` text
Effective Access
=
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

com:

``` text
Default = DENY
```

------------------------------------------------------------------------

## 5. Authentication First

Antes de autorização:

``` text
Authenticate
```

Supabase Auth identifica o usuário.

Autenticação não concede automaticamente acesso a nenhum Tenant ou
recurso.

------------------------------------------------------------------------

## 6. Tenant

Primeira fronteira de negócio:

``` text
User
  ↓
Tenant Membership
```

Sem Membership ou grant válido, o usuário não possui acesso ao Tenant.

------------------------------------------------------------------------

## 7. Role

Role representa um conjunto base de responsabilidades.

Roles iniciais:

1.  Platform Admin;
2.  Tenant Admin;
3.  PMO Admin;
4.  PMO;
5.  Project Manager;
6.  Contributor;
7.  Executive;
8.  Viewer.

------------------------------------------------------------------------

## 8. Scope

Role não é necessariamente global dentro do Tenant.

Scopes conceituais:

``` text
Tenant
Portfolio
Project
Resource / Assigned Item
```

------------------------------------------------------------------------

## 9. Same Role, Different Scope

Exemplo:

``` text
User A
PMO
Portfolio X
```

não implica automaticamente acesso ao Portfolio Y.

------------------------------------------------------------------------

## 10. Same User, Multiple Roles

Exemplo:

``` text
Tenant A → PMO Admin
Tenant B → Viewer
```

ou:

``` text
Project X → Project Manager
Project Y → Viewer
```

quando o modelo permitir grants específicos.

------------------------------------------------------------------------

## 11. Permission

Permission representa uma ação explícita.

Formato recomendado:

``` text
resource.action
```

Exemplos:

``` text
project.view
project.edit
risk.create
risk.edit
status.update.publish
projects.{projectId}.rag-evaluations.override
decision.approve
financial.view
report.export
```

------------------------------------------------------------------------

## 12. Role Is Permission Bundle

Role não deve ser usado diretamente como regra em todo código.

Preferência:

``` text
Role
  ↓
Permissions
```

e use cases verificam permission necessária.

Isso facilita evolução.

------------------------------------------------------------------------

## 13. Sensitive Permissions

Permissões especialmente sensíveis incluem:

``` text
financial.view
financial.edit
resources.view
resources.edit
documents.confidential.view
status.update.publish
baseline.change
projects.{projectId}.rag-evaluations.override
decision.approve
report.export
```

Devem ser deny by default.

------------------------------------------------------------------------

## 14. Data Policy

Mesmo com Permission, Data Policy pode limitar quais dados são visíveis.

Exemplo:

``` text
project.view
+
Scope Project A
```

não concede Project B.

------------------------------------------------------------------------

## 15. Workflow Rule

Estado do recurso também pode restringir ação.

Exemplo:

``` text
Snapshot Published
→ update denied
```

mesmo para usuário com permissão ampla.

------------------------------------------------------------------------

## 16. Authorization Function

Conceitualmente:

``` text
authorize(
  actor,
  tenant,
  action,
  resource,
  context
)
```

Resultado:

``` text
ALLOW
or
DENY
```

------------------------------------------------------------------------

## 17. Server-Side Enforcement

Autorização ocorre no servidor.

Frontend pode esconder botões por UX, mas:

``` text
Hidden Button
≠
Security
```

------------------------------------------------------------------------

## 18. Deny by Default

Se não existir regra explícita permitindo:

``` text
DENY
```

------------------------------------------------------------------------

## 19. Platform Admin

Responsável por capacidades SaaS/plataforma.

Não possui acesso automático a dados de negócio dos Tenants.

Acesso excepcional:

-   explícito;
-   autorizado;
-   temporário quando possível;
-   justificado;
-   auditado.

------------------------------------------------------------------------

## 20. Tenant Admin

Responsabilidades típicas:

-   users;
-   memberships;
-   access;
-   groups;
-   settings;
-   taxonomies;
-   integrations;
-   AI/BYOK configuration;
-   RAG configuration.

Não implica automaticamente direito de executar todas as decisões de
governança.

------------------------------------------------------------------------

## 21. PMO Admin

Pode possuir capacidades amplas de governança:

-   Portfolios;
-   Projects;
-   Status;
-   RAG;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   reports;
-   Time Machine.

Operações sensíveis continuam permission-based.

------------------------------------------------------------------------

## 22. PMO

Foco operacional:

-   acompanhar;
-   atualizar;
-   consolidar;
-   cobrar;
-   preparar Status;
-   riscos/issues;
-   ações;
-   relatórios;
-   Copilot.

Algumas ações podem exigir PMO Admin.

------------------------------------------------------------------------

## 23. Project Manager

Escopo padrão:

``` text
Assigned Projects
```

Pode atualizar execução, milestones, deliverables, riscos, issues,
actions e preparar Status conforme permissions.

Não recebe automaticamente Portfolio inteiro.

------------------------------------------------------------------------

## 24. Contributor

Escopo restrito.

Pode:

-   atualizar itens atribuídos;
-   adicionar Evidence;
-   comentar;
-   atualizar progresso permitido.

Não pode automaticamente:

-   mudar baseline;
-   publicar Status;
-   alterar RAG;
-   editar orçamento;
-   aprovar decisão executiva.

------------------------------------------------------------------------

## 25. Executive

Predominantemente read-only.

Pode visualizar:

-   Executive Portfolio;
-   authorized Projects;
-   investimentos;
-   riscos críticos;
-   milestones;
-   decisões.

Pode:

``` text
Approve
Reject
Defer
```

decisões explicitamente atribuídas quando autorizado.

------------------------------------------------------------------------

## 26. Viewer

Read-only dentro do Scope autorizado.

------------------------------------------------------------------------

## 27. Segregation of Duties

Regras configuráveis podem exigir:

``` text
Status Preparer
≠
Status Publisher
```

``` text
Baseline Requester
≠
Baseline Approver
```

``` text
Decision Requester
≠
Decision Maker
```

------------------------------------------------------------------------

## 28. Self-Approval

Contributor ou requester não deve aprovar automaticamente sua própria
solicitação quando segregação estiver configurada.

------------------------------------------------------------------------

## 29. Status Publication

Fluxo:

``` text
Draft
 ↓
Review
 ↓
PMO Review
 ↓
Publish
```

`status.update.publish` é permission sensível.

Tenant pode configurar fluxo simplificado, mas a autorização permanece
explícita.

------------------------------------------------------------------------

## 30. RAG Override

Exige:

``` text
projects.{projectId}.rag-evaluations.override
```

e registra:

-   calculated RAG;
-   effective RAG;
-   justification;
-   actor;
-   timestamp.

------------------------------------------------------------------------

## 31. Baseline Change

Exige workflow governado.

``` text
Request
 ↓
Impact
 ↓
Evidence
 ↓
Approval
 ↓
New Baseline Version
```

------------------------------------------------------------------------

## 32. Decision Approval

A autorização deve validar:

-   decisão;
-   assignee/decision maker;
-   Scope;
-   Permission;
-   current state.

------------------------------------------------------------------------

## 33. Financial Access

Financeiro é segregado.

Um PMO com acesso ao Project não necessariamente possui:

``` text
financial.view
```

------------------------------------------------------------------------

## 34. Confidential Documents

Document access pode exigir:

``` text
documents.confidential.view
```

além de Project Scope.

------------------------------------------------------------------------

## 35. Reports / Export

Visualizar dashboard não implica automaticamente exportar dados.

`report.export` pode ser permission separada.

------------------------------------------------------------------------

## 36. AI Authorization

Regra:

``` text
AI Access
≤
User Effective Access
```

Copilot nunca amplia Scope.

------------------------------------------------------------------------

## 37. AI Action

Ação consequencial sugerida por IA:

``` text
AI Proposal
 ↓
Human Confirmation
 ↓
Fresh Authorization Check
 ↓
Domain Validation
 ↓
Command
 ↓
Audit
```

------------------------------------------------------------------------

## 38. Background Jobs

Jobs executam com contexto explícito.

Não devem possuir autorização ilimitada apenas por serem internos.

------------------------------------------------------------------------

## 39. Integrations

Integrações também respeitam:

-   Tenant;
-   configured Scope;
-   source authority;
-   data policy;
-   operation permissions.

------------------------------------------------------------------------

## 40. API Authorization

Qualquer API futura deve usar o mesmo modelo.

Não criar um segundo sistema de autorização para APIs.

------------------------------------------------------------------------

## 41. Option A --- Role-Only RBAC

### Vantagens

-   simples.

### Desvantagens

-   não representa Scope;
-   não representa dados sensíveis;
-   não representa workflow;
-   tende a criar roles demais.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 42. Option B --- Fine-Grained Permissions Only

### Vantagens

-   flexibilidade.

### Desvantagens

-   administração complexa;
-   difícil compreensão;
-   grande volume de grants.

### Resultado

**Rejected as sole model.**

------------------------------------------------------------------------

## 43. Option C --- Role + Scope + Permission + Policies

### Vantagens

-   flexível;
-   compreensível;
-   escalável;
-   adequado ao domínio;
-   suporta least privilege.

### Desvantagens

-   implementação mais sofisticada;
-   exige testes de matriz;
-   administração precisa de UX clara.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 44. Authorization vs RLS

Application authorization decide:

``` text
Can this actor perform this business action?
```

RLS reforça:

``` text
Can this database context access this row?
```

As duas camadas são complementares.

------------------------------------------------------------------------

## 45. Authorization vs UI

UI pode usar capabilities para:

-   mostrar;
-   esconder;
-   desabilitar controles.

Mas servidor sempre revalida.

------------------------------------------------------------------------

## 46. Permission Naming

Convenção:

``` text
<resource>.<action>
```

Exemplos:

``` text
risk.view
risk.create
risk.edit
risk.delete
status.update.publish
```

------------------------------------------------------------------------

## 47. Permission Catalog

Catálogo central deve evitar strings arbitrárias espalhadas pelo código.

------------------------------------------------------------------------

## 48. Authorization Context

Pode incluir:

-   actor;
-   Tenant;
-   resource;
-   resource owner;
-   Scope;
-   state;
-   classification;
-   assignment;
-   workflow.

------------------------------------------------------------------------

## 49. Authorization Result

Internamente pode incluir razão/código:

``` text
ALLOW
DENY_NO_MEMBERSHIP
DENY_SCOPE
DENY_PERMISSION
DENY_DATA_POLICY
DENY_WORKFLOW
```

Usuário final não precisa receber detalhes que facilitem enumeração.

------------------------------------------------------------------------

## 50. Audit

Eventos sensíveis de autorização:

-   grant;
-   revoke;
-   Role change;
-   Scope change;
-   privileged access;
-   RAG override;
-   publication;
-   baseline approval;
-   executive decision;
-   sensitive export.

------------------------------------------------------------------------

## 51. Permission Changes

Alterações de acesso devem ter efeito previsível.

Sessões/tokens não devem manter privilégio removido indefinidamente.

------------------------------------------------------------------------

## 52. JWT Claims

Não depender exclusivamente de claims long-lived para autorização
dinâmica.

Quando necessário, consultar estado atual.

------------------------------------------------------------------------

## 53. Caching Authorization

Cache de permissions deve possuir estratégia de invalidação.

Revogação de acesso é requisito de segurança.

------------------------------------------------------------------------

## 54. Test Matrix

Cada Spec funcional deve declarar:

``` text
Actors
Permissions
Scope
Data Policies
Approval Rules
Audit Events
```

------------------------------------------------------------------------

## 55. CRUD + Governance Matrix

Para cada recurso relevante testar:

-   View;
-   Create;
-   Edit;
-   Delete/Archive;
-   Approve;
-   Publish;
-   Export.

------------------------------------------------------------------------

## 56. Negative Tests

Testar explicitamente:

``` text
Wrong Tenant
Wrong Scope
Missing Permission
Wrong Workflow State
Confidential Data Without Permission
Self-Approval When Forbidden
```

------------------------------------------------------------------------

## 57. Authorization as Architecture

Authorization não é middleware genérico isolado.

É parte do domínio de governança e deve estar presente nos use cases.

------------------------------------------------------------------------

## 58. Performance

Checks devem ser eficientes, mas não removidos por performance.

Otimizações podem incluir:

-   indexed memberships;
-   precomputed grants quando necessário;
-   safe caching;
-   query optimization.

------------------------------------------------------------------------

## 59. Observability

Monitorar:

-   denials;
-   privileged actions;
-   repeated unauthorized attempts;
-   unusual access patterns;
-   support access.

------------------------------------------------------------------------

## 60. Administration UX

Settings deve permitir compreender:

``` text
Who
has
what access
where
```

Evitar modelo impossível de auditar visualmente.

------------------------------------------------------------------------

## 61. Explain Access

Capacidade futura útil:

> "Por que este usuário pode acessar este Project?"

Resposta deve ser derivável de:

``` text
Membership
→ Role
→ Scope
→ Permission
→ Policy
```

------------------------------------------------------------------------

## 62. Revocation

Deve ser possível revogar:

-   Tenant Membership;
-   Role assignment;
-   Scope grant;
-   specific permission/grant.

------------------------------------------------------------------------

## 63. Ownership Transfer

Mudanças de ownership/assignment não devem automaticamente alterar
Tenant.

------------------------------------------------------------------------

## 64. Future Groups

Groups podem facilitar grants para:

-   áreas;
-   equipes;
-   portfolios.

Devem compor o modelo sem substituir permissions.

------------------------------------------------------------------------

## 65. Future SSO/SCIM

SSO/SCIM podem provisionar identidade/membership.

Não substituem autorização interna de recursos.

------------------------------------------------------------------------

## 66. Consequences --- Positive

-   least privilege;
-   suporte multi-scope;
-   reduz role explosion;
-   permite dados sensíveis;
-   suporta workflows;
-   auditável;
-   consistente com Specs.

------------------------------------------------------------------------

## 67. Consequences --- Negative

-   maior complexidade;
-   matriz de testes extensa;
-   UI administrativa precisa ser boa;
-   caching/revocation exigem cuidado.

------------------------------------------------------------------------

## 68. Mitigations

-   permission catalog central;
-   authorize() centralizado;
-   helpers;
-   policy documentation;
-   automated tests;
-   Spec template obrigatório;
-   deny by default.

------------------------------------------------------------------------

## 69. Revisit Triggers

Reavaliar se:

1.  número de policies tornar o modelo impraticável;
2.  clientes exigirem ABAC avançado;
3.  external policy engine se justificar;
4.  enterprise IAM exigir integração mais sofisticada;
5.  performance de checks se tornar gargalo medido.

------------------------------------------------------------------------

## 70. Future Policy Engine

Ferramentas dedicadas de policy não entram no MVP.

Só considerar com necessidade comprovada.

------------------------------------------------------------------------

## 71. Architecture Invariants

1.  Authentication não implica authorization.
2.  Role não é global por padrão.
3.  Scope é explícito.
4.  Sensitive permissions são deny by default.
5.  Frontend não é security boundary.
6.  Server revalida toda ação sensível.
7.  AI não amplia acesso.
8.  Platform Admin não possui acesso automático aos dados dos Tenants.
9.  Published Snapshot respeita imutabilidade.
10. Revogação precisa produzir efeito previsível.
11. RLS complementa, não substitui autorização.
12. Specs declaram authorization requirements.

------------------------------------------------------------------------

## 72. Relationship with ADR-004

ADR-004 define Tenant isolation.

ADR-006 define autorização dentro e além dessa fronteira.

------------------------------------------------------------------------

## 73. Relationship with ADR-005

RLS reforça row access.

ADR-006 continua sendo fonte da decisão de negócio.

------------------------------------------------------------------------

## 74. References

-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/03-adrs/004-multi-tenant-data-isolation.md`
-   `/docs/03-adrs/005-row-level-security.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 75. Decision Summary

``` text
Decision:
Effective Access =
Tenant
+ Role
+ Scope
+ Permission
+ Data Policy
+ Workflow Rule

Default:
DENY

Enforcement:
Server-side, complemented by database controls.

Why:
Role-only RBAC cannot safely represent the PMO Control
multi-tenant, multi-scope and governance requirements.

Revisit:
If enterprise IAM, ABAC complexity or measured scale
justifies a dedicated policy architecture.
```

------------------------------------------------------------------------

**ADR:** ADR-006\
**Status:** Accepted
