# SPEC-018 — Project Dashboard — Data/Projection

**Status:** Draft — read model; sem tabela autoritativa

Projeção lógica `project_dashboard_projections` (se materializada, derivada/reconstruível): `temporal_mode, as_of, current_progress, published_progress, rag, forecast, budget_summary, milestone_summary, risk_summary, issue_summary`. Incluir `tenant_id`, scope IDs, `as_of`, `source_version` e refreshed timestamp. RLS e queries aplicam Tenant e scope. Atualização ocorre após commit da fonte via job idempotente; projeção pode ficar stale e deve expor o instante de atualização. Não armazenar secrets nem conteúdo fora da data policy. A fonte relacional/ snapshot autoritativa permanece no respectivo módulo, não nesta Spec.
