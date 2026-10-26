# SPEC-025 — PMO Copilot — User Flows

**Status:** Draft — fluxos principais mapeados

## Consulta e execução principal

```text
Authenticate → Resolve active Tenant/Membership → Resolve Actor + authorized sources → Authorize operation
→ Load CopilotInteraction from source of truth → Validate input and linked resources
→ Execute domain command: askCopilot → Persist with expected_version
→ Append audit/domain event → Commit → Refresh authorized projection
```

## Fluxo de erro/concorrência

Se Tenant/scope não resolve, negar. Se campo/regra ou relação for inválida, retornar validation errors sem persistir. Se versão mudou, retornar conflito e exigir reload/merge; não sobrescrever silenciosamente. Se efeito derivado falhar após commit, preservar o estado oficial e reprocessar de forma idempotente.

## Configurar provider e acompanhar gastos

`Tenant Admin → ai.config.manage → write-only BYOK credential → validate provider/model access → set low/medium/high model mappings → save versioned config → review AI usage/cost with ai.cost.view → optionally export with ai.cost.export`.

Em cada pedido, o Gateway autoriza o ator e Tenant, aplica a regra determinística versionada, resolve a credencial e o modelo desse Tenant, chama provider e grava ledger de tokens/custo/estado de medição. Se qualquer etapa de credencial, autorização ou modelo falhar, não tenta credencial de outra empresa; devolve erro seguro e preserva os módulos não dependentes de IA.
