# PMO Control --- Permission Model

**Documento:** `permission-model.md`\
**Camada:** Foundation\
**Status:** Draft — aligned with SPEC-003 matrix; cross-document review pending\
**Tipo:** Modelo conceitual de autorização

------------------------------------------------------------------------

## 1. Objetivo

Este documento define o modelo conceitual de autorização do PMO Control.

O objetivo é estabelecer uma base única para autenticação,
multi-tenancy, RBAC, escopos, permissões granulares, políticas de dados,
workflows de aprovação, segregação de funções, auditoria e autorização
do PMO Copilot.

A implementação técnica detalhada será definida principalmente em:

-   `/docs/04-specs/001-authentication/`
-   `/docs/04-specs/002-multi-tenancy/`
-   `/docs/04-specs/003-rbac/`
-   `/docs/07-security/`

------------------------------------------------------------------------

# 2. Princípio central

O acesso efetivo não é determinado apenas pelo papel do usuário.

O modelo conceitual é:

> **Effective Access = Tenant + Role + Scope + Permission + Data
> Policy + Workflow Rule**

Representação:

``` text
Authenticated User
        ↓
Tenant Membership
        ↓
Role Assignment
        ↓
Scope
        ↓
Permission
        ↓
Data Policy
        ↓
Workflow Rule
        ↓
Context Validation
        ↓
ALLOW / DENY
```

A autorização deve ser validada no backend.

------------------------------------------------------------------------

# 3. Princípios

## 3.1 Deny by default

Na ausência de autorização válida:

``` text
DENY
```

é o comportamento padrão.

## 3.2 Least privilege

Usuários recebem somente o acesso necessário para executar suas
responsabilidades.

## 3.3 Tenant isolation

Nenhum Role, Scope ou Permission pode romper o isolamento entre Tenants.

## 3.4 Server-side enforcement

Controles visuais são apenas experiência de usuário.

``` text
Hidden Button ≠ Authorization
```

## 3.5 Explicit sensitive access

Acesso geral ao Project não concede automaticamente acesso a informações
sensíveis.

## 3.6 Auditability

Mudanças de autorização e operações sensíveis devem ser rastreáveis.

## 3.7 Authorization inheritance for AI

O PMO Copilot herda exatamente o contexto de autorização do usuário.

------------------------------------------------------------------------

# 4. Componentes do modelo

## Tenant

Define a fronteira primária de isolamento.

## Role

Representa um conjunto lógico de responsabilidades.

## Scope

Define onde o Role/Permission é válido.

## Permission

Define qual operação pode ser executada.

## Data Policy

Aplica restrições adicionais conforme categoria/sensibilidade da
informação.

## Workflow Rule

Define condições de processo para executar determinada operação.

Exemplo:

``` text
User: Maria
Tenant: Empresa A
Role: Project Manager
Scope: Project ERP
Permission: status.update.publish
Data Policy: standard-project-data
Workflow Rule: validate-required-data
```

No workflow padrão do MVP, Project Manager pode publicar diretamente quando possui grant explícito no Project scope; segunda aprovação não é exigida.

------------------------------------------------------------------------

# 5. Papéis padrão

O modelo inicial possui oito papéis:

1.  Platform Admin
2.  Tenant Admin
3.  PMO Admin
4.  PMO
5.  Project Manager
6.  Contributor
7.  Executive
8.  Viewer

Os papéis representam defaults conceituais. A matriz definitiva será
formalizada na Spec de RBAC.

------------------------------------------------------------------------

# 6. Platform Admin

## Responsabilidade

Administração da plataforma SaaS.

Pode administrar, conforme autorização técnica:

-   Tenants;
-   planos;
-   limites;
-   funcionalidades globais;
-   saúde da plataforma;
-   configurações operacionais da plataforma;
-   suporte técnico.

## Restrição fundamental

> Platform Admin não possui acesso automático aos dados de negócio dos
> Tenants.

Acesso excepcional de suporte deve ser:

-   explicitamente autorizado;
-   temporário quando aplicável;
-   limitado;
-   auditado;
-   revogável.

------------------------------------------------------------------------

# 7. Tenant Admin

## Responsabilidade

Administração da organização cliente.

Pode administrar, conforme política:

