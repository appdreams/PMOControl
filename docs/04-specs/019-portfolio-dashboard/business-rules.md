# SPEC-019 — Portfolio Dashboard — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-019-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-019-02 — Invariant:** Agregação considera somente Projects autorizados; contagens não revelam projetos ocultos.
- **BR-019-03 — Lifecycle:** PortfolioDashboardProjection só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-019-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-019-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-019-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-019-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
