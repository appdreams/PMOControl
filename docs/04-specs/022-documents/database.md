# SPEC-022 — Documents — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`documents(id UUID,tenant_id UUID,project_id UUID,storage_key TEXT UNIQUE,filename TEXT,mime_type TEXT,size_bytes BIGINT,classification TEXT,status TEXT,current_version_id UUID,uploaded_by UUID,created_at/updated_at TIMESTAMPTZ,version BIGINT)` stores metadata only.

`document_versions(id UUID,tenant_id UUID,document_id UUID,storage_key TEXT,checksum_sha256 CHAR(64),size_bytes BIGINT,mime_type TEXT,uploaded_by UUID,created_at TIMESTAMPTZ)` is append-only. `evidence_links(id UUID,tenant_id UUID,document_id UUID,resource_type TEXT,resource_id UUID,linked_by UUID,created_at TIMESTAMPTZ)` relates evidence to governed entities. Binary stays in private storage under opaque keys.

## Constraints

- Composite FKs require same Tenant/Project for documents, versions and linked resources; `size_bytes > 0`; filename is normalized and bounded; MIME type must be allowlisted and verified against content on upload.
- Classification is `standard|internal|confidential|restricted`; restricted classes require distinct grants. `storage_key` is opaque, unique and never supplied by a client as a storage path.
- `checksum_sha256` is computed server-side. Version rows and evidence links cannot be updated to point cross-tenant; delete is restricted to retention/purge procedure.
- Indexes `(tenant_id,project_id,classification,status)`, `(tenant_id,document_id,created_at DESC)` and `(tenant_id,resource_type,resource_id)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Binary and metadata deletion are coordinated by an idempotent retention job; version history is preserved until retention permits purge.
