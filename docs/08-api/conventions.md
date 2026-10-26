# API Conventions

**Status:** Approved

## Formato

JSON UTF-8.

## Naming

-   URLs: lowercase/kebab-case.
-   JSON fields: camelCase na interface HTTP.
-   IDs: UUID.
-   Datas: ISO 8601.
-   Timestamps: UTC.
-   Currency: código ISO + decimal fixo.

## Resources

Preferir substantivos: `/projects`, `/risks`, `/status-updates`.

Ações de domínio explícitas podem usar: `/status-updates/{id}/publish`
`/decisions/{id}/approve`

## Pagination

Cursor pagination preferencial para coleções grandes; page/limit somente
quando adequado.

## Filtering

Filtros explícitos e allowlisted. Não aceitar nomes arbitrários de
colunas SQL.

## Sorting

Campos permitidos declarados por endpoint.
