# SPEC-017 — My Day — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-017-01 — consulta autorizada

**Given** ator com membership ativa, scope `Actor + authorized Projects` e permission de view  
**When** consulta MyDayItem  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-017-02 — operação principal

**Given** MyDayItem válido e ator com grant necessário  
**When** executa `getMyDay` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-017-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Workspace agrega exceções de fontes oficiais autorizadas e não cria nem duplica tarefas.

## AC-017-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-017-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-017-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Workspace agrega exceções de fontes oficiais autorizadas e não cria nem duplica tarefas.
