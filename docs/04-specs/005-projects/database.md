# SPEC-005 — Projects — Database

**Status:** Partial — schema e RPC/API de leitura/criação/edição/archive, associação temporal e troca do gerente aplicados no DEV e smoke-validated; assignments de membros pendentes

## Estado implementado

Migrations `20261027163212_portfolio_project_scope_foundation.sql` e `20261027163415_index_portfolio_project_foreign_keys.sql` criam `public.projects` e índices de suas FKs. A tabela não concede acesso direto via Data API: RLS está ativo, sem policies, e grants foram revogados de `PUBLIC`, `anon`, `authenticated` e `service_role`. As tabelas de baseline, forecast e assignments ainda não foram criadas.

`20261027181701_portfolio_project_read_create.sql` adiciona RPCs para listar Projects de uma associação ativa de Portfolio e criar Project sob `project.create` exato no Portfolio. A criação também grava a associação `portfolio_projects`, atribui o ator como gerente e concede `project_manager` somente no Project novo; audit e gravação são atômicos/idempotentes. A rota/UI usa `/api/v1/tenants/{tenantId}/projects`.

`20261027183256_update_archive_resources.sql` exige `project.edit` ou `project.archive` no Project exato, versão esperada, motivo e idempotency key; atualiza campos descritivos/priority e audit atomicamente. Archive define `archived_at` e incrementa a versão, sem substituir o status do workflow (`planning|execution|paused|completed|cancelled`). Lista só inclui Projects não arquivados e retorna capacidades de ação por grant.

`20261027184547_manage_portfolio_project_associations.sql` permite associar o Projeto existente a outro Portfolio same-Tenant ou encerrar somente um vínculo. A operação não altera nem apaga o Project nem muda grants; a associação anterior fica no histórico temporal.

`20261027191449_assign_project_manager.sql` implementa troca atômica do gerente em `project_manager_id`, papel de acesso e audit. Exige `project.assign` no Project exato, alvo com membership ativa no Tenant, versão esperada, motivo e idempotência; revoga concessões `project_manager` anteriores e cria/reusa a concessão do novo gerente. O endpoint de candidatos retorna apenas ID/nome mínimo de membros ativos, excluindo o gerente atual. A migration `20261027203631_prevent_noop_project_manager_assignment.sql` também rejeita atribuição do gerente atual, evitando incremento de versão e auditoria para uma operação sem mudança.

## Tabela lógica

`projects` owns identity, ownership, status, priority and mutable descriptive fields. `project_baselines` stores approved/versioned baseline commitments; `project_forecasts` stores forecast history/current forecast; actual dates/results remain observed execution facts. Do not duplicate baseline/forecast in project row. Related canonical tables: `project_assignments`, `portfolio_projects`. Same-tenant FKs required.

## Constraints

- Implementado em `projects`: `id, tenant_id, name, code, sponsor_id, project_manager_id, status, priority, scope_summary, start_date, target_end_date, archived_at, version, created_at, created_by, updated_at, updated_by`. Associação a Portfolio é somente via `portfolio_projects`; `portfolioId` é input lógico da API e materializa a associação na mesma transação de criação.
- Aplicado: PK UUID, `UNIQUE(tenant_id,id)`, código opcional único/normalizado por Tenant, sponsor/manager membership same-Tenant, nome/escopo com limites, estados documentados incluindo `cancelled`, prioridades `low|medium|high|critical`, intervalo de datas e versão positiva.
- Aplicados índices para listagem, manager, sponsor, código e lookups de FKs, inclusive atores de autoria. Tabelas de baseline, forecast e assignments ainda não existem.
- Baselines aprovadas são append-only; baseline corrente é uma referência à versão aprovada. Forecast/actual não atualiza baseline. `UNIQUE(tenant_id,project_id,baseline_version)` e índices por `(tenant_id,portfolio_id,status)` e `(tenant_id,project_manager_id,status)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Arquivamento preserva baseline, forecast e assignments históricos; hard delete apenas pelo workflow central de retenção. Aplicar as mesmas constraints em migration e testar baseline change como transação versionada.

## Exclusão administrativa definitiva

`project_purge_jobs(id UUID,tenant_id UUID,project_id UUID,requested_by UUID,reason TEXT,preview_version BIGINT,impact_summary JSONB,confirmation_digest TEXT,status TEXT,phase TEXT,retained_counts JSONB,deleted_counts JSONB,error_code TEXT NULL,idempotency_key TEXT,created_at/updated_at TIMESTAMPTZ,completed_at TIMESTAMPTZ NULL)` rastreia o purge; segredo de confirmação nunca é persistido em claro. `project_tombstones(id UUID,tenant_id UUID,project_id UUID,project_code TEXT,project_name TEXT,retention_until TIMESTAMPTZ NULL,purge_job_id UUID,created_at TIMESTAMPTZ)` mantém identidade mínima necessária às referências históricas, sem acesso operacional.

A operação marca o Project como não operacional antes de apagar dados e percorre tabelas filhas, storage privado, índices/projeções e jobs derivados em fases retomáveis. Dados elegíveis são removidos permanentemente; audit, publicações, snapshots, holds e evidências sob retenção são preservados com ownership e referências mínimas. Dependências fora do Project nunca são apagadas em cascata sem validação do módulo owner. O tombstone só pode ser eliminado depois que a última referência/hold e os prazos de retenção expirarem. FKs e policies não podem usar `ON DELETE CASCADE` para contornar essa regra.
