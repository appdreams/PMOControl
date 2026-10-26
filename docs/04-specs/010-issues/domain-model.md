# SPEC-010 — Issues — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Issue`

Campos de domínio: `tenant_id, project_id, source_risk_id, description, root_cause, impact, priority, owner_id, opened_at, due_date, resolved_at, status, blocker`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Issue representa problema ocorrido; priority segue PDD (`low|medium|high|critical`), blocker é explícito e aging deriva de datas.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createIssue, updateIssue, assignOwner, resolveIssue, closeIssue, linkRisk. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
