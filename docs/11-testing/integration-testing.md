# Integration Testing

**Status:** Approved

## Dependências

Supabase/PostgreSQL/Auth/Storage, Inngest, SMTP e providers externos
simulados/sandbox.

## Casos

Timeout, rate limit, invalid credential, duplicate event, partial
provider outage e malformed response.

## Regra

Falha externa não corrompe estado oficial.
