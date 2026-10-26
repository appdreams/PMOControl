# SMTP / Email Integration

**Status:** Approved

## MVP

Usar SMTP existente/configurável para notificações de email.

## Configuração

Host, port, TLS mode, sender identity e credential reference.

## Segurança

Credentials nunca em client bundle/logs.

## Delivery

Assíncrona via Inngest quando apropriado.

## Falha

Falha de email não reverte publicação/status já confirmado.
