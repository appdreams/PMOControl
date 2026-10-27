# PMO Control — MVP Checklist

**Status:** Checklist operacional vivo
**Uso:** marque somente com evidência em código, migration, teste ou CI.

**Plano detalhado:** [`IMPLEMENTATION-PLAN.md`](IMPLEMENTATION-PLAN.md)
**Fase atual:** Fase 1 — Identity, Tenant e RBAC. Não avançar para itens da Fase 2 até fechar os gates desta fase. Fase 0 concluída; F0-07 usa `psql` no CI com a URL protegida do DEV e sem Docker. Catálogo `rbac-v1`, provisionamento, grants Tenant, convites Tenant/Portfolio/Project, atribuição/revogação controlada, lifecycle e CRUD Portfolio/Project com associação temporal/troca de gerente estão no DEV. O app não envia e-mail; aceite requer conta Auth confirmada. O perfil cria rótulo provisório para contas sem metadado e pede ao próprio usuário que informe o nome real; a validação das contas atuais está pendente. A segunda conta Auth aceitou convite scoped de Portfolio e tem membership ativa; o Projeto `Validação de troca de gerente` foi criado e recebeu grant `pmo_admin` para essa conta no scope exato, com auditoria. A terceira conta ainda não é membro, portanto não há outro alvo elegível para a transferência.

**Estado confirmado em 2026-10-27:** migrations `20261027163212`, `20261027163415`, `20261027165200`, `20261027165727`, `20261027175329`, `20261027175837` e `20261027180442` aplicadas no DEV. Smokes em transação revertida validaram convite nos três scopes, atribuição e replay idempotente de grant Portfolio, seletor de recursos ativos, rejeição cross-Tenant e deny; zero fixtures remanescentes. Catálogo DEV atual: 101 permissions, 111 vínculos de preset Tenant e 111 vínculos no Tenant aberto. RPCs públicas são executáveis por authenticated e negadas a anon; a consulta privilegiada de recursos foi movida para função no schema privado e o wrapper público é `SECURITY INVOKER`. Advisors: 12 INFO de RLS em tabelas fechadas, 1 WARN de proteção contra senha vazada, zero FKs novas sem índice e uma FK baseline não indexada em schema privado; o aviso de SECURITY DEFINER público foi removido.

## 1. Foundation

