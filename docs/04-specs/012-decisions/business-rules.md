# SPEC-012 — Decisions — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-012-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-012-02 — Invariant:** Approve/Reject/Defer exige ator autorizado, prazo/contexto e histórico append-oriented.
- **BR-012-03 — Lifecycle:** Decision só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-012-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-012-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-012-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-012-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
