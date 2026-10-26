# SPEC-029 — Settings — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`TenantSetting`

Campos de domínio: `tenant_id, key, value_schema_version, value_redacted, updated_by, updated_at`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Tenant + settings permission`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Configurações são tenant-scoped e tipadas; secrets nunca são retornados; mudanças sensíveis auditadas.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: getSettings, updateSetting, resetSetting, rotateSecretReference. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
