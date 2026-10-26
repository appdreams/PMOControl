# SPEC-021 — Resources — User Flows

**Status:** Draft — fluxos principais mapeados

## Consulta e execução principal

```text
Authenticate → Resolve active Tenant/Membership → Resolve Tenant/Project/Resource scope → Authorize operation
→ Load ResourceAllocation from source of truth → Validate input and linked resources
→ Execute domain command: listCapacity → Persist with expected_version
→ Append audit/domain event → Commit → Refresh authorized projection
```

## Fluxo de erro/concorrência

Se Tenant/scope não resolve, negar. Se campo/regra ou relação for inválida, retornar validation errors sem persistir. Se versão mudou, retornar conflito e exigir reload/merge; não sobrescrever silenciosamente. Se efeito derivado falhar após commit, preservar o estado oficial e reprocessar de forma idempotente.
