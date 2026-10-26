# SPEC-006 — Project Control Center — Data/Projection

**Status:** Draft — read model; sem tabela autoritativa

Projeção lógica `project_control_summaries` (se materializada, derivada/reconstruível): `current_rag, published_rag, progress, forecast_end_date, budget_variance, critical_risks, open_issues, overdue_actions, next_milestone, source_versions`. Incluir `tenant_id`, scope IDs, `as_of`, `source_version` e refreshed timestamp. RLS e queries aplicam Tenant e scope. Atualização ocorre após commit da fonte via job idempotente; projeção pode ficar stale e deve expor o instante de atualização. Não armazenar secrets nem conteúdo fora da data policy. A fonte relacional/ snapshot autoritativa permanece no respectivo módulo, não nesta Spec.
