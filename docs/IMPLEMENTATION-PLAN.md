# PMO Control — Plano Mestre de Desenvolvimento

**Status:** Plano vivo de execução
**Atualizado:** 2026-10-27
**Fonte de progresso:** este plano + [`MVP-CHECKLIST.md`](MVP-CHECKLIST.md)

## 1. Objetivo e regras de uso

Este plano transforma as 29 Specs em uma sequência de entregas pequenas, revisáveis e seguras. O trabalho segue a dependência funcional documentada em [`DEPENDENCY-MAP.md`](DEPENDENCY-MAP.md); nenhuma etapa pode marcar um módulo como concluído apenas porque a tela ou o schema existem.

**Legenda:** `[ ]` pendente · `[~]` em andamento · `[x]` concluído com evidência · `[!]` bloqueado · `[>]` adiado deliberadamente.

1. Antes de iniciar uma fase, marque-a `[~]` e indique responsável/PR quando houver.
2. Ao concluir uma tarefa, registre evidência verificável: teste, comando, migration, PR ou workflow CI. Atualize o checklist correspondente na mesma mudança.
3. Bloqueios recebem `[!]`, descrição, decisão/insumo necessário e responsável; não esconda bloqueios como tarefas concluídas.
4. Mudança de escopo atualiza Spec, critérios de aceite, testes, plano e checklist na mesma PR.
5. Alterações no Supabase devem nascer como migration revisada no repositório, ser aplicadas primeiro em desenvolvimento e ter o estado remoto verificado. Não faça alteração permanente manual sem migration correspondente.
6. PRs citam os IDs das tarefas deste plano e FR/AC/TC da Spec afetada.

## 2. Estado atual

- **Estado:** bootstrap concluído; contratos F1-01 e schema inicial aplicados no DEV, leitura RLS mínima validada com dois Tenants, endpoints iniciais de sessão implementados. A sessão real do operador e o `POST /api/v1/tenants` foram validados. F1-09 foi validado de ponta a ponta com `pvinicius@gmail.com`: link manual emitido e aceito, com membership, grant e audit. Em 2026-10-27, tabelas e fluxos de Portfolio/Project com associação temporal e troca de gerente foram aplicados no DEV. Constraints compostas impedem referências cross-Tenant e acesso direto continua fechado; smokes de associação e troca de gerente passaram com rollback. A segunda conta Auth foi confirmada, possui membership ativa e `pmo_admin` no Portfolio `TI Estratégico`; o operador também tem `pmo_admin` nesse Portfolio. O Projeto de validação foi criado no DEV e a segunda conta recebeu `pmo_admin` no scope exato do Projeto, com auditoria.
- **Foco atual:** nomes de exibição agora são obrigatórios em `user_profiles`. A migration `20261027205134_require_user_display_names.sql` backfilla perfis vazios com rótulo provisório, aciona criação automática para novas contas Auth e expõe formulário pessoal no workspace para informar o nome real; o nome aparece em membros e candidatos a gerente. A troca de gerente continua bloqueada até outra conta tornar-se membro ativo.
- **GitHub:** branch `main`, remoto `appdreams/PMOControl`; bootstrap publicado. `gh auth status` confirmou sessão da conta `appdreams`. O commit `9697590` publicou o workflow de CI para RLS; Actions `40594741068` passou em todos os jobs em 2026-10-27.
- **Supabase:** projeto `PMO Control`, ref `xsznvegtaukrvvrgubnn`, ativo/saudável, PostgreSQL 17.11, designado DEV em 2026-10-26. Migrations até `20261027205134` aplicadas; RPCs usam wrappers `SECURITY INVOKER` e funções privilegiadas somente no schema privado. As tabelas continuam sem acesso direto pela Data API. Nomes de perfil são não nulos; leitura/alteração ocorre somente por RPC autenticada do próprio ator. A checagem ACL da troca de gerente confirmou wrappers invoker, implementações privilegiadas privadas, `search_path` vazio, execução negada a `anon` e permitida a `authenticated`. Assessors de segurança e performance foram consultados após a migration; baseline inclui 12 INFO de RLS em tabelas deliberadamente fechadas, 1 WARN de proteção contra senha vazada, uma FK sem índice no catálogo privado de permissões e 22 índices ainda não usados no DEV de baixo tráfego.
- **Aplicação:** Next.js + TypeScript; login e recovery Supabase Auth, callback PKCE, redefinição de senha, logout local e workspace pós-login implementados. Sessão autenticada confirmada no navegador em 2026-10-26. `.env.local` configurado com valores publicáveis do DEV e ignorado pelo Git. Para o identificador automático de Tenant, `pnpm test` (69 testes), `pnpm lint` e `pnpm typecheck` passaram; a validação real confirmou prévia, bloqueio de nome inválido e conflito de duplicata sem estado adicional. Build de produção passou localmente com `NEXT_DIST_DIR=.next-ci-build` para isolar os artefatos do servidor em execução.
- **Ainda não implementado:** policies/RPC de negócio, CI de testes RLS por tabela, módulos de produto, ambientes hospedados adicionais e deploy.
- **Supabase SSR/Auth:** clientes de browser/servidor, renovação de cookie via Proxy Next.js 16, login, recovery, callback PKCE, redefinição de senha, logout e workspace pós-login estão conectados. O `.env.local` do DEV contém a configuração publicável e é ignorado pelo Git.
- **Observação de ambiente:** Docker não faz parte do fluxo. A CLI oficial 2.122.0 foi usada via `pnpm dlx` para gerar a migration; aplicação/verificação remota foi feita pelo MCP. `psql` e credenciais/link local da CLI continuam ausentes, então F0-07 segue em andamento.