-   usuários;
-   memberships;
-   roles;
-   scopes;
-   grupos;
-   parâmetros;
-   taxonomias;
-   integrações;
-   RAG configuration;
-   AI/BYOK;
-   configurações do Tenant.

## Observação

Ser Tenant Admin não precisa significar acesso irrestrito a todos os
dados operacionais.

A política do Tenant pode separar administração organizacional de
conteúdo sensível.

------------------------------------------------------------------------

# 8. PMO Admin

## Responsabilidade

Administração de governança de projetos e portfólios.

Capacidades típicas:

-   criar/configurar Portfolios;
-   criar/configurar Projects;
-   atribuir responsabilidades;
-   revisar Status Updates;
-   publicar Status;
-   administrar regras de governança;
-   consultar indicadores;
-   governar Risks, Issues, Actions e Decisions;
-   utilizar Time Machine;
-   gerar Reports;
-   utilizar PMO Copilot;
-   executar operações sensíveis autorizadas.

Operações como Baseline Change ou RAG Override devem permanecer
auditadas.

------------------------------------------------------------------------

# 9. PMO

## Responsabilidade

Governança operacional.

Capacidades típicas:

-   acompanhar projetos;
-   atualizar informações autorizadas;
-   realizar follow-up;
-   acompanhar Risks;
-   acompanhar Issues;
-   acompanhar Actions;
-   acompanhar Decisions;
-   revisar cronograma;
-   preparar Status;
-   publicar Status quando autorizado;
-   consultar Portfolio;
-   gerar Reports;
-   utilizar PMO Copilot.

Não recebe automaticamente todas as permissões administrativas de
`PMO Admin`.

------------------------------------------------------------------------

# 10. Project Manager

## Responsabilidade

Gestão dos projetos sob sua responsabilidade.

Capacidades típicas:

-   atualizar progresso;
-   atualizar Forecast;
-   administrar Milestones;
-   administrar Deliverables;
-   registrar Risks;
-   registrar Issues;
-   administrar Actions;
-   anexar Evidence;
-   administrar Documents autorizados;
-   preparar e publicar Status Update quando `status.update.publish` estiver concedida no Project scope;
-   corrigir publicação somente com grant distinto `status.update.correct` e motivo.

## Restrição

Project Manager não possui automaticamente acesso aos demais projetos do
Portfolio.

------------------------------------------------------------------------

# 11. Contributor

## Responsabilidade

Participação operacional restrita.

Pode, conforme assignment:

-   atualizar Actions atribuídas;
-   atualizar Deliverables atribuídas;
-   colaborar em Risks;
-   anexar Evidence;
-   registrar progresso;
-   comentar.

## Não possui por padrão

-   `baseline.change`;
-   `projects.{projectId}.rag-evaluations.override`;
-   `status.update.publish` fora de scope explicitamente concedido;
-   `status.update.correct` sem grant específico;
-   `financial.edit`;
-   `decision.approve`;
-   administração do Project;
-   acesso a outros Projects.

------------------------------------------------------------------------

# 12. Executive

## Responsabilidade

Consumo executivo e tomada de decisão.

Capacidades típicas:

-   Executive View;
-   dashboards;
-   Portfolio health;
-   projetos autorizados;
-   investimentos autorizados;
-   riscos críticos;
-   marcos críticos;
-   decisões pendentes;
-   aprovar/rejeitar/deferir decisões atribuídas.

## Princípio

Executive é predominantemente `read-only`, exceto por operações
explicitamente atribuídas de decisão/aprovação.

------------------------------------------------------------------------

# 13. Viewer

## Responsabilidade

Consulta.

Pode visualizar somente os recursos autorizados no Scope concedido.

Por padrão não pode:

-   Create;
-   Edit;
-   Delete;
-   Approve;
-   Publish;
-   administrar;
-   alterar governança.

Exportação pode exigir permissão independente.

------------------------------------------------------------------------

# 14. Hierarquia de Scope

Escopos conceituais:

``` text
Tenant
  ↓
Portfolio
  ↓
Project
  ↓
Resource / Assigned Item
```

Exemplos:

``` text
PMO Admin
Scope: Tenant
```

``` text
PMO
Scope: Portfolio Digital
```

``` text
Project Manager
Scope: Project ERP
```

