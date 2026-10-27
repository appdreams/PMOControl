# SPEC-003 — RBAC & Contextual Authorization — Acceptance Criteria

**Status:** Draft — policy outcomes testable

## AC-003-01 — allow requires full context

**Given** active user/membership, Tenant, scope, grant, permission and data policy match
**When** server evaluates authorized operation
**Then** it allows only the resource/fields in that scope.

## AC-003-02 — missing context denies

**Given** any required context is absent, expired or ambiguous
**When** query/command executes through API, storage, AI or job
**Then** deny without partial mutation or resource enumeration.

## AC-003-03 — explicit deny precedence

**Given** matching allow and deny grants exist
**When** policy is evaluated
**Then** explicit deny wins and decision is auditable.

## AC-003-04 — no implicit scope inheritance

**Given** user has Portfolio scope but no inheritable permission grant
**When** accesses a Project/resource under it
**Then** access is denied unless the permission catalog explicitly defines cascade.

## AC-003-05 — no privilege escalation

**Given** Tenant Admin attempts to grant a role/permission beyond delegation ceiling or another Tenant
**When** grant is created
**Then** server rejects and leaves no grant.

## AC-003-06 — revocation

**Given** grant/membership is revoked
**When** next request or queued job evaluates it
**Then** access is denied and stale decision cache is not used.

## AC-003-07 — sensitive separation

**Given** Project Manager has project.view but lacks financial.view
**When** reads dashboards/export/AI context
**Then** financial fields are omitted and cannot be inferred from aggregates.

## AC-003-08 — entitlement root isolado

**Given** Platform Admin comum e Platform Root Admin com grant explícito
**When** cada ator chama operações de purge de Project
**Then** somente o segundo pode usar preview/confirm/status, sem que o grant conceda leitura do conteúdo do Tenant.

## AC-003-09 — purge não pode ser delegado pelo Tenant

**Given** Tenant Admin/PMO Admin tenta atribuir `platform.projects.purge` ou delegá-lo
**When** o grant é submetido
**Then** servidor nega, audita a tentativa e não cria autorização.

## AC-003-10 — ancestry explícita e interseção de deny

**Given** uma permissão, grant e ancestry resolvidos pelo catálogo confiável
**When** o avaliador decide acesso a um scope
**Then** allow ancestral só alcança descendente quando a permissão declara herança e cada aresta consta no DAG versionado
**And** deny na mesma scope ou em ancestral aplicável vence, enquanto sibling/descendente não afeta o pedido
**And** ancestry ausente, ambígua ou inválida resulta em deny.
