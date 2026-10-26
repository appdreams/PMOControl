# SPEC-005 — Projects — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`projects` owns identity, ownership, status, priority and mutable descriptive fields. `project_baselines` stores approved/versioned baseline commitments; `project_forecasts` stores forecast history/current forecast; actual dates/results remain observed execution facts. Do not duplicate baseline/forecast in project row. Related canonical tables: `project_assignments`, `portfolio_projects`. Same-tenant FKs required.

## Constraints

- `projects(id, tenant_id, name, code, sponsor_id, project_manager_id, status, priority, start_date, target_end_date, version, created_at, created_by, updated_at, updated_by)`; membership em portfólios é representada somente por `portfolio_projects` (o `portfolio_id` da API é input para criar essa associação). `project_baselines` guarda versões aprovadas (datas, scope, budget, version, approver/time); `project_forecasts` guarda previsões com `as_of`, fonte, ator e versão; `project_assignments` guarda sujeito/escopo/validade.
- PK UUID e `UNIQUE(tenant_id,id)`; todas as tabelas-filhas têm FKs compostas para ownership same-tenant. `UNIQUE(tenant_id,code)` para código não vazio.
- `CHECK(status IN ('planning','execution','paused','completed','cancelled'))` conforme PDD §49; arquivamento é `archived_at`, não um status substituto. `CHECK(priority IN ('low','medium','high','critical'))`; datas de término não antecedem início; versão ≥ 1.
- Baselines aprovadas são append-only; baseline corrente é uma referência à versão aprovada. Forecast/actual não atualiza baseline. `UNIQUE(tenant_id,project_id,baseline_version)` e índices por `(tenant_id,portfolio_id,status)` e `(tenant_id,project_manager_id,status)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Arquivamento preserva baseline, forecast e assignments históricos; hard delete apenas pelo workflow central de retenção. Aplicar as mesmas constraints em migration e testar baseline change como transação versionada.

## Exclusão administrativa definitiva

`project_purge_jobs(id UUID,tenant_id UUID,project_id UUID,requested_by UUID,reason TEXT,preview_version BIGINT,impact_summary JSONB,confirmation_digest TEXT,status TEXT,phase TEXT,retained_counts JSONB,deleted_counts JSONB,error_code TEXT NULL,idempotency_key TEXT,created_at/updated_at TIMESTAMPTZ,completed_at TIMESTAMPTZ NULL)` rastreia o purge; segredo de confirmação nunca é persistido em claro. `project_tombstones(id UUID,tenant_id UUID,project_id UUID,project_code TEXT,project_name TEXT,retention_until TIMESTAMPTZ NULL,purge_job_id UUID,created_at TIMESTAMPTZ)` mantém identidade mínima necessária às referências históricas, sem acesso operacional.

A operação marca o Project como não operacional antes de apagar dados e percorre tabelas filhas, storage privado, índices/projeções e jobs derivados em fases retomáveis. Dados elegíveis são removidos permanentemente; audit, publicações, snapshots, holds e evidências sob retenção são preservados com ownership e referências mínimas. Dependências fora do Project nunca são apagadas em cascata sem validação do módulo owner. O tombstone só pode ser eliminado depois que a última referência/hold e os prazos de retenção expirarem. FKs e policies não podem usar `ON DELETE CASCADE` para contornar essa regra.
