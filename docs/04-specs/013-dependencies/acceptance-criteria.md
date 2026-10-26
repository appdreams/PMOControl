# SPEC-013 — Dependencies — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-013-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project and linked resource` e permission de view  
**When** consulta Dependency  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-013-02 — operação principal

**Given** Dependency válido e ator com grant necessário  
**When** executa `createDependency` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-013-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Origem e destino devem estar no mesmo Tenant; ciclos e dependências inválidas são rejeitados ou explicitamente sinalizados.

## AC-013-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-013-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-013-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Origem e destino devem estar no mesmo Tenant; ciclos e dependências inválidas são rejeitados ou explicitamente sinalizados.
