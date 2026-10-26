# SPEC-025 — PMO Copilot — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`CopilotInteraction`

Campos de domínio: `tenant_id, actor_id, question, authorized_scope, source_refs, fact_inference_recommendation, model_id, prompt_version, action_proposal_id`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

`TenantAIProviderConfig` guarda configuração isolada por Tenant: provider, secret-manager reference, três mapeamentos `low|medium|high`, versão e estado de validação. O segredo não pertence ao modelo de domínio e nunca é lido de volta pela aplicação cliente.

`AIUsageRecord` é o ledger append-only de cada tentativa: request/correlation, Tenant, provider/model, classe e versão da regra de roteamento, tokens/unidades reportados, referência/versão da tarifa, custo e qualidade da medição (`provider_reported|rate_estimated|unavailable`), status e timestamps. Não contém prompt, grounding ou segredo.

## Ownership e relações

Tenant-owned; scope primário: `Actor + authorized sources`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. AI Context ≤ Authorized User Context; AI não é source of truth e não executa ação consequencial sem confirmação e reautorização.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: askCopilot, getSources, proposeAction, confirmAction. Estado inicial, transições válidas e terminais devem ser enumerados na entidade; mutação em estado terminal é negada salvo comando de reabertura explicitamente autorizado.

Para cada solicitação, após autorização e antes da chamada externa, o Gateway aplica classificador determinístico versionado (use case/capacidade requerida, forma e profundidade de saída, volume/diversidade de fontes e análise multi-etapa) e persiste classe e motivos. A classe seleciona exclusivamente o modelo correspondente na configuração ativa do Tenant. Sem credencial/modelo compatível, falha de forma fechada; sem roteamento oculto para credencial da plataforma/outro Tenant.
