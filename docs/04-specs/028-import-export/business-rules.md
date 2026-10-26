# SPEC-028 — Import & Export — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-028-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-028-02 — Invariant:** generic imports follow staging→validate→preview→confirm→apply; project XLSX v1 uses the empty-scope initial-load path or explicit append/replace path defined in BR-028-10–13; exports revalidate permission/data policy per field and row.
- **BR-028-03 — Lifecycle:** DataJob só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-028-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-028-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-028-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-028-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
- **BR-028-08 — Project scope:** Project options and imports resolve from the verified Tenant and the user's Project scope; workbook target values are guards, not authorization.
- **BR-028-09 — Official workbook:** blank and synthetic sample workbooks use the same strict, versioned schema in `project-import-template-v1.md`.
- **BR-028-10 — Initial load:** if the v1 operational scope is empty, do not ask append/restart mode; apply only after upload, clean validation and preview.
- **BR-028-11 — Add data:** insert-only by stable external key; duplicates block before commit and existing entities are never silently overwritten.
- **BR-028-12 — Restart:** requires elevated replace grant, reason, impact counts and typed confirmation; archives active v1 records and inserts the replacement atomically, preserving immutable and held history.
- **BR-028-13 — Atomicity:** staging never mutates source entities; any validation/commit error leaves the prior active dataset intact.
- **BR-028-08 — Tenant/Project scope:** Project choices and imports are resolved from verified active Tenant context; the workbook cannot choose or elevate the target.
- **BR-028-09 — Templates:** blank/sample workbooks share strict schema/version; the sample is complete for the supported v1 import scope and synthetic only.
- **BR-028-10 — Initial load:** empty v1 scope skips append/restart choice and proceeds after successful validation/preview.
- **BR-028-11 — Append:** add-only; duplicate external keys reject the import and no existing record is overwritten.
- **BR-028-12 — Restart:** explicit elevated grant + typed confirmation; archive prior in-scope current data and atomically create new current data, preserving immutable publications, snapshots, audit and holds.
- **BR-028-13 — Atomicity:** apply is all-or-nothing; staging never mutates source entities.
