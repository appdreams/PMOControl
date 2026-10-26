# SPEC-019 — Portfolio Dashboard — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-019-01 — consulta autorizada

**Given** ator com membership ativa, scope `Portfolio + authorized Projects` e permission de view  
**When** consulta PortfolioDashboardProjection  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-019-02 — operação principal

**Given** PortfolioDashboardProjection válido e ator com grant necessário  
**When** executa `getPortfolioDashboard` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-019-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Agregação considera somente Projects autorizados; contagens não revelam projetos ocultos.

## AC-019-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-019-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-019-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Agregação considera somente Projects autorizados; contagens não revelam projetos ocultos.
