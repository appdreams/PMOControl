# SPEC-018 — Project Dashboard — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-018-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-018-02 — Invariant:** Projeção identifica Current vs Published e não permite edição direta dos fatos.
- **BR-018-03 — Lifecycle:** ProjectDashboardProjection só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-018-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-018-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-018-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-018-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
