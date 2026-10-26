# SPEC-008 — Deliverables — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-008-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project` e permission de view  
**When** consulta Deliverable  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-008-02 — operação principal

**Given** Deliverable válido e ator com grant necessário  
**When** executa `createDeliverable` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-008-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Delivered não equivale a Accepted quando aceite formal for exigido; evidência permanece vinculada.

## AC-008-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-008-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-008-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Delivered não equivale a Accepted quando aceite formal for exigido; evidência permanece vinculada.
