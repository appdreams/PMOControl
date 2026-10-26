# SPEC-025 — Pmo Copilot — Events

**Status:** Draft — alinhado ao catálogo candidato do PDD

Eventos relevantes do PDD para este módulo: `AIRequestStarted`, `AIResponseGenerated`, `AIActionProposed`, `AIActionConfirmed`. Um evento só é emitido quando a mudança autoritativa correspondente ocorre; consultas/preview não emitem evento de domínio. Evento é escrito em outbox/transação quando necessário e consumido após commit, com idempotência e replay controlado.

Envelope mínimo: `event_id`, `event_type`, `tenant_id`, `resource_id`, `actor_id`, `occurred_at`, `correlation_id`, `payload_version`; payload contém IDs/version e delta allowlisted, sem secrets ou conteúdo excessivo. Audit Log permanece registro distinto.

Tenant AI config create/validate/rotate/disable emits `AIProviderConfigChanged` with actor, Tenant, provider, config version, action, result and correlation ID; secret and raw reference are excluded.

Each provider call writes append-only `AIUsageRecorded` metadata with Tenant/request, provider/model, class/router version, tokens/cost measurement status and outcome. Do not include prompt, grounding or credentials. Duplicate delivery is idempotent by request/attempt ID.
