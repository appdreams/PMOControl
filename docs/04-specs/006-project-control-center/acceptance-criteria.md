# SPEC-006 — Project Control Center — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-006-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project` e permission de view  
**When** consulta ProjectControlSummary  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-006-02 — operação principal

**Given** ProjectControlSummary válido e ator com grant necessário  
**When** executa `getControlCenter` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-006-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** É projeção derivada; comandos gravam nas fontes oficiais e toda seção respeita permission própria.

## AC-006-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-006-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-006-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** É projeção derivada; comandos gravam nas fontes oficiais e toda seção respeita permission própria.
