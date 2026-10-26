# SPEC-005 — Projects — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Project`

Campos de domínio: `tenant_id, portfolio_id, name, code, sponsor_id, project_manager_id, status, priority, scope_summary, start_date, baseline_end_date, forecast_end_date, actual_end_date, currency`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Tenant/Portfolio/Project`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Baseline, Forecast e Actual são fatos distintos; Project define scope de autorização.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createProject, updateProject, changeBaseline, assignMember, archiveProject. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
