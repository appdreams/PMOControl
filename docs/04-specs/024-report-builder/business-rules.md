# SPEC-024 — Report Builder — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-024-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-024-02 — Invariant:** Relatório declara contexto temporal e aplica autorização/data policy na consulta e no download.
- **BR-024-03 — Lifecycle:** ReportJob só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-024-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-024-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-024-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-024-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
