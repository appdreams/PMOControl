# API Versioning

**Status:** Approved

## APIs públicas

Usar versionamento explícito, inicialmente `/api/v1`.

## APIs internas

Podem evoluir junto ao frontend quando não constituírem contrato
externo, mantendo compatibilidade dentro do deployment.

## Breaking change

Inclui remoção/renomeação de campo, mudança semântica incompatível,
alteração de enum ou comportamento de autorização contratado.

## Deprecation

Contrato público deve possuir janela de depreciação antes de remoção
quando aplicável.
