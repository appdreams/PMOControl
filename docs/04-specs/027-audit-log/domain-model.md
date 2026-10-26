# SPEC-027 — Audit Log — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`AuditEvent`

Campos de domínio: `tenant_id, actor_id, action, resource_type, resource_id, occurred_at, correlation_id, before_redacted, after_redacted, reason`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Tenant + audit permission`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Eventos append-only para usuários comuns; payload minimizado, sem secrets, com integridade e acesso restrito.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações: internal append from domain/outbox writer, queryAuditEvents and exportAuditEvidence. AuditEvent has no mutable lifecycle; a correction or redaction exception is represented by a new linked event under an authorized retention/privacy workflow.
