# SPEC-013 — Dependencies — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-013-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-013-02 — Invariant:** Origem e destino devem estar no mesmo Tenant; ciclos e dependências inválidas são rejeitados ou explicitamente sinalizados.
- **BR-013-03 — Lifecycle:** Dependency só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-013-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-013-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-013-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-013-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
