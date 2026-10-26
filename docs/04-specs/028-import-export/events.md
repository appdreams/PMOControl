# SPEC-028 — Import Export — Events

**Status:** Draft — alinhado ao catálogo candidato do PDD

Eventos relevantes do PDD para este módulo: `ImportStarted`, `ImportValidated`, `ImportApplied`, `ProjectDataImportReplaced`, `ImportFailed`, `ExportGenerated`. Um evento só é emitido quando a mudança autoritativa correspondente ocorre; consultas/preview não emitem evento de domínio. Evento é escrito em outbox/transação quando necessário e consumido após commit, com idempotência e replay controlado.

Envelope mínimo: `event_id`, `event_type`, `tenant_id`, `resource_id`, `actor_id`, `occurred_at`, `correlation_id`, `payload_version`; payload contém IDs/version e delta allowlisted, sem secrets ou conteúdo excessivo. Audit Log permanece registro distinto.

Project import events include `target_project_id`, job, template version, import mode, source checksum, counts, actor and result; never include workbook cell contents. `ProjectDataImportReplaced` is emitted only after the atomic replacement commits and carries archived/new record counts plus the audit reference.