``` text
Contributor
Scope: Assigned Actions
```

Um usuário pode possuir múltiplos assignments.

------------------------------------------------------------------------

# 15. Scope não implica herança irrestrita

A existência de um Scope superior não deve ser interpretada
automaticamente como acesso a qualquer dado sensível dentro dele.

Exemplo:

``` text
Role: PMO
Scope: Portfolio A
Permission: project.read
```

não implica:

``` text
financial.view
documents.confidential.view
```

se essas permissões/policies não estiverem concedidas.

------------------------------------------------------------------------

# 16. Modelo de Permission

Formato recomendado:

``` text
<resource>.<action>
```

Exemplos:

``` text
project.read
project.create
project.edit

milestone.read
milestone.create
milestone.edit

risk.read
risk.create
risk.edit

status.read
status.prepare
status.update.submit
status.update.review
status.update.publish

projects.{projectId}.rag-evaluations.view
projects.{projectId}.rag-evaluations.override

financial.view
financial.edit

decision.read
decision.request
decision.approve

report.view
report.generate
report.export
```

------------------------------------------------------------------------

# 17. Ações padrão

Quando aplicável:

``` text
read
create
edit
delete
archive
approve
reject
submit
review
publish
export
admin
```

Nem todo recurso precisa suportar todas as ações.

------------------------------------------------------------------------

# 18. Permissões sensíveis iniciais

As seguintes permissões devem receber atenção especial:

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

audit.view

access.manage

integration.manage

ai.byok.manage
```

Além das permissões transversais acima, ações de domínio com efeito
irreversível, histórico ou workflow próprio usam grants separados:

``` text
portfolio.projects.associate|remove
project.assign
milestone.forecast|complete
deliverable.deliver|accept|reject
risk.assess|respond|materialize|close
issue.assign|resolve|close|link-risk
action.reassign|complete|cancel
decision.approve|reject|defer|comment
dependency.resolve|view-impact
```

As Specs 004–013 definem o scope de cada grant. Alias no plural pode ser
usado em rotas, mas o catálogo canônico é singular por tipo de recurso e
deve ser normalizado no middleware de autorização.

------------------------------------------------------------------------

# 19. Data Policies

Permission responde:

> O usuário pode executar esta ação sobre este tipo de recurso?

Data Policy responde:

> O usuário pode acessar esta categoria específica de informação?

Exemplo:

``` text
project.read = ALLOW
financial.view = DENY
```

Resultado:

O usuário pode acessar o Project, mas valores financeiros devem
permanecer indisponíveis.

------------------------------------------------------------------------

# 20. Categorias iniciais de Data Policy

A classificação final será definida em `data-classification.md`.

Categorias iniciais:

``` text
standard
internal
confidential
financial
personal-data
restricted-document
security-sensitive
ai-secret
```

------------------------------------------------------------------------

# 21. Workflow Rules

Workflow Rule adiciona governança à autorização.

Exemplo:

``` text
User has status.update.publish
```

regras adicionais só bloqueiam a publicação se fizerem parte do workflow aprovado para aquele domínio. No workflow padrão de Status do MVP, segunda aprovação/`PMO Reviewed` não é exigida; publicar requer permission explícita e validação de estado/versão. Workflows de approval de outros domínios mantêm suas regras próprias.

Logo:

``` text
Permission alone ≠ executable action
```

------------------------------------------------------------------------

# 22. Workflow de Status Update

Fluxo padrão do MVP:

```text
Draft → Validate → Publish → Immutable Snapshot
```

Project Manager com `status.update.publish` explicitamente concedida pode publicar diretamente; não existe etapa obrigatória de segunda aprovação no MVP. `Under Review`/PMO review e permissões `status.update.submit`/`status.update.review` não fazem parte do workflow padrão atual. Podem ser introduzidos futuramente por decisão explícita, sem mudar o default para clientes existentes.

A autorização valida Tenant, Project scope, permission, estado e versão imediatamente antes do commit. Correção exige `status.update.correct`, motivo e publicação sucessora; não reescreve histórico.

# 23. Publicação direta e segregação opcional

No MVP, o Project Manager com grant explícito pode preparar e publicar. Não se exige que preparer e publisher sejam pessoas diferentes. A plataforma pode conceder a mesma permission a PMO Admin/PM, sempre por tenant/project scope.

Segregation of Duties, revisão/aprovação por segunda pessoa e workflow configurável ficam fora do MVP e exigem decisão/feature futura. Isso não se aplica a outras operações governadas (por exemplo, mudança de baseline), que mantêm seu próprio fluxo de approval.

# 24. Baseline Change

Alteração de Baseline é operação governada.

Fluxo conceitual:

``` text
Change Request
      ↓
