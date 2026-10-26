# SPEC-006 — Project Control Center — API

**Status:** Draft — read contract

`GET /api/v1/projects/{projectId}/control-center` retorna `ProjectControlSummary` após autenticação, tenant resolution, scope/data policy e permission check. Queries: filtros allowlisted relevantes, cursor pagination quando coleção, `asOf`/`temporalMode` (`current|published`) quando aplicável. Campos: `current_rag, published_rag, progress, forecast_end_date, budget_variance, critical_risks, open_issues, overdue_actions, next_milestone, source_versions`.

Operações expostas: getControlCenter. Sem `POST/PATCH/DELETE` de domínio. Refresh é interno/assíncrono; usuário não invoca projeção para alterar fonte. IDs sem acesso retornam resposta não reveladora. Erros: 401/403/404/422/429 conforme API conventions.
