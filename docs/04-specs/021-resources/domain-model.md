# SPEC-021 — Resources — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`ResourceAllocation`

Campos de domínio: `tenant_id, project_id, person_id, role, skill, capacity, demand, allocation_percent, start_date, end_date, cost_rate, status`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Tenant/Project/Resource scope`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Dados sensíveis; disponibilidade/capacidade não equivale a permission de ver dados pessoais ou financeiros.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: listCapacity, allocateResource, updateAllocation, resolveConflict, deallocateResource. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
