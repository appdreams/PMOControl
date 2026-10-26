# SPEC-024 — Report Builder — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-024-01 — consulta autorizada

**Given** ator com membership ativa, scope `User + authorized Tenant/Projects` e permission de view  
**When** consulta ReportJob  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-024-02 — operação principal

**Given** ReportJob válido e ator com grant necessário  
**When** executa `listTemplates` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-024-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Relatório declara contexto temporal e aplica autorização/data policy na consulta e no download.

## AC-024-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-024-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-024-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Relatório declara contexto temporal e aplica autorização/data policy na consulta e no download.
