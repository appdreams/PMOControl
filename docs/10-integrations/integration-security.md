# Integration Security

**Status:** Approved

## Credentials

Tenant-scoped, encrypted/secret-managed, masked and rotatable.

## OAuth

Usar scopes mínimos e armazenar refresh tokens com proteção equivalente
a secrets.

## Egress

Enviar somente dados necessários.

## Inbound

Todo payload externo é untrusted.

## Audit

Connect/disconnect, credential rotation, scope changes e mutations
sensíveis são auditáveis.