### Início da fundação de autorização — 2026-10-26

Responsável: desenvolvimento (Codex). Revisão parcial e pendências registradas em
[`identity-foundation-review.md`](07-security/identity-foundation-review.md).
F1-01 concluído: contratos de sessão, ancestry/deny, lifecycle e audit foram
formalizados e alinhados a AC/TC. F1-13 iniciado com avaliador puro de escopo exato e testes
negativos. F0-08 concluído: testes de domínio e smoke de RLS adicionados ao workflow; pipeline
migrations/RLS ainda pendente. Uma migration de segurança, sem tabelas de aplicação,
foi aplicada ao projeto DEV e validada; nenhuma integração Auth foi realizada.
O fluxo não usa Docker. F0-07 e gates adicionais de segurança seguem em andamento.

### Próximas três tarefas

1. `[x] F1-05` Suspensão/reativação de membership com `membership.manage`, reason/version, deny, grants preservados e audit atômico; migration `20261027155632_manage_tenant_membership_lifecycle.sql` e UI aplicadas. Smokes DEV (todos em transações revertidas) validaram sucesso, versões, audit, falta de permissão, versão obsoleta, auto-transição e proteção do último Tenant Admin; ACL/`search_path` e ausência de fixtures conferidos.
2. `[~] F1-03/F1-10` CRUD protegido, associação temporal e troca de gerente de Portfolio/Project implementados no workspace com smoke transacional. A validação real diagnosticou atribuição ao gerente atual e conflitos de versão; migration `20261027203631` e refresh de conflito corrigem esse comportamento. Permanecem policies de negócio e a validação de transferência real; falta outra membership ativa no Tenant.
3. `[x] F0-08` CI de migrations/RLS e fixtures no projeto hospedado DEV; execução Actions `40594741068` aprovada, sem Docker. F1-13 permanece parcial até ampliar testes de autorização por rota/entidade.

## 3. Fases e entregas

### Fase 0 — Bootstrap de engenharia `[~]`

**Escopo:** repositório, aplicação mínima, CI, configuração da Supabase CLI e acesso a ambiente hospedado de desenvolvimento.

- [x] **F0-01** Criar branch/repositório Git e conectar `origin`; commit inicial publicado.
- [x] **F0-02** Inicializar Next.js + TypeScript, App Router, layout pt-BR e health endpoint.
- [x] **F0-03** Fixar Node/pnpm, manter lockfile e ignorar dependências, builds e segredos locais.
- [x] **F0-04** Criar workflow GitHub com lint, geração de tipos Next, typecheck e build; resultado remoto aprovado.
- [x] **F0-05** Criar configuração versionada da Supabase CLI e instruções de ambiente.
- [x] **F0-06** Conectar MCP ao projeto PMO Control e confirmar banco inicial vazio.
- [~] **F0-07** Projeto Supabase remoto de desenvolvimento designado; migration de hardening aplicada pelo MCP e verificada. Falta validar um fluxo local de CLI/psql com credenciais isoladas; Docker não é utilizado.
- [x] **F0-08** Workflow observa `supabase/**`; job restrito ao GitHub Environment `supabase-dev` executa `supabase/tests/context_rls_smoke.sql` no DEV em push para `main` ou execução manual. Um smoke transacional direto via MCP com as duas contas ativas confirmou isolamento para contexto ausente e visibilidade de memberships/Tenants próprios, com rollback. O Environment `supabase-dev` foi criado no repositório e recebeu a variável `SUPABASE_PROJECT_REF=xsznvegtaukrvvrgubnn`. O secret `SUPABASE_DB_URL` foi cadastrado pelo operador; commit `9697590` publicou o workflow e a execução `40594741068` passou, incluindo o smoke `psql` de contexto RLS. Migrations não são aplicadas automaticamente.

