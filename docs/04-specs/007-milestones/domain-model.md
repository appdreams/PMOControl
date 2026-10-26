# SPEC-007 — Milestones — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Milestone`

Campos de domínio: `tenant_id, project_id, name, type, owner_id, baseline_date, forecast_date, actual_date, criticality, status, progress, dependency_ids`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Baseline Date, Forecast Date e Actual Date nunca se sobrescrevem entre si.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createMilestone, updateMilestone, changeForecast, completeMilestone, requestBaselineChange. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
