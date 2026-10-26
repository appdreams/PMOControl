# SPEC-006 — Project Control Center — Domain Model

**Status:** Draft — read model

## Projection

`ProjectControlSummary` é view/read model derivado de entidades oficiais. Campos visíveis: `current_rag, published_rag, progress, forecast_end_date, budget_variance, critical_risks, open_issues, overdue_actions, next_milestone, source_versions`. Chave primária de navegação é o ID da fonte ou combinação de IDs de snapshot; nunca uma nova identidade de domínio.

## Invariantes

1. É projeção derivada; nunca fonte paralela de verdade.
2. Tenant, membership, Project/Portfolio scope e field-level data policy são reaplicados na leitura.
3. Link de ação navega para fonte de verdade e reautoriza a operação.
