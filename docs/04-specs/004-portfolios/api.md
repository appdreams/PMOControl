# SPEC-004 — Portfolios — API

**Status:** Partial — list/create/update/archive and temporal association workflows implemented and smoke-validated in DEV

## Resource lógico

Rotas implementadas: `/api/v1/tenants/{tenantId}/portfolios` e `/api/v1/tenants/{tenantId}/portfolios/{portfolioId}`. Scope: `Tenant; Portfolio`.

## Operações e schemas

Todos os bodies são JSON camelCase; não aceitam `tenantId`, actor IDs, version de grant ou campos calculados como autoridade. Resposta de recurso: `{data:{id,tenantId,...,version},meta:{requestId}}`.

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| List | `GET /api/v1/tenants/{tenantId}/portfolios` | tenant vem da rota; sem grants do cliente | `200` apenas Portfolios ativos com `portfolio.view` exato; `canCreate` calculado no servidor |
| Create | `POST /api/v1/tenants/{tenantId}/portfolios` | `name`, `code?`, `sponsorId?`, `category`, `startDate?`, `targetEndDate?`, `reason`, `idempotencyKey`; owner é o ator autenticado | `201` Portfolio ativo + versão 1, grant inicial `pmo_admin` limitado ao Portfolio e audit atômico |
| Update | `PATCH /api/v1/tenants/{tenantId}/portfolios/{portfolioId}` | `name?`, `code?`, `sponsorId?`, `category?`, `startDate?`, `targetEndDate?`, `expectedVersion`, `reason`, `idempotencyKey`; owner transfer fora desta operação | `200` resource + versão incrementada |
| Archive | `POST /api/v1/tenants/{tenantId}/portfolios/{portfolioId}/archive` | `reason`, `expectedVersion`, `idempotencyKey` | `200` archived resource; exige arquivar Projects ativos antes; associação histórica preservada |
| List associable Projects | `GET /api/v1/tenants/{tenantId}/portfolios/{portfolioId}/projects` | tenant e Portfolio na rota | `200` somente Projects ativos same-Tenant com `project.view` exato ainda não associados |
| Associate Project | `POST /api/v1/tenants/{tenantId}/portfolios/{portfolioId}/projects` | `projectId`, `reason`, `idempotencyKey` | `201` association; exige `portfolio.projects.associate` no Portfolio e `project.view` no Project |
| Remove association | `DELETE /api/v1/tenants/{tenantId}/portfolios/{portfolioId}/projects/{associationId}` | `expectedVersion`, `reason`, `idempotencyKey` | `200` vínculo temporal encerrado; não apaga nem altera o Project |

As listas calculam `canAssociate` e `canRemoveAssociation` no servidor. Grants: `portfolio.create|view|edit|archive` e `portfolio.projects.associate|remove`, sempre no Tenant/Portfolio scope; alvo também requer `project.view` exato. Remoção é versionada e auditada, não altera grants do Projeto e conserva a linha histórica do vínculo.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; lista inicial ainda sem paginação; campos desconhecidos são rejeitados. Cada operação revalida membership/grant server-side. Update/archive usam versão esperada, motivo e chave idempotente.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.
