# SPEC-028 — Import & Export — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`DataJob`

Campos de domínio: `tenant_id, actor_id, direction, entity_type, source_file_key, mapping_version, row_count, validation_summary, status, idempotency_key, artifact_key`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

Para importação de projeto, `DataJob` inclui `target_project_id`, `template_version`, `import_mode` (`initial|append|replace`), `source_checksum`, `target_project_version`, contagens detectadas e resultado de aplicação. Alvo é sempre o Project escolhido no UI e revalidado no servidor.

## Ownership e relações

Tenant-owned; scope primário: `Tenant + authorized entities/fields`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Generic import follows staging→validate→preview→confirm→apply; Project XLSX v1 follows its initial-load or explicit append/replace mode; exports revalidate permission/data policy per field and row.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: createImportJob, mapColumns, validateImport, previewImport, confirmImport, createExportJob, downloadExport. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.

Fluxo project import: escolher projeto tenant-scoped → baixar template vazio ou exemplo → upload → validar/preview. Escopo vazio segue carga inicial sem prompt de modo. Escopo com dados requer append ou replace. Append é insert-only com `external_key` estável; replace arquiva o dataset v1 atual e insere o novo em operação atômica, preservando Project identity e história imutável.