**Gate parcial:** repositório publicado, CI de lint/typecheck/build e smoke RLS remoto — **passaram**. Fase 0 ainda aguarda validar o fluxo local de CLI/psql sem Docker (F0-07); migrations só após ferramenta e schema revisados. O fluxo não requer Docker. Os gates da Fase 13 continuam necessários para produção.

### Fase 1 — Identity, Tenant, RBAC e audit foundation `[~]`

**Specs:** 001 Authentication, 002 Multi-Tenancy, 003 RBAC, 027 Audit Log (fundação de escrita/eventos).

- [x] **F1-01** Revisão cruzada de contrato concluída: JWT 3.600 s + refresh rotation, cookie/CSRF/logout, limite do plano Free, ancestry/deny, matriz de transição Tenant/Membership e ator/payload de audit alinhados às AC/TC. Timebox/inatividade continua gate de produção a resolver no F1-08.
- [x] **F1-02** Criar e aplicar no DEV as migrations `20261026185335_create_identity_access_foundation.sql` e `20261026185430_index_identity_access_foreign_keys.sql`; nove tabelas vazias, RLS ativo, grants revogados e histórico remoto verificado.
- [~] **F1-03** Constraints básicas, unicidade, estados e índices aplicados; migrations `20261027163212`/`20261027163415` adicionam entidades Portfolio/Project, FKs compostas same-Tenant e índices das novas FKs. Smoke cross-Tenant revertido confirmou rejeições. Falta lifecycle/retention, policies/RPCs por entidade e cobertura em CI; advisor mantém apenas a FK baseline não indexada de tabela privada.
- [~] **F1-04** Resolver Supabase SSR verifica `getClaims`, consulta membership/Tenant ativos por PostgREST sem cache e gera correlation ID no servidor. `GET /api/v1/session/tenants` retorna somente Tenant(s) ativos próprios; `POST /api/v1/session/tenant` valida Origin/Host, confirma o seletor e não persiste contexto como autoridade. Faltam as demais rotas protegidas.
- [~] **F1-05** RLS deny-by-default e leitura de contexto mínima. `20261027134145_assign_tenant_role_with_ceiling.sql` implementa grant Tenant; as RPCs de convite, agora em `20261027165200_invite_members_at_resource_scopes.sql`, validam scope Tenant/Portfolio/Project same-Tenant, `membership.invite` no Tenant e teto por permissão no recurso exato, na emissão e no aceite. O audit e grant permanecem atômicos. `20261027135719_fix_invitation_grant_payload_validation.sql` trata compatibilidade JSONB do PostgreSQL DEV. Segunda conta real aceitou convite scoped de Portfolio; faltam lifecycle/boundaries para outras entidades e validação real da troca de gerente em Project.
- [~] **F1-06** Catálogo `rbac-v1`, nove presets, planner Tenant e avaliador de plataforma separados. O provisionamento inicial criou Tenant, sete roles/107 permission links e audit atomicamente; após `membership.manage` e `membership.grant`, o catálogo DEV atual tem 101 permissions e 111 permission links por Tenant. O catálogo privado permission/scope revalida ceiling/deny no banco. FKs validam scopes de `access_grants`; `getRolePermissionsForScope` e `private.role_delegable_at_scope` filtram ao tipo de scope e exigem grant exato. `20261027165727_list_delegable_invitation_scopes.sql` lista scopes delegáveis; `20261027175329_assign_resource_roles.sql` adiciona `membership.grant` e atribuição atômica; `20261027175837_list_resource_grant_targets.sql` lista somente recursos ativos autorizados e `20261027180442_move_resource_targets_private.sql` mantém sua consulta privilegiada fora da API pública; `20261027191449_assign_project_manager.sql` implementa `project.assign` no Projeto exato. CRUD base está operacional; validação real aguarda segundo membro Auth e Projeto persistente.
- [~] **F1-07** Audit append-only de criação de Tenant e do fluxo inicial de administrador (criar/revogar convite e ativar membership/grant) guarda ator, correlação e motivo sem token ou e-mail no payload redigido. Ainda faltam eventos mínimos de login/recovery, convites/membership/grants gerais, demais transições de lifecycle e scrub sistemático.
- [~] **F1-12 (parcial)** Tela de login conectada, recuperação/redefinição, workspace pós-login, escolha de Tenant, formulário de provisionamento e aceite do primeiro administrador adicionados. Sessão real, provisionamento e ativação do primeiro administrador foram validados no DEV em 2026-10-27; estados completos de sessão expirada e onboarding de novos usuários ainda pendem. `/workspace` abriu com a sessão real e Tenant selecionado. `pnpm lint`, `pnpm typecheck` e `pnpm build` passaram em alterações anteriores; o script usa Webpack pois o Turbopack falha ao iniciar o subprocesso de CSS neste ambiente Windows. O dev local segue em uma pasta `distDir` separada para contornar o lock antigo.
- [~] **F1-08** Login por e-mail/senha, recovery neutro via Supabase Auth, callback PKCE, atualização de senha, logout local e renovação SSR pelo Proxy implementados. `Site URL` do DEV permanece `http://localhost:3000` e a allowlist contém `http://localhost:3000/auth/callback` (verificado no Dashboard em 2026-10-26). Sessão real do operador confirmada em 2026-10-26. SMTP customizado está desativado; recovery usa o SMTP padrão do Supabase, best-effort e restrito a destinatários elegíveis da equipe. Falta aplicar limite de abuso adicional. A idade de sessão permanece gate de produção. MFA e SSO Google/Microsoft ficam fora do MVP.
- [~] **F1-09** Convites first-admin e tenant-member são single-use, expiram em 7 dias e persistem token somente como SHA-256. Convite comum suporta agora scope `tenant|portfolio|project`; emissão e aceite revalidam membership, Auth confirmado do destinatário, emissor, recurso ativo e teto exato. Grant, consumo e audit são atômicos. UI compartilha link manual, sem envio de e-mail. Smoke DEV cobriu os três scopes; uma segunda conta real aceitou convite scoped de Portfolio e recebeu `pmo_admin`; convite Tenant-level com outra conta ainda aguarda validação.
- [~] **F1-10** Endpoints de diretório/listagem confirmam membership e Tenant; seleção não é autoridade. `GET /api/v1/tenants/{tenantId}/invitation-scopes` retorna scopes com preset delegável; `GET .../resource-grant-targets` mostra recursos ativos apenas ao ator autorizado; `POST .../invitations` aceita scope exato; `POST .../resource-grants` atribui papel com `membership.grant`; `POST .../projects/{projectId}/manager` troca o gerente com `project.assign` no escopo exato. Associação e transferência têm smoke transacional; validação ponta a ponta com outra conta Auth pendente.
- [~] **F1-11** Suspensão/reativação de membership por administradores Tenant em andamento. Início de encerramento export-first do Tenant continua pendente; purge só após export, prazo/retention e ausência de hold/disputa aplicável.
- [~] **F1-12** Login, recovery, redefinição de senha, seleção de Tenant, provisionamento inicial e página de aceite de convite implementados. Sessão real, provisionamento e RPC de emissão/aceite foram validados no DEV. Pendentes: entrega de e-mail/conta Auth para convidados e estados completos de sessão negada/expirada.
- [~] **F1-13** Testes unitários de autorização/delegação/contexto cobrem convite/aceite Tenant, Portfolio e Project, listagem exata, cross-Tenant, ator/seletor forjados e falha fechada. `pnpm test` passou (69 testes), assim como lint, typecheck e build. O modelo de erro correlaciona todas as respostas 5xx com logs JSON seguros, deduplicados por requisição. Smokes SQL com rollback cobrem convite/grants; contexto RLS real no DEV passou via CI. Restam IDs forjados nas demais rotas e ampliar as policies/mutations protegidas por entidade.
- [~] **F1-14** Specs 002/003/004/005, checklist, plano, changelog e README de migrations atualizados; advisors revistos após DDL. Zero FK nova sem índice; permanece uma FK baseline sem índice em tabela privada e o aviso de proteção contra senha vazada. A revisão das demais Specs e o baseline completo de segurança seguem pendentes.

