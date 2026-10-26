# SPEC-020 — Financial — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`ProjectFinancials`

Campos de domínio: `project_id, currency, approved_budget, revised_budget, committed_amount, actual_amount, forecast_amount, variance, period, baseline_version`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project + Financial permission`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Dados Restricted; baseline aprovada não muda com forecast/actual; access financial.view/edit explícito.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: readFinancials, recordCommitment, recordActual, updateForecast, requestBudgetBaselineChange. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
