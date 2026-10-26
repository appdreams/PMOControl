# SPEC-004 — Portfolios — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Portfolio`

Campos de domínio: `tenant_id, name, code, owner_id, sponsor_id, category, status, start_date, target_end_date, archived_at`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Tenant; Portfolio`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Project associado deve pertencer ao mesmo Tenant; projeções derivam dos Projects autorizados.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createPortfolio, updatePortfolio, archivePortfolio, associateProject, removeProject. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
