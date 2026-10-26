# Authentication Security

**Status:** Approved

## Identity

Supabase Auth autentica identidade e sessão. Autorização de negócio
pertence ao PMO Control.

## Requisitos

-   sessões seguras e revogáveis;
-   recuperação de conta segura;
-   proteção contra enumeration;
-   rate limiting em fluxos sensíveis;
-   MFA suportável/evolutivo;
-   reautenticação para operações altamente sensíveis quando aplicável;
-   logout/revogação efetivos;
-   eventos de segurança auditáveis.

## Regra

Usuário autenticado não implica usuário autorizado em Tenant, Portfolio,
Project ou Resource.
