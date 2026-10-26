# PMO Control --- MVP Checklist

**Status:** Approved\
**Uso:** controle de implementação. Marcar somente quando houver
evidência no repositório.

**Prontidão do bootstrap:** apto para iniciar a primeira fatia vertical de desenvolvimento local. Persistência e autenticação multi-tenant começam com a migration inicial de Identity & Access, acompanhada de policies RLS e testes negativos. Serviços hospedados e deploy ainda não estão provisionados.

## 1. Foundation

-   [x] Next.js + TypeScript bootstrap (`apps/web`; lint, TypeScript e build Webpack aprovados; Turbopack local esbarra na restrição de iniciar processo auxiliar)
-   [x] Workflow GitHub Actions configurado para lint, typecheck e build; execução hospedada pendente de conectar o repositório ao GitHub.
-   [x] Configuração Supabase local versionada; CLI e Docker Desktop são pré-requisitos na máquina de cada desenvolvedor.
-   [ ] Vercel environments
-   [ ] Supabase project/database/auth/storage
-   [ ] Inngest
-   [x] GitHub CI workflow configurado; primeira execução remota pendente de conectar o repositório.
-   [ ] SMTP configuration
-   [ ] Migrations
-   [ ] Logging/correlation
-   [ ] Error handling
-   [ ] Design system foundation

## 2. Core Specs

  Spec   Módulo                   Backend   DB      UI      Security   Tests   Done
  ------ ------------------------ --------- ------- ------- ---------- ------- -------
  001    Authentication           \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  002    Multi-Tenancy            \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  003    RBAC                     \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  004    Portfolios               \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  005    Projects                 \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  006    Project Control Center   \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  007    Milestones               \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  008    Deliverables             \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  009    Risks                    \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  010    Issues                   \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  011    Actions                  \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  012    Decisions                \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  013    Dependencies             \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  014    Status Update            \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  015    RAG Engine               \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  016    Snapshots                \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  017    My Day                   \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  018    Project Dashboard        \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  019    Portfolio Dashboard      \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  020    Financial                \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  021    Resources                \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  022    Documents                \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  023    Time Machine             \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  024    Report Builder           \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  025    PMO Copilot              \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  026    Notifications            \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  027    Audit Log                \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  028    Import & Export          \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  029    Settings                 \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]

## 3. Critical Governance Gates

-   [ ] Tenant isolation proven with negative tests.
-   [ ] Effective Access implemented server-side.
-   [ ] Sensitive permissions deny-by-default.
-   [ ] Baseline change workflow implemented.
-   [ ] RAG deterministic calculation implemented.
-   [ ] RAG override requires justification/audit.
-   [ ] Status publication is atomic/idempotent.
-   [ ] Published snapshot is immutable.
-   [ ] Audit events append-oriented.
-   [ ] Executive decisions preserve history.
-   [ ] Confidential documents protected.
-   [ ] Financial/resource sensitive data protected.
-   [ ] Project Excel import: Tenant-scoped Project selection, official blank/example templates, strict validation, append-only mode, and guarded atomic restart with immutable history retained.
-   [ ] Project purge: Platform Root Admin-only grant, explicit confirmation, idempotent job, no business-content access, retention/legal-hold preservation and minimal tombstone.

## 4. AI Gates

-   [ ] AI Gateway.
-   [ ] OpenAI GPT, Google Gemini, Anthropic Claude, Meta Llama, DeepSeek and OpenRouter BYOK per Tenant.
-   [ ] Three AI models per Tenant provider with deterministic low/medium/high routing and cost-usage view.
-   [ ] Credentials protected/masked.
-   [ ] Authorized grounding.
-   [ ] Fact / Inference / Recommendation distinction.
-   [ ] Structured output validation.
-   [ ] Human confirmation for consequential action.
-   [ ] Fresh authorization before AI-originated command.
-   [ ] Prompt injection tests.
-   [ ] Cross-tenant AI tests.
-   [ ] Evaluation/regression set.

## 5. Operational Gates

-   [ ] CI/CD.
-   [ ] Preview/Production separation.
-   [ ] Secrets management.
-   [ ] Migrations tested.
-   [ ] Backup/restore validated.
-   [ ] Smoke tests.
-   [ ] Monitoring/alerts.
-   [ ] Incident process.
-   [ ] Production access policy.
-   [ ] Release/rollback process.

## 6. UX Gates

-   [ ] Box Focus: all titled boxes support double-click and keyboard toggle; grayscale isolation, Escape restore and accessibility verified.



## 7. MVP Exit Criteria

O MVP está pronto para produção somente quando: - golden path funcional
estiver completo; - critical security gates estiverem verdes; -
status/snapshot integrity estiver comprovada; - operações essenciais
funcionarem sem IA; - AI falhar de forma degradável; - backup/restore e
incident readiness estiverem validados; - documentação refletir a
implementação real.