**Gate de segurança:** mesmo Tenant autorizado → permitido; Tenant diferente, membership ausente/revogada, grant inválido, actor/Tenant forjado → negado; mutation sensível e audit obrigatórios são atômicos. Sem esse gate, não iniciar dados de cliente nem módulos de negócio.

### Fase 2 — Fundação de interface e Portfolio/Project `[~]`

**Specs:** design system/UX base, 004 Portfolios, 005 Projects; Box Focus global.

- [~] **F2-01** Componentes compartilhados `Button`, `TextField`, `SelectField`, `TextAreaField` e `Feedback` estão em `apps/web/src/components/ui`, com foco visível, mensagens semânticas e estilos comuns. Usados no perfil, seletor de Tenant, convites, grants, provisionamento de Tenant e gestão de membros, além dos fluxos Portfolio/Project. Navegação acessível por âncoras cobre perfil, membros e recursos; ações de associação/lifecycle mantêm botão comum ou destrutivo segundo a operação. Faltam consolidar listas/tabelas, tokens e concluir revisão de acessibilidade. `pnpm lint`, `pnpm typecheck` e `git diff --check` passaram; workspace autenticado foi conferido no browser.
- [ ] **F2-02** Implementar Box Focus: todos os boxes titulados têm destaque por duplo clique; demais elementos em escala de cinza; alternativa por teclado, Escape e retorno de cor; testar contraste e navegação.
- [~] **F2-03** Fundação DB, leitura/criação/edição/arquivamento e associação temporal gerenciada implementados nas migrations `20261027181701`, `20261027183256`, `20261027184547` e forward-fix `20261027185024`. Associar/remover exige permissão sensível exata no Portfolio, `project.view` exato no alvo, motivo e idempotency key; remover também valida versão e preserva histórico/Projeto. Smoke DEV passou com rollback para link/unlink, replay, versão stale e relink. Validação real com outra membership ainda pendente.
- [~] **F2-04** Fundação DB, leitura/criação/edição/arquivamento, associação temporal e troca de gerente implementados; migrations `20261027191449_assign_project_manager.sql` e `20261027203631_prevent_noop_project_manager_assignment.sql`. Edição/archive exigem grant exato e versão; `POST .../projects/{projectId}/manager` exige `project.assign`, membro ativo, motivo, versão e chave idempotente; campo do gerente, grant/revogação e audit são atômicos. A migration mais recente retira o gerente atual da lista e rejeita no-op; o formulário recarrega dados após conflito. Verificação DEV comprovou bloqueio no-op e gerente/version preservados (versão 2 após tentativa anterior sem troca). Para transferência real falta outra membership ativa e um ator autorizado distinto do novo gerente.
- [ ] **F2-05** Manter Baseline, Forecast e Actual separados; implementar mudança de baseline com motivo, aprovação/workflow definido e histórico.
- [ ] **F2-06** Criar telas e API conforme SPEC-004/005; estados vazios, erros, forbidden e conflito incluídos.
- [~] **F2-07** Smoke SQL transacional confirmou create/list/update/archive, associação temporal e troca de gerente (grant/revogação, replay idempotente, versão stale), além das rejeições cross-Tenant; fixtures revertidos e advisors conferidos. Ainda faltam policies por entidade e execução do smoke no CI; rastreabilidade FR → AC → TC permanece parcial.

