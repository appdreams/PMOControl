# SPEC-014 — Status Update — Acceptance Criteria

**Status:** Draft — defaults mensais/KPI-v1 definidos; revisão transversal pendente  
**Spec:** 014

## AC-014-01 — publicação autorizada e válida

**Given** um rascunho do Project do Tenant ativo, com versão atual e checklist válido  
**And** o ator tem `status.update.publish` no Project scope  
**When** publica com `expected_version` e idempotency key  
**Then** o servidor revalida Tenant, membership, permission, estado e versão  
**And** grava estado publicado, Publication, Snapshot imutável e outbox/audit no mesmo commit.

## AC-014-02 — falha antes do commit

**Given** uma falha durante validação, cálculo ou gravação autoritativa  
**When** o comando publish termina  
**Then** não existe Publication nem Snapshot parcial  
**And** o rascunho permanece editável no estado anterior.

## AC-014-03 — idempotência

**Given** publicação aceita para idempotency key K e payload P  
**When** a mesma operação K/P é repetida  
**Then** retorna a publicação original sem criar novo snapshot  
**And** K com payload diferente resulta em conflito.

## AC-014-04 — concorrência e estado imutável

**Given** outra alteração avançou a versão do rascunho ou ele já foi publicado  
**When** uma versão antiga tenta publicar ou editar  
**Then** a mutação é recusada como conflito  
**And** snapshots publicados anteriores permanecem inalterados.

## AC-014-05 — pós-commit

**Given** publicação autoritativa confirmada e job de projeção/notificação indisponível  
**When** o job é repetido  
**Then** a publicação continua válida e histórica  
**And** o consumidor pode repetir sem duplicar efeitos de negócio.

## AC-014-06 — isolamento

**Given** o status ou Project pertence a outro Tenant  
**When** o ator manipula ID, payload, filtro ou chave de repetição  
**Then** operação é negada sem revelar o recurso e sem gravar evento cross-tenant.

## Pendências para aprovação da Spec

Definir schema versionado do snapshot, algoritmo/versionamento de KPI e RAG, campos obrigatórios e data de referência. Aprovação separada não é exigida no workflow MVP; correção segue permission `status.update.correct`, justificativa e publicação sucessora.


## AC-014-07 — publicação direta no padrão MVP

**Given** Project Manager com `status.update.publish` explicitamente concedida e rascunho válido  
**When** publica  
**Then** publicação é permitida sem aprovação separada no fluxo padrão.

## AC-014-08 — correção imutável

**Given** status publicado com erro e solicitante com `status.update.correct`  
**When** informa motivo e submete correção  
**Then** o sistema cria publicação sucessora ligada à anterior  
**And** snapshot e audit anteriores permanecem imutáveis.


## AC-014-09 — draft por período

**Given** Project ativo e reporting date dentro do ciclo permitido  
**When** Project Manager autorizado cria draft  
**Then** draft fica ligado ao Project/Tenant e período  
**And** draft duplicado para o ciclo é rejeitado ou reabre o existente conforme regra de ciclo.

## AC-014-10 — consolidação de fontes e validação

**Given** fontes operacionais autorizadas com versões/as-of identificáveis  
**When** draft carrega ou valida dados  
**Then** origem e timestamp são apresentados  
**And** blockers impedem publicação enquanto warnings são exibidos separadamente.

## AC-014-11 — cadência mensal e checklist

**Given** Project ativo e ciclo mensal `YYYY-MM`  
**When** cria ou publica status  
**Then** existe no máximo um draft ativo, a data de corte é o último dia do mês no timezone do Tenant e a publicação valida resumo, progresso, responsável, N/A justificado e resposta para riscos Red.

## AC-014-12 — KPI-v1 reproduzível

**Given** mesmas fontes autorizadas, baseline/forecast e versão `kpi-v1`  
**When** cálculo é executado para o mesmo corte  
**Then** progresso, variação de prazo, custo e entregas no prazo coincidem com as fórmulas da Spec 014; denominador ausente retorna N/A com motivo, nunca valor inventado.
