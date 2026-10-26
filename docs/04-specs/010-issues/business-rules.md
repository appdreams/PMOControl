# SPEC-010 — Issues — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-010-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-010-02 — Invariant:** Issue representa problema ocorrido; priority segue a escala do PDD, blocker é explícito, aging deriva de datas e não é persistido como valor mutável.
- **BR-010-03 — Lifecycle:** Issue só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-010-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-010-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-010-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-010-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
