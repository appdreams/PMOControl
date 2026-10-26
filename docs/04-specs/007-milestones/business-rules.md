# SPEC-007 — Milestones — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-007-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-007-02 — Invariant:** Baseline Date, Forecast Date e Actual Date nunca se sobrescrevem entre si.
- **BR-007-03 — Lifecycle:** Milestone só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-007-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-007-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-007-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-007-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
