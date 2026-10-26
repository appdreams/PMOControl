# SPEC-023 — Time Machine — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-023-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-023-02 — Invariant:** Visão histórica deriva somente de snapshots publicados, nunca do estado atual retroprojetado.
- **BR-023-03 — Lifecycle:** SnapshotComparison só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-023-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-023-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-023-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-023-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
