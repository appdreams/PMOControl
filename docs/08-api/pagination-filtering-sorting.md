# Pagination, Filtering & Sorting

**Status:** Approved

## Pagination

Cursor-based para Audit, Notifications, Actions, Risks, Issues e
coleções potencialmente grandes.

## Filtering

Exemplos: - `projectId` - `status` - `ownerId` - `severity` -
`dueFrom` - `dueTo` - `updatedSince`

## Sorting

Allowlist por recurso. Default deve ser previsível.

## Limits

Definir limite máximo server-side; cliente não controla queries
ilimitadas.

## Tenant

Todos os filtros são aplicados dentro do contexto autorizado; filtros
nunca ampliam scope.
