# SPEC-015 — RAG Engine — Acceptance Criteria

**Status:** Draft — critérios domain-specific para `rag-v1`

## AC-015-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project` e permission de view  
**When** consulta RagEvaluation  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-015-02 — operação principal

**Given** RagEvaluation válido e ator com grant necessário  
**When** executa `evaluateRag` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-015-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Calculated RAG é determinístico e preservado; override muda Effective RAG, exige justificativa e audit.

## AC-015-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-015-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.

## AC-015-06 — cálculo determinístico e incomplete

**Given** conjunto fixo de entradas normalizadas e rule version `rag-v1`  
**When** o cálculo é repetido  
**Then** resultado, indicadores e hash são idênticos; ausência de entrada obrigatória retorna `incomplete`, nunca Green.
