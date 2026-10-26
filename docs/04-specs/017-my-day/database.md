# SPEC-017 — My Day — Data/Projection

**Status:** Draft — read model; sem tabela autoritativa

Projeção lógica `my_day_items` (se materializada, derivada/reconstruível): `actor_id, project_id, source_type, source_id, exception_type, due_at, severity, action_url`. Incluir `tenant_id`, scope IDs, `as_of`, `source_version` e refreshed timestamp. RLS e queries aplicam Tenant e scope. Atualização ocorre após commit da fonte via job idempotente; projeção pode ficar stale e deve expor o instante de atualização. Não armazenar secrets nem conteúdo fora da data policy. A fonte relacional/ snapshot autoritativa permanece no respectivo módulo, não nesta Spec.
