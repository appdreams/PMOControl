# SPEC-018 — Project Dashboard — Domain Model

**Status:** Draft — read model

## Projection

`ProjectDashboardProjection` é view/read model derivado de entidades oficiais. Campos visíveis: `temporal_mode, as_of, current_progress, published_progress, rag, forecast, budget_summary, milestone_summary, risk_summary, issue_summary`. Chave primária de navegação é o ID da fonte ou combinação de IDs de snapshot; nunca uma nova identidade de domínio.

## Invariantes

1. Dashboard declara Current ou Published e não altera fatos.
2. Tenant, membership, Project/Portfolio scope e field-level data policy são reaplicados na leitura.
3. Link de ação navega para fonte de verdade e reautoriza a operação.
