# SPEC-023 — Time Machine — Domain Model

**Status:** Draft — read model

## Projection

`SnapshotComparison` é view/read model derivado de entidades oficiais. Campos visíveis: `from_snapshot_id, to_snapshot_id, sections, diff, generated_at`. Chave primária de navegação é o ID da fonte ou combinação de IDs de snapshot; nunca uma nova identidade de domínio.

## Invariantes

1. Passado deriva exclusivamente de snapshots publicados.
2. Tenant, membership, Project/Portfolio scope e field-level data policy são reaplicados na leitura.
3. Link de ação navega para fonte de verdade e reautoriza a operação.
