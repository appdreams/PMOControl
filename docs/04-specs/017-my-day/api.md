# SPEC-017 — My Day — API

**Status:** Draft — read contract

`GET /api/v1/my-day` retorna `MyDayItem` após autenticação, tenant resolution, scope/data policy e permission check. Queries: filtros allowlisted relevantes, cursor pagination quando coleção, `asOf`/`temporalMode` (`current|published`) quando aplicável. Campos: `actor_id, project_id, source_type, source_id, exception_type, due_at, severity, action_url`.

Operações expostas: getMyDay, filterItems, dismissReminder. Sem `POST/PATCH/DELETE` de domínio. Refresh é interno/assíncrono; usuário não invoca projeção para alterar fonte. IDs sem acesso retornam resposta não reveladora. Erros: 401/403/404/422/429 conforme API conventions.
