# Environment Variables

**Status:** Approved

## Classes

Public browser-safe, server-only e secrets.

## Naming

Prefixos explícitos. Somente variáveis deliberadamente públicas podem
ser expostas ao browser.

## Regras

-   documentar nome/finalidade;
-   nunca documentar valor real;
-   validar presença/tipo;
-   separar por ambiente;
-   remover variáveis obsoletas.

## Secrets

Supabase service role, SMTP password e platform credentials são
server-only.
