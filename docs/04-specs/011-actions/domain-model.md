# SPEC-011 — Actions — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Action`

Campos de domínio: `tenant_id, project_id, source_type, source_id, title, owner_id, priority, start_date, due_date, completed_at, progress, status`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Ação derivada mantém source_type/source_id; conclusão exige 100%/data real segundo regra definida.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createAction, updateAction, reassignAction, completeAction, cancelAction. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
