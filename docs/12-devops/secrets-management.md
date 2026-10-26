# Secrets Management

**Status:** Approved

## Fontes

Vercel/GitHub/Supabase/provider secret facilities conforme boundary.

## Regras

-   não versionar;
-   least privilege;
-   rotation;
-   environment isolation;
-   redaction em logs;
-   nunca retornar ao browser;
-   revogar após exposição.

## BYOK

Chaves de tenants seguem modelo próprio de proteção e não devem ser
colocadas como variáveis globais de ambiente.