Reason
      ↓
Impact
      ↓
Evidence
      ↓
Approval
      ↓
New Baseline Version
      ↓
Audit Event
```

Permissões conceituais:

``` text
baseline.view
baseline.request_change
baseline.approve_change
baseline.change
```

------------------------------------------------------------------------

# 25. RAG Override

Fluxo:

``` text
Calculated RAG
      ↓
Override Request / Action
      ↓
Permission Check
      ↓
Justification
      ↓
Effective RAG
      ↓
Audit
```

Dados mínimos:

``` text
calculated_rag
effective_rag
overridden_by
overridden_at
reason
```

------------------------------------------------------------------------

# 26. Executive Decision

Uma Decision pode possuir decisores específicos.

Fluxo:

``` text
Decision Request
      ↓
Authorized Decision Maker
      ↓
Approve / Reject / Defer
      ↓
Result
      ↓
Audit
      ↓
Optional Actions
```

`decision.approve` sozinho não significa que o usuário possa decidir
qualquer Decision.

O Scope e assignment do decisor também devem ser considerados.

------------------------------------------------------------------------

# 27. Segregação de funções

O PMO Control deve permitir políticas de segregação.

Exemplos:

### Status

No mandatory separation in MVP: an explicitly authorized Project Manager may prepare and publish. A future tenant-specific workflow may add separation by explicit decision; it is not the default.

### Baseline

``` text
Requester != Approver
```

### Decision

``` text
Requester != Decision Maker
```

### Sensitive Access

``` text
Access Requester != Access Approver
```

Essas regras podem ser configuráveis por Tenant ou contexto.

------------------------------------------------------------------------

# 28. Matriz conceitual de acesso

Legenda:

-   `R` --- Read
-   `C` --- Create
-   `E` --- Edit
-   `A` --- Approve
-   `P` --- Publish
-   `M` --- Manage
-   `*` --- condicionado a Scope/Policy
-   `—` --- não concedido por padrão

  -----------------------------------------------------------------------------------------------
  Área           Platform   Tenant   PMO     PMO     Project   Contributor   Executive   Viewer
                 Admin      Admin    Admin           Manager                             
  -------------- ---------- -------- ------- ------- --------- ------------- ----------- --------
  Platform       M          ---      ---     ---     ---       ---           ---         ---

  Tenant         ---\*      M        ---\*   ---     ---       ---           ---         ---
  Settings                                                                               

  Users/Access   ---\*      M        ---\*   ---     ---       ---           ---         ---

  Portfolio      ---        R/M\*    M       R/E\*   R\*       ---\*         R\*         R\*

  Project        ---        R\*      M       R/E     M\*       R/E\*         R           R

  Milestones     ---        R\*      M       R/E     M\*       E\*           R           R

  Deliverables   ---        R\*      M       R/E     M\*       E\*           R           R

  Risks          ---        R\*      M       R/E     M\*       E\*           R           R

  Issues         ---        R\*      M       R/E     M\*       E\*           R           R

  Actions        ---        R\*      M       R/E     M\*       E\*           R\*         R\*

  Decisions      ---        R\*      M       R/E     C/E\*     R\*           R/A\*       R

  Status Update  ---        R\*      M/P     E/P\*   C/E\*     ---\*         R           R

  RAG Override   ---        ---\*    M       E\*     ---\*     ---           ---         ---

  Financial      ---        R/M\*    M\*     R/E\*   R/E\*     ---\*         R\*         R\*

  Resources      ---        R/M\*    M\*     R/E\*   R\*       R\*           R\*         R\*

  Documents      ---        R/M\*    M       R/E     R/E       C/E\*         R\*         R\*

  Reports        ---        R\*      M       M\*     R\*       ---\*         R\*         R\*

  Audit          ---\*      R\*      R\*     R\*     ---\*     ---           ---\*       ---

  AI/BYOK Config ---\*      M        ---\*   ---     ---       ---           ---         ---

  PMO Copilot    ---        R\*      R       R       R\*       R\*           R\*         R\*
  -----------------------------------------------------------------------------------------------

Esta tabela é uma baseline conceitual, não substitui a matriz detalhada
da Spec `003-rbac`.

------------------------------------------------------------------------

# 29. Regras por recurso

Toda Specification funcional deverá declarar explicitamente:

``` text
Actors
Permissions
Scope
Data Policies
Approval Rules
Audit Events
```

E responder:

``` text
Who can View?
Who can Create?
Who can Edit?
Who can Delete/Archive?
Who can Approve?
Who can Publish?
Who can Export?
```

------------------------------------------------------------------------

# 30. PMO Copilot

O PMO Copilot deve executar consultas com o mesmo contexto de
autorização do usuário.

Modelo:

``` text
User
 ↓
