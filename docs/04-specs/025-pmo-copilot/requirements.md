# SPEC-025 — PMO Copilot — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 025

## Objetivo e regra de domínio

AI Context ≤ Authorized User Context; AI não é source of truth e não executa ação consequencial sem confirmação e reautorização.

## Requisitos funcionais testáveis

- **FR-025-01:** consultar/listar PMO Copilot somente dentro de `Actor + authorized sources`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-025-02:** criar/derivar CopilotInteraction usando apenas campos aceitos pelo domínio: `tenant_id, actor_id, question, authorized_scope, source_refs, fact_inference_recommendation`; validar required fields e relações autorizadas.
- **FR-025-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-025-04:** executar operações governadas: askCopilot, getSources, proposeAction, confirmAction.
- **FR-025-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-025-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-025-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-025-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-025-09:** Enforce the domain invariant: AI Context ≤ Authorized User Context; AI não é source of truth e não executa ação consequencial sem confirmação e reautorização.
- **FR-025-10 — BYOK por Tenant:** permitir ao Tenant Admin configurar credencial própria por provider via referência segura, validar/rotacionar/desabilitar sem jamais retornar o segredo; operações são auditadas sem registrar o valor.
- **FR-025-10a — allowlist de providers MVP:** aceitar somente OpenAI GPT (`openai`), Google Gemini (`google_gemini`), Anthropic Claude (`anthropic_claude`), Meta Llama (`meta_llama`, via endpoint de inferência compatível validado), DeepSeek (`deepseek`) e OpenRouter (`openrouter`). OpenRouter mantém credencial/model IDs próprios; não é alias das demais integrações.
- **FR-025-11 — três níveis de modelo:** cada configuração ativa de provider permite mapear exatamente um modelo para cada classe `low|medium|high`; modelo precisa estar habilitado/capaz para a API configurada. Alterações são versionadas e valem para novas solicitações; requests em andamento mantêm sua configuração resolvida.
- **FR-025-12 — classificação automática:** o Gateway classifica cada solicitação por regras versionadas de use case, tipo de saída, número/diversidade de fontes, análise multi-etapa/cenários e orçamento de contexto; mapeia `low|medium|high` para o modelo do Tenant. Usuário não escolhe/substitui a classe. Classificador determinístico não chama outro LLM. A classe, versão da regra e motivos legíveis ficam na telemetria.
- **FR-025-13 — contabilização:** registrar por solicitação Tenant, provider/model, classe e versão da regra, uso de tokens quando fornecido, unidade/preço usado e custo estimado/confirmado. Falha/ausência de usage ou preço fica explicitamente marcada como indisponível/estimada, nunca como custo zero confirmado.
- **FR-025-14 — gastos de IA:** disponibilizar visão autorizada por período, provider, modelo, use case e classe de complexidade, com totais de solicitações, tokens e custos medidos/estimados e exportação. Visão diferencia consumo medido pela aplicação de cobrança final do provedor.
- **FR-025-15 — falha de configuração:** credencial ausente/inválida ou modelo indisponível gera erro operacional seguro e auditável; não envia dados a credencial de outro Tenant nem faz fallback de provider sem política explícita do Tenant.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-025-01` authorized query → `AC-025-01` → `TC-025-01`.
- `FR-025-02`, `FR-025-04` primary create/command → `AC-025-02` → `TC-025-01/02`.
- `FR-025-03` version/lifecycle → `AC-025-05` → `TC-025-03/05`.
- `FR-025-05` Tenant/source relationship → `AC-025-04` → `TC-025-04/05`.
- `FR-025-06` audit/post-commit → `AC-025-02` → `TC-025-06`.
- `FR-025-07` data policy/export → `AC-025-04` → `TC-025-07`.
- `FR-025-08` UI states/error surfaces → `AC-025-05` → `TC-025-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-025-09` domain invariant → `AC-025-06` → `TC-025-10`.
- `FR-025-10` BYOK/secret lifecycle → `AC-025-07` → `TC-025-11/12`.
- `FR-025-10a` MVP provider/model allowlist → `AC-025-07` → `TC-025-20`.
- `FR-025-11` three-model mapping → `AC-025-08` → `TC-025-13/14`.
- `FR-025-12` automatic deterministic routing → `AC-025-08` → `TC-025-13/14/15`.
- `FR-025-13` per-attempt usage/cost measurement → `AC-025-09` → `TC-025-16/17`.
- `FR-025-14` Tenant cost view/export → `AC-025-09` → `TC-025-18`.
- `FR-025-15` isolation/failure handling → `AC-025-10` → `TC-025-12`.
