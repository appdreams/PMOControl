# SPEC-004 — Portfolios — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-004-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-004-02 — Invariant:** Project associado deve pertencer ao mesmo Tenant; projeções derivam dos Projects autorizados.
- **BR-004-03 — Lifecycle:** Portfolio só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-004-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-004-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-004-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-004-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
