# PMO Control --- Security

**Status:** Draft — security contract re-audit in progress\
**Official path:** `/docs/07-security/README.md`

## Objetivo

Esta pasta define os controles de segurança do PMO Control,
complementando `security-architecture.md`, ADRs, Specs e políticas de
dados.

## Princípios

-   Security by Default
-   Least Privilege
-   Deny by Default
-   Defense in Depth
-   Tenant Isolation
-   Server-side Authorization
-   Auditability
-   Secure by Design
-   AI Does Not Expand Access

## Regra central

`Acesso efetivo = Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

O frontend nunca é a fronteira de segurança.
