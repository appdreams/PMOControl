# SPEC-004 — Portfolios — Database

**Status:** Partial — schema e RPC/API de leitura/criação/edição/archive/associação temporal aplicados e smoke-validated no DEV

## Estado implementado

Migrations `20261027163212_portfolio_project_scope_foundation.sql` e `20261027163415_index_portfolio_project_foreign_keys.sql` criam `public.portfolios` e `public.portfolio_projects`. Os grants de tabela foram revogados de `PUBLIC`, `anon`, `authenticated` e `service_role`; RLS está ativo sem policies por desenho até existir uma boundary de autorização. As tabelas não estão expostas para acesso direto via Data API.

`20261027181701_portfolio_project_read_create.sql` adiciona RPCs públicas `SECURITY INVOKER`, com implementação privilegiada no schema `private`, para listar e criar Portfolios. Listagem exige membership/Tenant ativos e filtra grants `portfolio.view` no Portfolio exato. Criação exige `portfolio.create` e `membership.grant` no Tenant; owner é o ator e recebe grant `pmo_admin` apenas no Portfolio criado. Recurso, grant e audit são transacionais e idempotentes. A rota/UI correspondente usa `/api/v1/tenants/{tenantId}/portfolios`.

`20261027183256_update_archive_resources.sql` exige `portfolio.edit` ou `portfolio.archive` no recurso exato, `expectedVersion`, motivo e idempotency key; incrementa versão e grava audit atômico. Archive define `status='archived'` e `archived_at`, preserva associações e falha enquanto houver Projects ativos. Lista retorna flags de capacidade já calculadas com deny precedence.

`20261027184547_manage_portfolio_project_associations.sql` adiciona associação/remocão temporal por RPC privada e wrappers públicos `SECURITY INVOKER`. Exige permission sensível no Portfolio e `project.view` exato no Projeto; remove com versão esperada, reason e idempotência, incrementando a versão e preservando histórico sem alterar/apagar o Projeto. Audit é atômico. O preset PMO Admin recebe as permissões de associação e remoção; usuários existentes recebem os permission links correspondentes.

## Tabela lógica

`portfolios(id UUID, tenant_id UUID, name TEXT, code TEXT, owner_id UUID, sponsor_id UUID NULL, category TEXT, status TEXT, start_date DATE NULL, target_end_date DATE NULL, archived_at TIMESTAMPTZ NULL, version BIGINT, created_at TIMESTAMPTZ, created_by UUID, updated_at TIMESTAMPTZ, updated_by UUID)`; relação com Projects permanece em `portfolio_projects`.

`portfolio_projects(id UUID,tenant_id UUID,portfolio_id UUID,project_id UUID,linked_at TIMESTAMPTZ,linked_by UUID,removed_at TIMESTAMPTZ NULL,removed_by UUID NULL,version BIGINT)` é uma associação temporal; remoção encerra a relação sem apagar o Project.

## Constraints

- Aplicado: PK UUID, `UNIQUE(tenant_id,id)`, código opcional normalizado e único por Tenant, membership same-Tenant para owner/sponsor, categoria/nome com limites, status `active|archived`, coerência de archive, intervalo de datas e versão positiva.
- Aplicado: `portfolio_projects` tem FKs compostas para Portfolio e Project no mesmo Tenant, autoria Auth, remoção temporal coerente e unicidade parcial de associação ativa.
- Aplicados índices para listagem, owner, sponsor, código e lookups de todas as FKs (incluindo atores de autoria/vínculo). Advisors não apontam FKs novas sem índice.
- A gestão independente exige permission do Portfolio e visibilidade exata do Projeto; o RPC lista somente alvos same-Tenant ativos e ainda não associados. Smoke DEV confirmou link/unlink, replay, versão stale e relink com rollback.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Arquivar define `archived_at` e mantém relações/histórico; remoção da associação não apaga Project. Hard delete segue o workflow central de retenção. Esta especificação lógica é a base de migration e requer revisão na implementação.
