# SPEC-007 — Milestones — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`milestones(id UUID, tenant_id UUID, project_id UUID, name TEXT, type TEXT, owner_id UUID NULL, baseline_date DATE NULL, forecast_date DATE NULL, actual_date DATE NULL, criticality TEXT NULL, status TEXT, progress NUMERIC(5,2), version BIGINT, created_at/updated_at TIMESTAMPTZ, created_by/updated_by UUID)`. Dependency edges are rows in `dependencies`, never a `dependency_ids` array.

## Constraints

- `milestones(id,tenant_id,project_id,name,type,owner_id,baseline_date,forecast_date,actual_date,criticality,status,progress,version,created_at,created_by,updated_at,updated_by)`; dependency edges pertencem à tabela canônica `dependencies`, não a array gravado em `dependency_ids`.
- PK UUID, `UNIQUE(tenant_id,id)`, FK composta para Project e owner no Tenant; `CHECK(progress BETWEEN 0 AND 100)` e `CHECK(status IN ('planned','in_progress','blocked','completed','cancelled'))` conforme PDD §49. `type` e `criticality` usam taxonomias allowlisted e customizáveis por Tenant. No provisionamento, criar como valores padrão iniciais `type`: `project_start`, `phase_gate`, `major_deliverable`, `review`, `project_end`, `other`; `criticality`: `low`, `medium`, `high`, `critical`. Manter o código estável e permitir renomear apenas o rótulo de exibição; novos códigos exigem configuração explícita e não podem quebrar registros existentes.
- Baseline date é imutável fora de baseline aprovado; forecast update não altera baseline; `actual_date` só é preenchida ao concluir. O comando de conclusão exige registrar progresso 100% e `actual_date`, ou retorna erro de validação.
- Índices `(tenant_id,project_id,status)`, `(tenant_id,project_id,baseline_date)` e `(tenant_id,owner_id,status)`; versão esperada para update concorrente.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Forecast e atualizações preservam histórico governado; arquivamento não apaga milestone vinculada a publicação/snapshot. Hard delete segue retenção central.
