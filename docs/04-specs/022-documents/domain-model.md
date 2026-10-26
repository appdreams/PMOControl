# SPEC-022 — Documents — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Document`

Campos de domínio: `tenant_id, project_id, storage_key, filename, mime_type, size_bytes, classification, version, checksum, uploaded_by, linked_entity_type, linked_entity_id`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project + Document classification`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Binário privado; metadata no banco; download/upload sempre autorizado no servidor e classificação aplicada.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: uploadDocument, getMetadata, downloadDocument, createVersion, linkEvidence, archiveDocument. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
