# SPEC-005 — Projects — User Flows

**Status:** Draft — fluxos principais mapeados

## Consulta e execução principal

```text
Authenticate → Resolve active Tenant/Membership → Resolve Tenant/Portfolio/Project → Authorize operation
→ Load Project from source of truth → Validate input and linked resources
→ Execute domain command: createProject → Persist with expected_version
→ Append audit/domain event → Commit → Refresh authorized projection
```

## Fluxo de erro/concorrência

Se Tenant/scope não resolve, negar. Se campo/regra ou relação for inválida, retornar validation errors sem persistir. Se versão mudou, retornar conflito e exigir reload/merge; não sobrescrever silenciosamente. Se efeito derivado falhar após commit, preservar o estado oficial e reprocessar de forma idempotente.

## Exclusão administrativa definitiva

`Platform Root Admin → administração de Projects (metadados mínimos) → preview do impacto → revisar identidade, contagens, histórico retido e bloqueios → informar motivo e confirmar código do Project → servidor revalida grant/hold/retenção e cria purge job idempotente → bloquear novas operações → preservar histórico/tombstone → purgar dados operacionais elegíveis em lotes → auditar cada fase → concluir ou reportar itens retidos/bloqueados.`

O job pode ser retomado após falha. Repetir o mesmo comando não duplica purge. Sem confirmação, grant, motivo ou preview atual, nenhuma escrita é iniciada.
