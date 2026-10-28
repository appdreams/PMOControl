# PMO Control — MVP Checklist

**Status:** Checklist operacional vivo
**Uso:** marque somente com evidência em código, migration, teste ou CI.

**Plano detalhado:** [`IMPLEMENTATION-PLAN.md`](IMPLEMENTATION-PLAN.md)
**Fase atual:** Fase 1 — Identity, Tenant e RBAC. Não avançar para itens da Fase 2 até fechar os gates desta fase. Fase 0 concluída; F0-07 usa `psql` no CI com a URL protegida do DEV e sem Docker. O CI compara o histórico de migrations com os arquivos locais. Catálogo `rbac-v1`, provisionamento, grants Tenant, convites Tenant/Portfolio/Project, atribuição/revogação controlada, lifecycle e CRUD Portfolio/Project com associação temporal/troca de gerente estão no DEV. O app não envia e-mail; aceite requer conta Auth confirmada. A consulta agregada mais recente encontrou 3 perfis incompletos e 2 memberships ativas; cada pessoa deve informar seu próprio nome pelo workspace. A segunda conta Auth aceitou convite scoped de Portfolio e tem membership ativa; o Projeto `Validação de troca de gerente` foi criado e recebeu grant `pmo_admin` para essa conta no scope exato, com auditoria. A terceira conta ainda não é membro; o usuário decidiu aguardar outro administrador antes de prosseguir com esse convite.

**Estado confirmado em 2026-10-28:** 40 migrations aplicadas no DEV até `20261028020817`; histórico e arquivos locais devem permanecer em paridade. Exportação privada, geração, checksum, notificação, download, disputa, legal hold e purge retomável estão implementados; smoke de export/disputa/hold/purge passou em transação com rollback. O worker de purge foi implantado como Edge Function `tenant-export` versão 2; a remoção do objeto ocorre pela Storage API. Advisor: nenhuma FK sem índice; 16 INFO de RLS em tabelas deliberadamente fechadas (inclui fila privada do purge); 1 WARN de proteção contra senhas vazadas, exceção aceita pelo usuário em 2026-10-27 por permanecer no Free; 29 índices sem uso em DEV de baixo tráfego.

## 1. Fase 1 — gates de encerramento

**Fonte única de escopo e critério de 100%:** [`PHASE-1-CLOSURE.md`](PHASE-1-CLOSURE.md). Não contar pendências da Fase 2 nem gates de produção nesta lista. O usuário decidiu manter o Supabase no plano Free; a proteção contra senhas vazadas fica registrada como exceção aceita.

- [x] **C1 — Identity/Tenant/RBAC:** constraints e índices, isolamento, grants, convites e lifecycle. Migration `20261028012242_index_rbac_preset_permission_fk.sql` aplicada; advisor sem FK sem índice e CI `40616066451` passou com paridade das 36 migrations e smokes.
- [~] **C2 — Auth/onboarding:** validar login, recovery/reset, callback, logout, renovação e estados de sessão negada/expirada; confirmar proteção de abuso e perfil self-service com testes. Não exige que todos os usuários preencham seus nomes reais para liberar a fase.
- [~] **C3 — Audit:** confirmar eventos append-only de operações sensíveis, recovery/alteração de credenciais e scrub por testes; tokens e segredos não podem aparecer em audit/log.
- [~] **C4 — Export/retention de Tenant:** exportação privada verificável, notificação, download autenticado, disputa, legal hold e purge retomável implementados. Migrations `20261028014319`, `20261028015112`, `20261028020344` e `20261028020817`; smoke no DEV passou com rollback, sem excluir dados reais. Edge Function `tenant-export` v2 implantada; falta CI verde atualizado para fechar o gate.
- [~] **C5 — Testes/documentação:** ampliar matriz negativa dos endpoints incluídos em C1–C4, manter smokes no CI e revisar Specs 001/002/003/027. CI `40616066451` validou lint, typecheck, 78 testes, build, paridade das 36 migrations e smokes transacionais. Revisão das Specs e matriz negativa de C2–C4 continuam no escopo fixo.

**Fora dos gates:** CRUD/UX de Portfolio/Project (Fase 2), SMTP customizado, MFA/SSO, expiração absoluta de sessão, ambientes/deploy/backup de produção e testes que exijam uma terceira conta real. Os fluxos suportados precisam de smokes automatizados, não de alteração de dados de pessoas reais.
## 2. Core Specs

  Spec   Módulo                   Backend   DB      UI      Security   Tests   Done
  ------ ------------------------ --------- ------- ------- ---------- ------- -------
  001    Authentication           \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  002    Multi-Tenancy            \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  003    RBAC                     \[ \]     \[ \]   \[ \]   \[ \]      \[ \]   \[ \]
  004    Portfolios               \[ \]     \[~\]   \[ \]   \[~\]      \[~\]   \[ \]
  005    Projects                 \[ \]     \[~\]   \[ \]   \[~\]      \[~\]   \[ \]
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


