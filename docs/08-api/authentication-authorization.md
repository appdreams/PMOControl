# API Authentication & Authorization

**Status:** Draft — align with SPEC-001/002/003 and trusted RLS context

## Pipeline obrigatório

1.  Authenticate.
2.  Resolve Tenant.
3.  Resolve Membership.
4.  Resolve Scope.
5.  Check Permission.
6.  Apply Data Policy.
7.  Apply Workflow Rule.
8.  Execute.

## Fórmula

`Effective Access = Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

## Proibições

-   confiar em `tenantId` enviado pelo cliente como autoridade;
-   autorizar somente porque resource UUID existe;
-   depender de controle oculto na UI;
-   usar service role como bypass genérico.

## AI

Endpoints de Copilot obedecem exatamente ao contexto autorizado do
usuário.
