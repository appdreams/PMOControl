# SPEC-024 — Report Builder — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`ReportJob`

Campos de domínio: `tenant_id, requested_by, template_id, filters, temporal_mode, as_of, sections, format, status, artifact_key`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `User + authorized Tenant/Projects`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Relatório declara contexto temporal e aplica autorização/data policy na consulta e no download.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: listTemplates, previewReport, createReportJob, getReportJob, downloadReport. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.