**Gate:** usuário com membership/grant válido percorre Tenant → Portfolio → Project; outro Tenant não enumera nem acessa recursos. Box Focus funciona por mouse e teclado sem alterar dados.

### Fase 3 — Execução do projeto `[ ]`

**Specs:** 007 Milestones, 008 Deliverables, 013 Dependencies.

- [ ] **F3-01** Implementar Milestones com tipos/status/defaults documentados, datas, dono, progresso e estados permitidos.
- [ ] **F3-02** Implementar Deliverables com critérios de aceite, responsável, evidências e ciclo de aceitação.
- [ ] **F3-03** Implementar Dependencies com `dependency_type` allowlisted, source/target validado e prevenção de ciclos inválidos conforme Spec.
- [ ] **F3-04** Preservar Project/Tenant ownership, versionamento, eventos/audit e atualizações idempotentes.
- [ ] **F3-05** Criar APIs, telas, import schema compatibility e testes de domínio/RLS/API.

**Gate:** relações e enums são validados pelo servidor/banco; nenhuma referência cross-tenant ou ciclo proibido é aceito; alterações concorrentes são detectadas.

### Fase 4 — Governança diária `[ ]`

**Specs:** 009 Risks, 010 Issues, 011 Actions, 012 Decisions.

- [ ] **F4-01** Implementar Risks e histórico de avaliações/respostas; manter probabilidade/impacto/tendência e configuração de taxonomias.
- [ ] **F4-02** Implementar Issues como problemas presentes, separadas semanticamente de Risks; ciclo de resolução e severidade/prioridade conforme catálogo.
- [ ] **F4-03** Implementar Actions rastreáveis a origem/owner/prazo/estado e governança de conclusão.
- [ ] **F4-04** Implementar Decisions, justificativas, comentários append-only, responsável, estado e histórico de decisão/correção.
- [ ] **F4-05** Aplicar permissões, scopes, optimistic concurrency, audit e eventos de domínio.
- [ ] **F4-06** Criar telas, filtros e estados; adicionar testes para regras/edge cases/segregação de campo.

