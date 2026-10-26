# SPEC-008 — Deliverables — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-008-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-008-02 — Invariant:** Delivered não equivale a Accepted quando aceite formal for exigido; evidência permanece vinculada.
- **BR-008-03 — Lifecycle:** Deliverable só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-008-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-008-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-008-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-008-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