Tenant
 ↓
Roles / Scope
 ↓
Permissions
 ↓
Data Policies
 ↓
Authorized Retrieval
 ↓
AI Context
 ↓
Model
 ↓
Authorized Response
```

## Regra crítica

> Se o usuário não pode acessar diretamente um dado, o Copilot também
> não pode revelá-lo.

------------------------------------------------------------------------

# 31. Copilot e ações

Para uma ação proposta pela IA:

``` text
AI Recommendation
      ↓
User Confirmation
      ↓
Authorization Re-check
      ↓
Workflow Rule Check
      ↓
Execute
      ↓
Audit
```

A autorização deve ser revalidada no momento da execução.

------------------------------------------------------------------------

# 32. Relatórios e exportações

Relatórios devem ser construídos somente com dados autorizados.

``` text
Authorized Dataset
      ↓
Report
      ↓
Export Permission
      ↓
File
```

`report.view` e `report.export` podem ser permissões diferentes.

Exportações sensíveis podem exigir Audit Event.

------------------------------------------------------------------------

# 33. Documentos confidenciais

Exemplo:

``` text
Project access = ALLOW
document.read = ALLOW
documents.confidential.view = DENY
```

Resultado:

Documentos comuns aparecem; documentos classificados como confidenciais
não.

A ausência do documento na interface não deve revelar metadados
sensíveis indevidamente.

------------------------------------------------------------------------

# 34. Financeiro

Exemplo:

``` text
project.read = ALLOW
financial.view = DENY
```

O sistema deve evitar exposição indireta por:

-   dashboards;
-   tooltips;
-   relatórios;
-   exportações;
-   Copilot;
-   APIs;
-   notificações;
-   logs acessíveis ao usuário.

------------------------------------------------------------------------

# 35. Audit Log

Acesso ao Audit Log deve ser restrito.

Usuários comuns não podem alterar registros.

A visualização pode variar por Scope.

Exemplo:

``` text
PMO Admin
audit.view
Scope: Portfolio A
```

não implica necessariamente acesso aos eventos administrativos globais
do Tenant.

------------------------------------------------------------------------

# 36. Support Access

Acesso excepcional de suporte a dados de Tenant deve seguir fluxo
controlado.

Requisitos conceituais:

``` text
Explicit Authorization
Purpose
Scope
Start Time
Expiration
Support Actor
Audit
Revocation
```

A implementação será definida na camada de Security.

------------------------------------------------------------------------

# 37. Service Accounts e automações

Integrações e jobs não devem utilizar permissões irrestritas sem
necessidade.

Uma identidade técnica deve possuir:

-   Tenant;
-   finalidade;
-   Scope;
-   Permissions;
-   credenciais protegidas;
-   auditoria adequada.

------------------------------------------------------------------------

# 38. API Authorization

APIs devem aplicar o mesmo modelo de autorização.

``` text
Web UI
Mobile/Future Client
Integration
API
AI
```

não são canais com regras de segurança diferentes.

Todos convergem para a mesma política efetiva.

------------------------------------------------------------------------

# 39. Segurança contra IDOR/BOLA

Conhecer ou manipular um identificador não concede acesso ao recurso.

Exemplo:

``` text
GET /projects/{project_id}
```

deve validar Tenant, Scope, Permission e policies aplicáveis.

------------------------------------------------------------------------

# 40. Cache e autorização

Caches não podem servir dados de outro Tenant ou usuário fora do
contexto autorizado.

Chaves e invalidação devem considerar contexto de segurança quando
necessário.

------------------------------------------------------------------------

# 41. Revogação

Mudanças críticas de acesso devem produzir efeito conforme política de
segurança.

Exemplos:

-   usuário removido do Tenant;
-   Role revogado;
-   Project Scope removido;
-   acesso confidencial revogado.

Sessões e caches não devem preservar acesso indevido indefinidamente.

------------------------------------------------------------------------

# 42. Auditoria de autorização

Eventos iniciais:

``` text
UserInvited
UserRemoved
MembershipCreated
MembershipRevoked
RoleAssigned
RoleRevoked
ScopeGranted
ScopeRevoked
PermissionGranted
PermissionRevoked
SupportAccessGranted
SupportAccessRevoked
SensitiveExportPerformed
```

------------------------------------------------------------------------

# 43. Testes obrigatórios de autorização

As Specs de segurança deverão prever testes como:

### Tenant isolation

``` gherkin
Given a user belongs to Tenant A
And Project X belongs to Tenant B
When the user requests Project X
Then access must be denied
```

### Project scope

``` gherkin
Given a Project Manager has access only to Project A
When the user requests Project B
Then access must be denied
```

### Financial policy

``` gherkin
Given a user can read Project A
And the user does not have financial.view
When Project A is displayed
Then financial data must not be exposed
```

### Copilot

``` gherkin
Given a user cannot access Project B
When the user asks the PMO Copilot about Project B
Then the Copilot must not reveal Project B data
```

### Status publication

``` gherkin
Given a user can prepare a Status Update
And the user does not have status.update.publish
When the user attempts publication
Then publication must be denied
```

------------------------------------------------------------------------

# 44. Anti-patterns proibidos

## Role-only authorization

``` text
if role == "PMO":
    allow_everything()
