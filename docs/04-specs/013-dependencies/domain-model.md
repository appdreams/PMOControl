# SPEC-013 — Dependencies — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Dependency`

Campos de domínio: `tenant_id, source_type, source_id, target_type, target_id, dependency_type, owner_id, criticality, due_date, status, impact, lag_days`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project and linked resource`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Origem e destino devem estar no mesmo Tenant; ciclos e dependências inválidas são rejeitados ou explicitamente sinalizados.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createDependency, updateDependency, resolveDependency, listImpactedItems. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
