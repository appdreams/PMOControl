# SPEC-020 — Financial — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-020-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-020-02 — Invariant:** Dados Restricted; baseline aprovada não muda com forecast/actual; access financial.view/edit explícito.
- **BR-020-03 — Lifecycle:** ProjectFinancials só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-020-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-020-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-020-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-020-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
