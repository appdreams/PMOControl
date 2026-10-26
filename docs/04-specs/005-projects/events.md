# SPEC-005 — Projects — Events

**Status:** Draft — alinhado ao catálogo candidato do PDD

Eventos relevantes do PDD para este módulo: `ProjectCreated`, `ProjectUpdated`, `ProjectArchived`, `BaselineChanged`, `ForecastChanged`. Um evento só é emitido quando a mudança autoritativa correspondente ocorre; consultas/preview não emitem evento de domínio. Evento é escrito em outbox/transação quando necessário e consumido após commit, com idempotência e replay controlado.

Envelope mínimo: `event_id`, `event_type`, `tenant_id`, `resource_id`, `actor_id`, `occurred_at`, `correlation_id`, `payload_version`; payload contém IDs/version e delta allowlisted, sem secrets ou conteúdo excessivo. Audit Log permanece registro distinto.

Eventos adicionais: `ProjectPurgeRequested`, `ProjectPurgeProgressed`, `ProjectPurgeBlocked`, `ProjectPurged`. Preview não emite evento. Solicitação, cada fase e resultado são auditados; payload contém job/project identity, estado, contagens e referências de retenção, nunca conteúdo apagado. Eventos e consumers são idempotentes; audit permanece append-only.
