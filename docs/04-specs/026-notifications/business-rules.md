# SPEC-026 — Notifications — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-026-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-026-02 — Invariant:** Notificação é pós-commit, minimizada e idempotente; falha nunca altera estado oficial.
- **BR-026-03 — Lifecycle:** Notification só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-026-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-026-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-026-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-026-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
