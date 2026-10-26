# SPEC-018 — Project Dashboard — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-018-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project` e permission de view  
**When** consulta ProjectDashboardProjection  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-018-02 — operação principal

**Given** ProjectDashboardProjection válido e ator com grant necessário  
**When** executa `getProjectDashboard` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-018-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Projeção identifica Current vs Published e não permite edição direta dos fatos.

## AC-018-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-018-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-018-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Projeção identifica Current vs Published e não permite edição direta dos fatos.
