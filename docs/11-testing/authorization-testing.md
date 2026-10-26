# Authorization Testing

**Status:** Draft — executable actor/scope matrix required

## Fórmula

`Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

## Cobertura

Testar View/Create/Edit/Delete/Approve/Publish/Export conforme cada
Spec.

## Sensíveis

financial, resources, confidential documents, status.update.publish,
baseline.change, projects.{projectId}.rag-evaluations.override, decision.approve, report.export.

## Regra

Testar backend; esconder botão não conta como autorização.