-   [x] Repositório GitHub `appdreams/PMOControl`, branch `main`, commit inicial publicado.
-   [x] Next.js + TypeScript bootstrap; lint, typecheck e build de produção via Webpack aprovados localmente.
-   [x] GitHub Actions executa lint, typecheck, testes de domínio e build; execução passou no commit de código `efd6d159`.
-   [x] Node.js/pnpm fixados, lockfile versionado e arquivos `.env.*`, dependências e builds ignorados pelo Git.
-   [x] Configuração da Supabase CLI versionada em `supabase/config.toml`; migrations usam projeto hospedado de desenvolvimento.
-   [x] MCP conectado ao projeto DEV `PMO Control`; schema, privilégios, catálogo RBAC e advisors revisados.
-   [~] Login e recovery conectados ao Supabase Auth: e-mail/senha, callback PKCE, redefinição, logout local, página pós-login, seletor de Tenant e formulário de provisionamento. Cadastro público continua fechado. Login/recovery renderizam no navegador; `/workspace` foi verificado redirecionando sem sessão e abrindo com sessão real em 2026-10-26. `pnpm lint`, `pnpm typecheck` e `pnpm build` passaram; script de build fixado em Webpack porque o Turbopack falha ao iniciar um subprocesso para CSS neste ambiente Windows. `Site URL` do DEV é `http://localhost:3000` e o callback `http://localhost:3000/auth/callback` está na allowlist. SMTP customizado está desativado; e-mail de recovery não foi enviado/testado.
-   [x] Projeto Supabase `PMO Control` designado como DEV; CLI oficial via `pnpm dlx` gerou migrations, MCP aplicou/verificou, e o GitHub Environment isolado executa `psql` contra o DEV sem persistir a URL localmente. CI `40594741068` e seguintes passam; fluxo sem Docker.
-   [x] Pipeline CI: quality gates web e job SQL protegidos configurados; Environment `supabase-dev` com `SUPABASE_PROJECT_REF` e `SUPABASE_DB_URL`; execução Actions `40598022420` passou em lint, 69 testes, typecheck, build e cinco smokes SQL com rollback (RLS, convites, grants, Portfolio/Project e encerramento) no Supabase DEV. Migrations não são aplicadas automaticamente.
-   [x] Criar e aplicar no DEV as migrations iniciais de Identity & Access; nove tabelas com RLS ativo, grants fechados por padrão e histórico remoto conferido.
-   [~] Clients Supabase SSR/browser, Proxy de renovação, login, recovery, reset e logout integrados; `.env.local` ignorado configurado com URL e publishable key do DEV. Redirect `/auth/callback` está na allowlist e a sessão real foi confirmada. SMTP customizado e entrega de recovery continuam pendentes.
-   [~] Resolver contexto confiável via SSR/PostgREST e rotas de listagem/seleção de Tenant; conferir novamente membership/Tenant ativos a cada request.
-   [~] Aplicar policy mínima de leitura RLS de contexto. Teste transacional anterior confirmou isolamento entre dois Tenants; faltam policies por entidade/ação e RPCs.
-   [~] F1-06: catálogo `rbac-v1`, nove presets, planner Tenant e avaliador de grants de plataforma; validação original de provisionamento confirmou 100 permissions, sete vínculos globais e 107 vínculos em sete roles Tenant. Consulta do DEV em 2026-10-27: 101 permissões no catálogo, 112 vínculos nos presets Tenant e 112 permission links no Tenant selecionado. A rota `/api/v1/tenants` revalida grant platform `tenant.lifecycle.create` e deny e cria Tenant, roles, vínculos de preset e audit atomicamente. A UI deriva identificador do nome. ACL e `search_path` verificados; presets privados sem SELECT. Testes locais atuais: 69 aprovados; lint, typecheck e build de produção aprovados. O build usou `NEXT_DIST_DIR=.next-ci-build` para não conflitar com o servidor local. A validação real de slug automático, nome inválido e duplicata ocorreu na sessão do DEV. Fixtures foram revertidos.
-   [~] F1-09: migrations `20261027125336_first_tenant_admin_invitation.sql`, `20261027130146_isolate_first_admin_invitation_kind.sql` e `20261027130438_resume_first_admin_setup.sql` aplicadas no DEV. Criador do Tenant com grant de plataforma ativo emite link único de 7 dias para papel `tenant_admin`; token de 256 bits persistido somente como SHA-256, reemissão revoga link pendente. Aceite exige e-mail Auth confirmado correspondente e grava membership, grant e audit atomicamente. Testes transacionais revertidos cobriram contexto autorizado/negado, emissão, reemissão, aceite, mismatch, replay e isolamento do tipo. Em 2026-10-27, o convite real foi aceito e conferido: 1 membership ativa, 1 grant `tenant_admin`, convite aceito com hash de 32 bytes e auditorias de emissão/aceite; workspace autenticado abriu com Tenant selecionado. A UI compartilha link manual e não envia e-mail; conta Auth precisa ser previamente criada e confirmada.
-   [~] F1-05/F1-06/F1-09/F1-10: diretório exige `membership.view`; convite/aceite revalidam membership, Auth confirmado, ceiling e scope, token hash-only de sete dias e audit atômico. Smoke DEV transacional sintético emitiu e aceitou convite `tenant_member` como Tenant Admin e conferiu membership/grant/audit; rollback deixou zero fixture. Uma segunda conta Auth real aceitou convite scoped no Portfolio e recebeu grant `pmo_admin`; diretório mostra os dois membros após recarregar o workspace. A validação de convite Tenant-level com outra conta ainda aguarda execução.
-   [~] F1-06/F1-09/F1-10: convites scoped aplicam delegation ceiling no recurso exato e UI lista somente scopes/papéis delegáveis. As migrations de atribuição de papéis e gerente verificam membro/escopo ativo, isolamento same-Tenant, deny precedence, versão/idempotência e audit atômico. Smokes de associação e troca de gerente passaram com rollback; CRUD está no workspace. Conta real, Project e grant `pmo_admin` no scope exato estão confirmados; teste real requer um ator adicional autorizado ou decisão sobre outra regra de autorização.
-   [x] F1-05/F1-10 (lifecycle): catálogo ganhou `membership.manage`, migration `20261027155632_manage_tenant_membership_lifecycle.sql`, rota versionada e ações separadas da revogação no painel. Aplicada ao DEV; transações revertidas validaram suspensão/reativação, versões 1→2→3, grants preservados, dois eventos audit, negação por falta de permission, versão obsoleta, auto-transição e último Tenant Admin. `pnpm lint`, `pnpm typecheck`, ACL/`search_path` aprovados; nenhum fixture ou audit de teste permaneceu. Convite scoped de Portfolio foi aceito por outra conta Auth; convite comum com papel Tenant-level ainda aguarda validação real.
-   [~] F2-03/F2-04: migrations `20261027181701`, `20261027183256`, `20261027184547`, `20261027185024`, `20261027191449` e `20261027203631` implementam CRUD, associação temporal e troca de gerente com rejeição de no-op. UI lista candidatos sem o gerente atual e recarrega os dados após conflito 409. RPC exige `project.assign` exato, versão, motivo e chave idempotente; atualiza gerente, grant e audit na mesma transação e encerra o acesso `project_manager` anterior. Smokes sintéticos prévios passaram com rollback; a verificação no DEV reproduziu a falha (seleção do gerente atual, incremento de versão e retries obsoletos) e confirmou que a nova RPC bloqueia no-op sem alterar gerente nem versão. Lint, typecheck e 60 testes locais passaram. Projeto real no Portfolio `TI Estratégico`; a segunda conta tem `pmo_admin` no scope exato do Project. A terceira conta ainda não aceitou convite; falta outra membership ativa para concluir transferência real.
-   [~] F1-01 perfis: migration `20261027205134_require_user_display_names.sql` torna `display_name` obrigatório, cria perfil por trigger para Auth novo e adiciona RPCs self-service com payload/ator controlados. As duas memberships ativas atuais ainda têm `profile_complete=false`; o workspace solicita que cada pessoa informe o próprio nome. Falta cada usuário concluir o perfil.
-   [x] Bootstrap inicial aplicado no Supabase DEV após confirmar a conta Auth e verificar ausência de grants de plataforma; o evento `platform.access_grant.bootstrap` foi localizado uma vez na auditoria. O script operacional está em `supabase/operations/bootstrap-first-platform-admin.sql` e contém guardas para novos ambientes.
-   [~] F1-07: audit append-only de bootstrap/plataforma, criação de Tenant, convites, grants e lifecycle de membership está implementado. A migration `20261027224138_revoke_scoped_access_grant.sql` adiciona revogação isolada de grant scoped com versão, idempotência, audit atômico e guarda contra revogar `project_manager` fora da troca de gerente; smoke DEV e ACL passaram. Auth Audit Logs cobrem login/logout/signup/tokens; `auth.audit_log_entries` não contém cópias. Permanecem eventos de recovery/alteração de senha observáveis e scrub sistemático.
-   [~] F1-11: suspensão/reativação de membership está implementada. A migration `20261027224740_request_tenant_termination.sql` e rota autenticada de plataforma movem Tenant ativo/suspenso a `termination_pending`, bloqueiam uso normal e auditam ator/motivo/version de forma idempotente. Smoke DEV transacional cobre acesso permitido/negado, status, audit, replay, conflito e versão obsoleta; fixtures revertidos. Export privado verificável, entrega/validação, contestação/legal hold e purge após 90 dias ainda não existem; portanto não há encerramento/purge automático.
-   [~] Smoke SQL de contexto RLS com fixtures de dois atores/Tenants preparado em `supabase/tests/context_rls_smoke.sql`. Em 2026-10-27, uma checagem transacional direta via MCP com as duas contas atuais confirmou isolamento para contexto ausente e acesso apenas a memberships ativas/Tenants relacionados; rollback sem fixtures persistentes. Testes de aplicação cobrem também ator e seletor forjados, memberships inativas e falha fechada (`pnpm test`: 69 passaram; `pnpm lint` e `pnpm typecheck` passaram). O Environment `supabase-dev`, a variável `SUPABASE_PROJECT_REF` e o secret `SUPABASE_DB_URL` estão configurados. O workflow foi publicado no commit `9697590`; execução Actions `40594741068` passou em 2026-10-27, incluindo `psql` e o smoke de isolamento RLS no Supabase DEV.
-   [x] Logging/correlation e modelo de erro nos limites server-side: rotas API versionadas usam envelope comum com `requestId` e `X-Request-Id`; qualquer resposta 5xx emite um log JSON correlacionado, uma única vez por requisição. Falhas classificadas preservam a operação e o tipo de erro sanitizado; respostas genéricas registram operação segura, sem mensagem, stack, identificadores de recurso ou payload. Mutações de Portfolio/Project incluem código SQLSTATE validado nas falhas RPC não classificadas. Coberto por testes locais; 69 testes passaram, além de lint, typecheck e build de produção.
-   [~] F2-01: base reutilizável de interface inclui `Button`, `TextField`, `SelectField`, `TextAreaField` e `Feedback`, aplicada ao perfil, seletor, convite scoped, grants, provisionamento de Tenant, gestão de membros e fluxos de Portfolio/Project. Workspace tem navegação por âncoras; botões comuns/destrutivos e feedback semântico estão padronizados nesses fluxos. Faltam listas/tabelas, consolidação de tokens e revisão abrangente de acessibilidade. Lint, typecheck, `git diff --check` e conferência do workspace passaram.
-   [ ] Configurar ambientes Vercel dev/preview/produção e secrets após os gates de segurança.
-   [ ] Configurar SMTP e Inngest quando os fluxos dependentes forem implementados.

Evidência da primeira fatia de domínio: [revisão de Identity & Access](07-security/identity-foundation-review.md). Grant inicial, sessão real, provisionamento e primeiro administrador foram verificados. A emissão/aceite comum está implementada para papéis Tenant com delegation ceiling revalidado; ainda aguarda validação real para papel Tenant-level. Convite scoped de Portfolio já foi aceito por uma segunda conta. Isolamento de outras entidades continua pendente.

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