```

Proibido.

## Frontend-only authorization

``` text
hide_button()
```

sem proteção no backend.

Proibido.

## Tenant ID fornecido pelo cliente como autoridade

O sistema não deve confiar cegamente em `tenant_id` enviado pelo
frontend.

## Copilot com service role irrestrito

A IA não deve consultar todo o banco e tentar filtrar apenas no prompt.

## Shared cache sem contexto

Dados de diferentes Tenants não podem compartilhar cache de forma
insegura.

## Export sem revalidação

Permissão de tela não implica automaticamente permissão de exportação.

------------------------------------------------------------------------

# 45. Ordem de avaliação conceitual

Uma decisão de autorização pode seguir:

``` text
1. Is user authenticated?
2. Is membership active?
3. Does resource belong to the Tenant context?
4. Does user have an applicable Role?
5. Is resource inside allowed Scope?
6. Does user have required Permission?
7. Does Data Policy permit the requested fields/data?
8. Does Workflow Rule allow action in current state?
9. Is segregation-of-duties rule satisfied?
10. ALLOW
```

Qualquer falha:

``` text
DENY
```

------------------------------------------------------------------------

# 46. Relação com RLS

RLS é uma camada técnica importante para isolamento e proteção de
registros.

Porém:

> **RLS ≠ modelo completo de autorização.**

Algumas regras dependem de:

-   workflow;
-   state;
-   field-level policy;
-   approval;
-   segregation;
-   business logic.

Logo, a arquitetura poderá combinar:

``` text
Application Authorization
        +
Database RLS
        +
Data Policies
        +
Workflow Validation
```

------------------------------------------------------------------------

# 47. Custom Roles

Custom Roles são uma evolução possível.

Se implementados, não devem permitir:

-   romper Tenant isolation;
-   conceder permissões proibidas pela plataforma;
-   ignorar Data Policies obrigatórias;
-   desativar auditoria crítica.

A decisão de MVP será tomada na Spec `003-rbac`.

------------------------------------------------------------------------

# 48. Groups / Teams

Grupos poderão simplificar assignments.

Exemplo:

``` text
Group: PMO Corporativo
Role: PMO
Scope: Portfolio Estratégico
```

O modelo deve evitar duplicação desnecessária de grants individuais.

A implementação pode ficar fora do MVP se necessário.

------------------------------------------------------------------------

# 49. Permission precedence

A regra definitiva será formalizada na Spec de RBAC.

Princípio inicial:

``` text
Explicit security restriction
        >
