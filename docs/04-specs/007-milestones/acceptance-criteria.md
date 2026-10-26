# SPEC-007 — Milestones — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-007-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project` e permission de view  
**When** consulta Milestone  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-007-02 — operação principal

**Given** Milestone válido e ator com grant necessário  
**When** executa `createMilestone` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-007-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Baseline Date, Forecast Date e Actual Date nunca se sobrescrevem entre si.

## AC-007-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-007-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-007-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Baseline Date, Forecast Date e Actual Date nunca se sobrescrevem entre si.