**Gate:** Risk ≠ Issue; Actions têm origem e responsabilidade; decisões e alterações sensíveis não apagam histórico e deixam audit rastreável.

### Fase 5 — Status, RAG e snapshots imutáveis `[ ]`

**Specs:** 014 Status Update, 015 RAG Engine, 016 Snapshots; dependência nas fases 2–4.

- [ ] **F5-01** Implementar draft mensal por Project/Tenant timezone, consolidação autorizada das fontes, datas de corte e source IDs/versions.
- [ ] **F5-02** Implementar checklist de publicação, N/A com justificativa, bloqueios versus avisos e versionamento concorrente.
- [ ] **F5-03** Implementar cálculos determinísticos `kpi-v1` e `rag-v1`; avaliação `incomplete` para fontes obrigatórias ausentes; registrar versão, inputs normalizados e hash.
- [ ] **F5-04** Implementar override somente com grant, justificativa, avaliação calculada preservada e trilha append-only.
- [ ] **F5-05** Implementar `snapshot-v1`: JSON canônico, SHA-256, vínculos e imutabilidade contra roles de aplicação.
- [ ] **F5-06** Publicar em uma transação: Publication + Snapshot + RAG/inputs necessários + Audit/Outbox; usar idempotency key e rollback integral em erro.
- [ ] **F5-07** Corrigir somente por publicação sucessora vinculada, com motivo e sem alteração retroativa do Snapshot anterior.
- [ ] **F5-08** Criar jobs retry-safe pós-commit para projeções/notificações; falha downstream não desfaz publicação oficial.
- [ ] **F5-09** Implementar UX de criação, preview, publicação, correção e comparação Current vs Published.
- [ ] **F5-10** Testar atomicidade, retries, duplicação, concorrência, reprodução/hash, authorization freshness e imutabilidade.

**Gate crítico:** cadeia `Publish → RAG → Snapshot → Audit` íntegra, idempotente, transacional e autorizada; testes de falha provam zero estado parcial.

### Fase 6 — Centro de controle e visibilidade `[ ]`

**Specs:** 006 Project Control Center, 017 My Day, 018 Project Dashboard, 019 Portfolio Dashboard.

- [ ] **F6-01** Criar projeções/read models rebuildable com source IDs/versions, `as_of`, Tenant e autorização revalidada.
- [ ] **F6-02** Implementar Project Control Center como visão derivada, não fonte paralela; filtros e ações apontam aos comandos oficiais.
- [ ] **F6-03** Implementar My Day com prioridades/tarefas do usuário autenticado e estado acionável.
- [ ] **F6-04** Implementar dashboards de projeto/portfolio com distinção explícita Current vs Published, origem/tempo/availability de métricas.
- [ ] **F6-05** Testar recomputação, dados atrasados, autorização, escopo, vazamento em cache e estados vazios.

**Gate:** dashboards sempre derivam do modelo fonte e não expõem indicadores fora do grant/data policy.

### Fase 7 — Financeiro, recursos e documentos `[ ]`

**Specs:** 020 Financial, 021 Resources, 022 Documents.

- [ ] **F7-01** Implementar acesso separado de leitura/edição/export para campos financeiros; trilha e política de retenção.
- [ ] **F7-02** Implementar diretório de recursos e alocações com constraints de capacidade, escopo e conflitos.
- [ ] **F7-03** Implementar metadata/document versions/evidence no banco e binários em bucket privado.
- [ ] **F7-04** Criar policy de Storage, upload/download com grant verificado e signed URL curto; testar revogação e cross-tenant.
- [ ] **F7-05** Implementar telas, export allowlist e testes de campo confidencial, storage, lifecycle e retenção.

**Gate:** acesso Project não concede Financial/Resource/Confidential data implicitamente; buckets privados e downloads revalidam autorização.

### Fase 8 — Histórico e relatórios `[ ]`

