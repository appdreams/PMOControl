# SPEC-006 — Project Control Center — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-006-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-006-02 — Invariant:** É projeção derivada; comandos gravam nas fontes oficiais e toda seção respeita permission própria.
- **BR-006-03 — Lifecycle:** ProjectControlSummary só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-006-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-006-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-006-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-006-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
