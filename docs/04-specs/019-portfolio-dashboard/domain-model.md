# SPEC-019 — Portfolio Dashboard — Domain Model

**Status:** Draft — read model

## Projection

`PortfolioDashboardProjection` é view/read model derivado de entidades oficiais. Campos visíveis: `temporal_mode, as_of, authorized_project_count, rag_distribution, delivery_metrics, budget_summary, critical_exceptions`. Chave primária de navegação é o ID da fonte ou combinação de IDs de snapshot; nunca uma nova identidade de domínio.

## Invariantes

1. Dashboard declara Current ou Published e não altera fatos.
2. Tenant, membership, Project/Portfolio scope e field-level data policy são reaplicados na leitura.
3. Link de ação navega para fonte de verdade e reautoriza a operação.
