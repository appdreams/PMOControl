# SPEC-023 — Time Machine — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-023-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project/Snapshot` e permission de view  
**When** consulta SnapshotComparison  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-023-02 — operação principal

**Given** SnapshotComparison válido e ator com grant necessário  
**When** executa `listTimeline` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-023-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Visão histórica deriva somente de snapshots publicados, nunca do estado atual retroprojetado.

## AC-023-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-023-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-023-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Visão histórica deriva somente de snapshots publicados, nunca do estado atual retroprojetado.
