# SPEC-019 — Portfolio Dashboard — API

**Status:** Draft — read contract

`GET /api/v1/portfolios/{portfolioId}/dashboard` retorna `PortfolioDashboardProjection` após autenticação, tenant resolution, scope/data policy e permission check. Queries: filtros allowlisted relevantes, cursor pagination quando coleção, `asOf`/`temporalMode` (`current|published`) quando aplicável. Campos: `temporal_mode, as_of, authorized_project_count, rag_distribution, delivery_metrics, budget_summary, critical_exceptions`.

Operações expostas: getPortfolioDashboard. Sem `POST/PATCH/DELETE` de domínio. Refresh é interno/assíncrono; usuário não invoca projeção para alterar fonte. IDs sem acesso retornam resposta não reveladora. Erros: 401/403/404/422/429 conforme API conventions.
