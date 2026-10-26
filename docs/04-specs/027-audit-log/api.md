# SPEC-027 — Audit Log — API

**Status:** Draft — query contract; writer contract e retention alinhados

## Write path interno

Audit events são anexados por domínio/transactional outbox; não existe API CRUD pública para criar/editar/apagar evento. Event ingestion valida actor/context, tenant, schema version, redaction e deduplication key. Commit do evento acompanha operação sensível quando audit é requisito de atomicidade.

## Query

`GET /api/v1/audit-events` requer `audit.view` e filtros allowlisted por tenant, resource type/id, actor, action e intervalo. `GET /api/v1/audit-events/{eventId}` retorna somente payload redigido autorizado. Export exige `audit.export` e data policy.

Query response fields: `{event_id, tenant_id, actor_id, action, resource_type, resource_id, occurred_at, correlation_id, schema_version, before_redacted, after_redacted, reason}` subject to field policy. List query uses cursor and limit 1–100. Public API exposes no append/update/delete route; domain writer accepts only server-authenticated actor/context, schema version and allowlisted redacted delta.

Usuário comum não atualiza nem remove eventos. Respostas não incluem secrets; retenção segue `docs/06-data/retention-archival.md`. Queries são paginadas e auditáveis.
