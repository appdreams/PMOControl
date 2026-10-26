# SPEC-023 — Time Machine — Data/Projection

**Status:** Draft — read model; sem tabela autoritativa

Projeção lógica `snapshot_comparisons` (se materializada, derivada/reconstruível): `from_snapshot_id, to_snapshot_id, sections, diff, generated_at`. Incluir `tenant_id`, scope IDs, `as_of`, `source_version` e refreshed timestamp. RLS e queries aplicam Tenant e scope. Atualização ocorre após commit da fonte via job idempotente; projeção pode ficar stale e deve expor o instante de atualização. Não armazenar secrets nem conteúdo fora da data policy. A fonte relacional/ snapshot autoritativa permanece no respectivo módulo, não nesta Spec.
