# SPEC-008 — Deliverables — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Deliverable`

Campos de domínio: `tenant_id, project_id, milestone_id, name, owner_id, baseline_date, forecast_date, delivered_at, acceptance_status, accepted_at, progress, status`. Evidências são relações em `evidence_links`, não IDs serializados no registro. Campos de auditoria (`created_at`, `updated_at`, `created_by`, `updated_by`) ficam separados dos valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Delivered não equivale a Accepted quando aceite formal for exigido; evidência permanece vinculada.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createDeliverable, updateDeliverable, recordDelivery, acceptDeliverable, rejectAcceptance. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
