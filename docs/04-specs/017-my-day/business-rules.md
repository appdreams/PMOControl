# SPEC-017 — My Day — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-017-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-017-02 — Invariant:** Workspace agrega exceções de fontes oficiais autorizadas e não cria nem duplica tarefas.
- **BR-017-03 — Lifecycle:** MyDayItem só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-017-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-017-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-017-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-017-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
