# SPEC-025 — PMO Copilot — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-025-01 — consulta autorizada

**Given** ator com membership ativa, scope `Actor + authorized sources` e permission de view  
**When** consulta CopilotInteraction  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-025-02 — operação principal

**Given** CopilotInteraction válido e ator com grant necessário  
**When** executa `askCopilot` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-025-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** AI Context ≤ Authorized User Context; AI não é source of truth e não executa ação consequencial sem confirmação e reautorização.

## AC-025-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-025-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-025-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** AI Context ≤ Authorized User Context; AI não é source of truth e não executa ação consequencial sem confirmação e reautorização.

## AC-025-07 — credencial própria e segredo protegido

**Given** Tenant Admin com `ai.config.manage` e credencial/provider válido  
**When** salva, valida, rotaciona ou desabilita a configuração  
**Then** configuração/modelos ficam versionados no Tenant correto, segredo é guardado em secret manager, nunca aparece em resposta/log/audit/UI após gravação e cada alteração sensível é auditada.

## AC-025-08 — roteamento automático por complexidade

**Given** Tenant com três modelos ativos e solicitação autorizada  
**When** Gateway aplica a versão determinística da regra de classificação  
**Then** request usa somente o modelo correspondente à classe calculada `low|medium|high`, persistindo classe/regra/modelo; cliente não pode forçar classe e nenhum fallback cruza Tenant.

## AC-025-09 — gastos e qualidade da medição

**Given** usuário com `ai.cost.view` no Tenant  
**When** consulta um período e agrupa por provider/model/classe  
**Then** totais e detalhes são restritos ao Tenant e distinguem custo reportado, estimado e indisponível, tokens e moeda; custo indisponível não é apresentado como zero confirmado nem como fatura final.

## AC-025-10 — falha de credencial ou limite

**Given** credencial inválida/revogada, modelo indisponível ou limite alcançado  
**When** usuário solicita Copilot  
**Then** Gateway não envia conteúdo ao provider não configurado, retorna erro seguro e grava telemetria sem segredo; funcionalidades centrais não dependentes de IA permanecem disponíveis.
