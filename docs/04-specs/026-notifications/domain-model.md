# SPEC-026 — Notifications — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Notification`

Campos de domínio: `tenant_id, recipient_id, event_id, type, channel, payload_minimized, status, attempts, next_attempt_at, delivered_at, dedupe_key`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Recipient/Tenant`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Notificação é pós-commit, minimizada e idempotente; falha nunca altera estado oficial.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: listInbox, markRead, updatePreferences, enqueueDelivery, retryDelivery. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
