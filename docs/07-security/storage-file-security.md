# Storage & File Security

**Status:** Approved

## Princípios

Buckets privados por padrão.

## Upload

Validar tamanho, tipo permitido, metadata e autorização. Não confiar
apenas em extensão/MIME fornecido pelo cliente.

## Download

Usar autorização server-side e URLs temporárias/assinadas quando
aplicável.

## Documentos confidenciais

Exigem `documents.confidential.view` ou política equivalente.

## Evidências

Relacionamentos com Project/Deliverable/Action/Decision devem respeitar
tenant e scope.

## Segurança adicional

Malware scanning pode ser introduzido conforme risco/requisitos
operacionais.
