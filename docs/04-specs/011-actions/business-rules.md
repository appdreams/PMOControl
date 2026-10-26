# SPEC-011 — Actions — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-011-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-011-02 — Invariant:** Ação derivada mantém source_type/source_id; conclusão exige 100%/data real segundo regra definida.
- **BR-011-03 — Lifecycle:** Action só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-011-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-011-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-011-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-011-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