**Specs:** 023 Time Machine, 024 Report Builder.

- [ ] **F8-01** Reconstituir estado histórico somente por Snapshots versionados; rotular modo e horário de corte.
- [ ] **F8-02** Implementar comparação e validação de integridade sem reescrever snapshots.
- [ ] **F8-03** Implementar definições/execuções de relatório com filtros allowlisted, ownership e artifact privado/expirável.
- [ ] **F8-04** Testar temporalidade, política por linha/campo, expiração de arquivo e acesso após revogação.

**Gate:** relatório histórico é reproduzível e respeita autorização atual e temporalidade documentada.

### Fase 9 — Settings e inteligência artificial `[ ]`

**Specs:** 029 Settings, 025 PMO Copilot; depende de identidade, autorização e dados estáveis.

- [ ] **F9-01** Implementar Settings do Tenant e taxonomias com delegation ceiling, versionamento, audit e alterações com effectivity.
- [ ] **F9-02** Implementar AI Gateway server-side e adapters para OpenAI GPT, Google Gemini, Anthropic Claude, Meta Llama, DeepSeek e OpenRouter.
- [ ] **F9-03** Implementar credenciais BYOK do Tenant como referências cifradas server-side; teste/rotação/desativação e redaction.
- [ ] **F9-04** Implementar três modelos por configuração (baixo/médio/alto) e seleção automática, determinística, explicável/versionada segundo regra documentada.
- [ ] **F9-05** Implementar ledger append-only de custo/uso, fontes/estimativa e tela de gastos; aplicar permissões `ai.cost.view/export`.
- [ ] **F9-06** Implementar grounding limitado ao Effective Access; Fact/Inference/Recommendation, output estruturado validado, proposta com confirmação humana e nova autorização ao executar.
- [ ] **F9-07** Implementar UX da configuração e Copilot com avisos de indisponibilidade/limites e falha degradável.
- [ ] **F9-08** Construir avaliações/regressão, cross-tenant, prompt injection, provider timeout, custo e resposta estruturada inválida.

**Gate:** contexto da IA nunca excede o autorizado ao usuário; nenhum secret aparece no cliente/log; IA não comanda ação consequencial sem confirmação e reautorização.

### Fase 10 — Importação e exportação `[ ]`

**Spec:** 028 Import & Export; o workbook de Project depende das entidades das fases 2–4.

- [ ] **F10-01** Implementar jobs, staging, limites de arquivo e Storage privado; idempotência, retries e expiração de artefatos.
- [ ] **F10-02** Gerar template vazio e exemplo `.xlsx` sintético idênticos em schema/versionamento `project-import-v1`.
- [ ] **F10-03** Selecionar somente Projects ativos do Tenant verificado e com scope; ignorar IDs/tenant do workbook como autoridade.
- [ ] **F10-04** Validar workbook estrito (abas/cabeçalhos/tipos/enums/refs/limites, sem macros/fórmulas/links externos), mostrar erros por linha/célula antes de escrita.
- [ ] **F10-05** Implementar carga inicial sem pergunta de modo quando escopo está vazio.
- [ ] **F10-06** Implementar adicionar como insert-only; duplicatas bloqueiam sem sobrescrita implícita.
- [ ] **F10-07** Implementar reiniciar com grant separado, preview/contagens/confirmação digitada e substituição atômica somente do escopo v1; preservar Audit/Publications/Snapshots/holds.
- [ ] **F10-08** Implementar export com revalidação de escopo/campo e artifact privado/expirável.
- [ ] **F10-09** Testar arquivo malformado, injection, duplicatas, falha parcial, retries, cross-Tenant e rollback de reinício.

**Gate:** preview/validação antes da mutação; import sem parcialidade; restart somente no Project selecionado e sem destruir histórico protegido.

### Fase 11 — Notificações, audit UI e plataforma `[ ]`

**Specs:** 026 Notifications, 027 Audit Log (consulta/export UI), 029 Settings avançado; exclusão de Project da SPEC-005.

- [ ] **F11-01** Implementar inbox/preferences/deliveries com payload minimizado, idempotência, backoff e falha não bloqueante.
- [ ] **F11-02** Implementar Audit Log UI com filtros allowlisted, paginação, política de campo, exports governados e busca de correlation ID.
- [ ] **F11-03** Implementar console administrativo da plataforma isolado do conteúdo de Tenant.
- [ ] **F11-04** Implementar preview/confirm/job de purge de Project: entitlement Root separado, reason e confirmação, job retomável, allowlist de dados operacionais, retenção/holds e tombstone mínimo.
- [ ] **F11-05** Garantir que Platform Root Admin não receba implicitamente permissão para consultar conteúdo de negócio do Tenant.
- [ ] **F11-06** Testar purge com dry-run/fixtures, histórico preservado, bloqueios por retention/legal hold, idempotência e falhas/reexecuções; validar advisors e procedimento de restore.

