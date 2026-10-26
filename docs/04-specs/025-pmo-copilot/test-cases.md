# SPEC-025 — PMO Copilot — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-025-01:** Happy path de `askCopilot` com campos mínimos válidos e Tenant/scope corretos.
- **TC-025-02:** Cada operação relevante (askCopilot, getSources, proposeAction, confirmAction) verifica persistência e evento/audit esperado.
- **TC-025-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-025-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-025-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-025-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-025-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-025-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-025-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-025-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-025-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.
- **TC-025-11:** configurar provider BYOK e validar credencial; inspecionar persistência, resposta, logs, erros e audit para garantir que o segredo não vaza.
- **TC-025-12:** tentar usar/consultar/rotacionar credencial de outro Tenant, credencial inválida e provider desabilitado; deve negar/ falhar de forma fechada sem fallback cross-tenant.
- **TC-025-13:** validar roteamento determinístico para tarefas low/medium/high, guardando `router_rule_version`, motivo, classe e modelo selecionado.
- **TC-025-14:** mesma solicitação e mesma versão de regra/config devem produzir a mesma classe; mudança de configuração vale apenas para novos requests.
- **TC-025-15:** payload forjado com classe/modelo/provider é ignorado ou rejeitado; usuário não consegue aumentar custo escolhendo modelo de classe alta.
- **TC-025-16:** ingerir usage reportado pelo provider e validar tokens, moeda e custo vinculados ao Tenant/request/model.
- **TC-025-17:** tarifa local gera valor `rate_estimated`; ausência de usage/tarifa gera `unavailable` e null, nunca zero confirmado.
- **TC-025-18:** testar tela/filtros/export com períodos half-open, timezone do Tenant, agrupamentos e negativa de dados para usuário sem `ai.cost.view/export`.
- **TC-025-20:** validar que UI/API aceitam exatamente os seis providers MVP, rejeitam provider desconhecido, exigem endpoint aprovado para Meta Llama e não aceitam URLs arbitrárias; verificar credencial e model IDs isolados por provider/Tenant.
