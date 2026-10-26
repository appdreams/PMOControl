# SPEC-011 — Actions — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-011-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project` e permission de view  
**When** consulta Action  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-011-02 — operação principal

**Given** Action válido e ator com grant necessário  
**When** executa `createAction` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-011-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Ação derivada mantém source_type/source_id; conclusão exige 100%/data real segundo regra definida.

## AC-011-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-011-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-011-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Ação derivada mantém source_type/source_id; conclusão exige 100%/data real segundo regra definida.
