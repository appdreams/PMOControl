# SPEC-009 — Risks — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-009-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project` e permission de view  
**When** consulta Risk  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-009-02 — operação principal

**Given** Risk válido e ator com grant necessário  
**When** executa `createRisk` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-009-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Risk representa evento futuro incerto; materialização cria/vincula Issue sem apagar histórico do Risk.

## AC-009-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-009-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-009-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Risk representa evento futuro incerto; materialização cria/vincula Issue sem apagar histórico do Risk.
