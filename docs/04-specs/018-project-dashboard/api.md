# SPEC-018 — Project Dashboard — API

**Status:** Draft — read contract

`GET /api/v1/projects/{projectId}/dashboard` retorna `ProjectDashboardProjection` após autenticação, tenant resolution, scope/data policy e permission check. Queries: filtros allowlisted relevantes, cursor pagination quando coleção, `asOf`/`temporalMode` (`current|published`) quando aplicável. Campos: `temporal_mode, as_of, current_progress, published_progress, rag, forecast, budget_summary, milestone_summary, risk_summary, issue_summary`.

Operações expostas: getProjectDashboard. Sem `POST/PATCH/DELETE` de domínio. Refresh é interno/assíncrono; usuário não invoca projeção para alterar fonte. IDs sem acesso retornam resposta não reveladora. Erros: 401/403/404/422/429 conforme API conventions.
