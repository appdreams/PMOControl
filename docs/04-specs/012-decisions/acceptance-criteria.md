# SPEC-012 — Decisions — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-012-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project/Decision` e permission de view  
**When** consulta Decision  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-012-02 — operação principal

**Given** Decision válido e ator com grant necessário  
**When** executa `createDecisionRequest` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-012-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Approve/Reject/Defer exige ator autorizado, prazo/contexto e histórico append-oriented.

## AC-012-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-012-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-012-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Approve/Reject/Defer exige ator autorizado, prazo/contexto e histórico append-oriented.
