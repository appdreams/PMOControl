# SPEC-022 — Documents — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-022-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-022-02 — Invariant:** Binário privado; metadata no banco; download/upload sempre autorizado no servidor e classificação aplicada.
- **BR-022-03 — Lifecycle:** Document só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-022-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-022-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-022-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-022-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
