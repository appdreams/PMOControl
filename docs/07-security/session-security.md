# Session Security

**Status:** Draft — align claims/revocation contract with SPEC-001 before implementation

## Requisitos

-   cookies/tokens protegidos conforme arquitetura;
-   expiração e refresh controlados;
-   revogação após eventos críticos;
-   não armazenar secrets em local storage;
-   CSRF mitigado nos fluxos aplicáveis;
-   proteção contra session fixation;
-   sessão vinculada à identidade, não ao tenant escolhido pelo browser.

## Mudanças de acesso

Revogação de membership/role/scope deve surtir efeito sem depender
apenas de cache antigo.
