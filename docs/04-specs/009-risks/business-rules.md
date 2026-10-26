# SPEC-009 — Risks — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-009-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-009-02 — Invariant:** Risk representa evento futuro incerto; materialização cria/vincula Issue sem apagar histórico do Risk.
- **BR-009-03 — Lifecycle:** Risk só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-009-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-009-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-009-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-009-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
