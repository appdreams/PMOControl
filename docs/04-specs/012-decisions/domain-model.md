# SPEC-012 — Decisions — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Decision`

Campos de domínio: `tenant_id, project_id, subject, context, options, requested_by, decision_maker_id, due_date, status, outcome, impact, evidence_ids`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project/Decision`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Approve/Reject/Defer exige ator autorizado, prazo/contexto e histórico append-oriented.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createDecisionRequest, approveDecision, rejectDecision, deferDecision, commentDecision. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