General grant
```

e:

``` text
Tenant isolation
        >
Any permission
```

Nenhuma permissão pode sobrescrever isolamento de Tenant.

------------------------------------------------------------------------

# 50. Decisões em aberto

Devem ser resolvidas nas Specs/ADRs apropriadas:

1.  Custom Roles no MVP;
2.  Groups no MVP;
3.  herança exata de Scope;
4.  precedence detalhada entre grants/denies;
5.  suporte a field-level permissions;
6.  acesso temporário;
7.  fluxo de support access;
8.  duração/revogação de sessões;
9.  delegação de aprovação;
10. múltiplos decisores;
11. aprovação por quorum;
12. permissões por custom field;
13. modelo de service accounts;
14. usuários multi-tenant;
15. acesso de auditor externo.

------------------------------------------------------------------------

# 51. Invariantes de autorização

1.  Tenant isolation nunca pode ser ignorado por Role.
2.  UI não é mecanismo de segurança.
3.  Copilot não amplia acesso.
4.  Export não amplia acesso.
5.  API não amplia acesso.
6.  Notification não amplia acesso.
7.  Dashboard não amplia acesso.
8.  Permission não ignora Data Policy.
9.  Permission não ignora Workflow Rule.
10. Scope deve ser verificado no recurso real.
11. Alterações de acesso relevantes são auditáveis.
12. Operações sensíveis devem ser explicitamente autorizadas.
13. Identidades técnicas seguem least privilege.
14. Revogação não pode depender apenas de logout voluntário.
15. Acesso excepcional deve ser controlado e auditado.

## 51.1 Permissões de IA por Tenant

- `ai.config.view`: consultar configuração de IA sem segredo nem referência interna.
- `ai.config.manage`: validar, gravar, rotacionar e desabilitar credencial própria e mapeamentos low/medium/high no Tenant.
- `ai.cost.view`: consultar ledger/agregados de uso e custo do Tenant.
- `ai.cost.export`: exportar dados de uso/custo dentro do Tenant.

Essas permissões exigem membership ativa e scope Tenant; segredo é resolvido somente no servidor e nunca pode ser lido via API, audit ou RLS pelo cliente. Custo/uso é dado sensível separado da permissão geral do Copilot.

## 51.2 Permissões de importação de dados de projeto

- `project.data.import`: listar/selecionar Projects do Tenant autorizado, baixar modelos e importar ao Project selecionado.
- `project.data.import.replace`: grant elevado e separado para arquivar o conjunto operacional v1 e substituir os dados; exige motivo, contagem de impacto e confirmação digitada.

Nenhum grant permite cross-Tenant. Seleção, arquivo e payload nunca são prova de acesso; o backend verifica membership, Project scope, estado, permission e versão no momento do apply. Reiniciar não apaga audit, publicações, snapshots ou holds.

------------------------------------------------------------------------

# 52. Referências

-   `/docs/00-foundation/README.md`
-   `/docs/00-foundation/glossary.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/01-product/PDD.md`
-   `/docs/04-specs/001-authentication/`
-   `/docs/04-specs/002-multi-tenancy/`
-   `/docs/04-specs/003-rbac/`
-   `/docs/07-security/`

------------------------------------------------------------------------

# 53. Status

**Documento:** Permission Model\
**Status:** Under Review\
**Responsabilidade:** estabelecer o modelo conceitual de autorização,
papéis, escopos, permissões, políticas de dados, workflows e invariantes
de segurança do PMO Control.

## Entitlement privilegiado de purge de Project

`platform.projects.purge` é um entitlement de plataforma explícito, fora dos presets de Tenant, e não herda `projects.view` nem acesso de suporte. Sua única finalidade é executar o workflow confirmado de purge e ler metadados mínimos de impacto/status. Cada chamada revalida ator, entitlement, expiração e project target; qualquer acesso a conteúdo continua negado sem concessão independente autorizada. Concessão/revogação é auditada e não delegável por administradores de Tenant/Project.
