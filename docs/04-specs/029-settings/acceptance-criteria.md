# SPEC-029 — Settings — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-029-01 — consulta autorizada

**Given** ator com membership ativa, scope `Tenant + settings permission` e permission de view  
**When** consulta TenantSetting  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-029-02 — operação principal

**Given** TenantSetting válido e ator com grant necessário  
**When** executa `getSettings` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-029-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Configurações são tenant-scoped e tipadas; secrets nunca são retornados; mudanças sensíveis auditadas.

## AC-029-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-029-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-029-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Configurações são tenant-scoped e tipadas; secrets nunca são retornados; mudanças sensíveis auditadas.
