# SPEC-023 — Time Machine — API

**Status:** Draft — read contract

`GET /api/v1/projects/{projectId}/time-machine` retorna `SnapshotComparison` após autenticação, tenant resolution, scope/data policy e permission check. Queries: filtros allowlisted relevantes, cursor pagination quando coleção, `asOf`/`temporalMode` (`current|published`) quando aplicável. Campos: `from_snapshot_id, to_snapshot_id, sections, diff, generated_at`.

Operações expostas: listTimeline, getHistoricalView, compareSnapshots. Sem `POST/PATCH/DELETE` de domínio. Refresh é interno/assíncrono; usuário não invoca projeção para alterar fonte. IDs sem acesso retornam resposta não reveladora. Erros: 401/403/404/422/429 conforme API conventions.