**Gate:** console mostra apenas metadados mínimos; purge não apaga publicações, snapshots, audit ou dados sob retenção/hold e não ultrapassa o Project.

### Fase 12 — Integrações necessárias `[ ]`

- [~] **F12-01** Redirect de callback local validado na allowlist do Auth DEV. SMTP customizado ainda não foi provisionado; até lá o DEV depende do SMTP padrão, sujeito aos limites de destinatários/equipe e entrega best-effort. Antes de habilitar recovery/convites para usuários externos ou produção, provisionar SMTP por ambiente, domínio, entregabilidade, links e templates pt-BR.
- [ ] **F12-02** Configurar Inngest para processos assíncronos, assinatura/autorização, retries, idempotência e observabilidade.
- [ ] **F12-03** Fechar primeiro adapter prioritário com contrato, OAuth/segredos, mapeamentos, conflito, retry, audit e reconciliação.
- [ ] **F12-04** Manter Jira/Azure DevOps/GitHub/Microsoft Project/Drive/Teams/Slack/sistemas financeiros fora do core até prioridade validada; cada integração recebe plano/ADR próprios.

**Gate:** falha de provedor não compromete fonte transacional; nenhuma credencial aparece no cliente/log e sync tem autoridade de fonte explicitada.

### Fase 13 — Produção e release `[ ]`

- [ ] **F13-01** Provisionar dev/preview/prod separados e aplicar secrets por ambiente.
- [ ] **F13-02** Executar suite de segurança, tenant isolation, authz, RLS, Storage, upload/import, purge e supply chain.
- [ ] **F13-03** Completar E2E golden paths: login/convite → escolher Tenant → criar Portfolio/Project → execução/governança → publicar Status → snapshot/dashboard.
- [ ] **F13-04** Fazer baseline de carga/performance, alertas/SLOs, logs correlation e resposta a incidentes.
- [ ] **F13-05** Validar backups/restores, migrations forward-fix, rollback de app, acesso de produção e restore drill.
- [ ] **F13-06** Verificar accessibility/responsive, retenção/legal, exportabilidade e docs sincronizadas com comportamento real.
- [ ] **F13-07** Liberar produção somente após gates críticos verdes e revisão de release.

**Gate de release:** backup/restore demonstrado, security suite verde, dados isolados, integridade Status/Snapshot provada, rollback testado e documentação atual.

## 4. Definition of Done por módulo/PR

- [ ] Todos os FR da Spec implementados ou explicitamente adiados/aprovados.
- [ ] AC e TC ligados aos FR foram executados; evidência anexada à PR/CI.
- [ ] Domínio/use case sem dependência indevida de Next.js/SDK; API, UI e banco coerentes com a Spec.
- [ ] Autorização validada no servidor; RLS, relações same-tenant e política de campo cobertas.
- [ ] Audit/eventos transacionais/idempotência implementados conforme risco do módulo.
- [ ] Loading/empty/validation/forbidden/conflict/failure e acessibilidade documentados/implementados.
- [ ] Telemetria sem PII/secrets e com correlation ID em caminhos críticos.
- [ ] Migration aplicada no ambiente de desenvolvimento e rastreada no Git; rollback/forward-fix entendido.
- [ ] `pnpm lint`, `pnpm typecheck`, `pnpm build` e testes relevantes passam no CI.
- [ ] Docs, rastreabilidade, este plano e `MVP-CHECKLIST.md` atualizados; nenhuma finding High/Critical aberta.

## 5. Ritmo de atualização

- Atualizar checkboxes no PR que conclui a tarefa, incluindo link de evidência/commit e data quando necessário.
- Atualizar **fase atual** no topo sempre que o próximo gate for iniciado ou aprovado.
- Manter `MVP-CHECKLIST.md` como painel de gates globais e o quadro de Specs como status por módulo; este arquivo mantém sequência, tarefas e critérios.
- Não marcar a coluna Done de uma Spec antes de completar seu gate de segurança/testes/documentação.
- A estimativa de calendário será adicionada quando houver disponibilidade da equipe e tamanho real da primeira fatia; este plano não inventa prazo.
