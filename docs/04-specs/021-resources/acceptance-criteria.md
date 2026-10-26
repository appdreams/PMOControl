# SPEC-021 — Resources — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-021-01 — consulta autorizada

**Given** ator com membership ativa, scope `Tenant/Project/Resource scope` e permission de view  
**When** consulta ResourceAllocation  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-021-02 — operação principal

**Given** ResourceAllocation válido e ator com grant necessário  
**When** executa `listCapacity` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-021-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Dados sensíveis; disponibilidade/capacidade não equivale a permission de ver dados pessoais ou financeiros.

## AC-021-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-021-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-021-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Dados sensíveis; disponibilidade/capacidade não equivale a permission de ver dados pessoais ou financeiros.
