# SPEC-028 — Import & Export — User Flows

**Status:** Draft — fluxos principais mapeados

## Consulta e execução principal

```text
Authenticate → Resolve active Tenant/Membership → Resolve Tenant + authorized entities/fields → Authorize operation
→ Load DataJob from source of truth → Validate input and linked resources
→ Execute domain command: createImportJob → Persist with expected_version
→ Append audit/domain event → Commit → Refresh authorized projection
```

## Fluxo de erro/concorrência

Se Tenant/scope não resolve, negar. Se campo/regra ou relação for inválida, retornar validation errors sem persistir. Se versão mudou, retornar conflito e exigir reload/merge; não sobrescrever silenciosamente. Se efeito derivado falhar após commit, preservar o estado oficial e reprocessar de forma idempotente.

## Importar dados de um projeto

`Authenticate → Resolve active Tenant/Membership → List authorized active Projects → Select target Project → Download blank template or synthetic complete example → Upload .xlsx → Malware scan → Validate schema/relations → Preview`

Se o escopo de dados v1 está vazio, importar após preview válido sem pergunta de modo. Se há registros ativos, mostrar contagem e exigir seleção: append (só novas chaves) ou replace (grant específico, motivo e confirmação digitada). No replace, bloquear o Project por versão, revalidar grants e dependências, arquivar dados v1 antigos, inserir o dataset novo e escrever audit/event na mesma transação. Falha faz rollback integral. Publicações, snapshots, audit e legal holds são preservados.
