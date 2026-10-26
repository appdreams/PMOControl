# SPEC-014 --- Status Update --- Domain Model

**Status:** Draft — monthly publication domain and lifecycle defined\
**Spec:** 014\
**Módulo:** Status Update\
**Arquivo:** `domain-model.md`

------------------------------------------------------------------------

## Entidades principais

- `StatusUpdate`: mutable monthly draft with `tenant_id`, `project_id`, `reporting_period`, Tenant-local `status_date`, `status`, `version`, executive summary and authorship timestamps.
- `StatusUpdateSection`: draft-only narrative/section content with source IDs/version/as-of; never owns or mutates source Risk/Milestone/Financial records.
- `StatusPublication`: immutable publication receipt with `status_update_id`, unique idempotency key, `kpi_rule_set_version`, `rag_rule_version_id`, published actor/time and optional successor/reason links.
- `Snapshot`: immutable `snapshot-v1`, owned by Spec 016 and one-to-one with publication.

## Ownership

`Tenant 1—N Project 1—N StatusUpdate 1—N StatusUpdateSection`; `StatusUpdate 1—0..1 StatusPublication`; `StatusPublication 1—1 Snapshot`. All tenant-owned links carry the same `tenant_id`; successor publication links to exactly one prior publication in the same Project.

## Invariantes

1. Uma única draft ativa por Project/mês; `reporting_period` é o primeiro dia do mês e `status_date` é o último dia no timezone do Tenant.
2. Publish valida versão do draft e de todas as fontes e grava Publication + `snapshot-v1` + audit/outbox atomicamente.
3. Status publicado/superseded, publicação e snapshot são imutáveis; correção cria sucessor com motivo e grant próprio.
4. KPI/RAG guardam rule versions e as-of; recalcular no futuro não reescreve o snapshot.
5. IDs, ownership e assignment não concedem acesso; tenant-owned links nunca cruzam Tenants.

## Lifecycle

`draft → published → superseded`; `draft → published` por `status.update.publish`; correção publica successor e marca referência anterior superseded sem alterar bytes/conteúdo publicado. `expected_version` stale retorna conflito. Não há delete de publication/snapshot pelo app.

## Temporalidade

Cada seção e indicador distingue `current state` de `published state` e carrega fonte, versão e instante de corte. Baseline, forecast e actual são valores distintos; fórmulas são `kpi-v1` e `rag-v1`.
