# Request & Response Model

**Status:** Approved

## Request

Requests de mutação devem conter apenas campos editáveis pelo ator
naquele contexto.

## Success envelope

Contratos podem retornar diretamente o resource ou envelope padronizado:

``` json
{
  "data": {},
  "meta": {}
}
```

## Collection

``` json
{
  "data": [],
  "pageInfo": {
    "nextCursor": null,
    "hasNextPage": false
  }
}
```

## Mutations

Retornar representação mínima suficiente para sincronizar UI, incluindo
versão/updatedAt quando concurrency for relevante.

## Sensitive fields

Nunca retornar secrets, hashes, raw credentials ou campos sem permissão.
