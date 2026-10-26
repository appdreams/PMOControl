# Authorization Security

**Status:** Draft — aligned with Spec 003 authorization contract; re-audit pending

## Modelo

`Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

## Regras

-   deny by default;
-   autorização centralizada no backend;
-   cada command/query resolve tenant e scope;
-   IDs nunca concedem acesso;
-   permissões sensíveis explícitas;
-   segregação de funções configurável;
-   acesso revalidado no momento de ações consequenciais.

## Permissões sensíveis

`financial.view`, `financial.edit`, `resources.view`, `resources.edit`,
`documents.confidential.view`, `status.update.publish`, `baseline.change`,
`projects.{projectId}.rag-evaluations.override`, `decision.approve`, `report.export`.

## AI

Copilot e agentes herdam exatamente o contexto autorizado do usuário.
