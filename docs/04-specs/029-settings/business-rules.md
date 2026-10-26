# SPEC-029 — Settings — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-029-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-029-02 — Invariant:** Configurações são tenant-scoped e tipadas; secrets nunca são retornados; mudanças sensíveis auditadas.
- **BR-029-03 — Lifecycle:** TenantSetting só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-029-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-029-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-029-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-029-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
