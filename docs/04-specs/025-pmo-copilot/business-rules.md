# SPEC-025 — PMO Copilot — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-025-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-025-02 — Invariant:** AI Context ≤ Authorized User Context; AI não é source of truth e não executa ação consequencial sem confirmação e reautorização.
- **BR-025-03 — Lifecycle:** CopilotInteraction só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-025-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-025-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-025-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-025-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
