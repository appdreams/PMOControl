# SPEC-021 — Resources — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-021-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-021-02 — Invariant:** Dados sensíveis; disponibilidade/capacidade não equivale a permission de ver dados pessoais ou financeiros.
- **BR-021-03 — Lifecycle:** ResourceAllocation só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-021-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-021-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-021-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-021-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
