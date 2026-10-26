# Model Routing

**Status:** Approved

## Objetivo

Usar o modelo adequado por ação, equilibrando qualidade, latência e
custo.

## Classes sugeridas

-   Fast/Low Cost: classificação, extração, reformatação.
-   Balanced: Q&A, resumos, análise operacional.
-   Reasoning/High Capability: análise complexa, cenários e preparação
    executiva crítica.

## Routing

Pode considerar use case, tenant policy, provider availability, model
capability, sensitivity, token budget e SLA.

## Regra

Model routing é configuração de plataforma/tenant; não deve ficar
hardcoded em cada feature.

## Roteamento MVP por Tenant

Para cada provider configurado pelo Tenant, existem três mappings obrigatórios: baixa (`low`), média (`medium`) e alta (`high`). O classificador local e determinístico recebe metadados do use case/contexto (tipo de tarefa e saída, volume/diversidade de fontes autorizadas, necessidade de múltiplas etapas/cenários e orçamento de contexto); não chama LLM para classificar. A tabela de decisão e versão da regra são mantidas no Gateway e observáveis no request. A classe calculada escolhe o mapping do Tenant. O usuário/cliente não envia classe/modelo como autoridade; campo forjado é descartado/rejeitado. Sensibilidade, autorização, limites e capacidade de modelo podem rebaixar ou negar a rota, nunca elevá-la contra a regra de custo sem política explícita.

| Classe automática | Regra determinística inicial |
|---|---|
| `low` | Extração/reformatação/classificação, resposta objetiva sobre uma fonte ou tarefa curta de uma etapa; contexto autorizado pequeno e sem comparação/cenários. |
| `medium` | Resumo/análise operacional, combinação/comparação de fontes limitadas (até 20 itens de origem), elaboração estruturada ou síntese com mais de uma etapa simples. |
| `high` | Cenários/what-if, análise executiva crítica, síntese multi-projeto/portfólio, cadeias de dependência ou análise multi-etapa com grande diversidade de fontes. |

Avaliação determinística usa precedência `high > medium > low`: se qualquer critério high ocorre, seleciona high; caso contrário qualquer critério medium seleciona medium; só cai em low quando todos os critérios são low. Limites numéricos e catálogo de use cases são parte da versão `complexity-router-v1` e versionados antes de alteração. Conteúdo do prompt não controla role, Tenant, permission, limite ou classe; a regra usa classificação de tarefa e metadados já autorizados. Inputs incompletos/ambíguos sobem no máximo para medium, não para high sem critério explícito. A escolha não é editável pelo usuário.

Quando provider/model mapping falha, Gateway não troca para outra chave/provider implicitamente. A chamada falha de forma segura e os recursos centrais não dependentes de IA continuam disponíveis. A classe, versão da regra, modelo escolhido e reason code são persistidos no ledger sem armazenar prompt/grounding.
