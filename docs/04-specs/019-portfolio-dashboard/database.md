# SPEC-019 — Portfolio Dashboard — Data/Projection

**Status:** Draft — read model; sem tabela autoritativa

Projeção lógica `portfolio_dashboard_projections` (se materializada, derivada/reconstruível): `temporal_mode, as_of, authorized_project_count, rag_distribution, delivery_metrics, budget_summary, critical_exceptions`. Incluir `tenant_id`, scope IDs, `as_of`, `source_version` e refreshed timestamp. RLS e queries aplicam Tenant e scope. Atualização ocorre após commit da fonte via job idempotente; projeção pode ficar stale e deve expor o instante de atualização. Não armazenar secrets nem conteúdo fora da data policy. A fonte relacional/ snapshot autoritativa permanece no respectivo módulo, não nesta Spec.
