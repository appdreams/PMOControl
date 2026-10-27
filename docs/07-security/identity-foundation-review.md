# Revisão inicial de Identity & Access

Data: 2026-10-26. Tarefas: F1-01, F1-13 parcial e F0-08 parcial.
Status: revisão parcial; schema inicial aplicado somente no DEV; login/Auth ainda bloqueados por policies, RPCs e testes RLS pendentes.

## Contratos examinados

Requisitos, regras, banco, permissões, critérios e testes da SPEC-003;
contratos de banco/regras das SPEC-001/002 e banco da SPEC-027;
políticas RLS canônicas e segurança de sessão. Esta é uma revisão parcial,
não aprovação integral das quatro Specs.

Nesta continuação foram alinhados o boundary de RLS/PostgREST, o modelo de
role assignment versus permission efetiva, os scopes de plataforma, a
idempotência de audit com Tenant nulo e o contrato de convite single-use.
Detalhes normativos foram escritos nas Specs 001/002/003/027, em
`docs/06-data/rls-data-policies.md` e em
`docs/08-api/authentication-authorization.md`.

## Pendências antes de habilitar Auth e fluxos de dados

| Tema | Achado e próximo passo | Tarefa |
|---|---|---|
| Contexto confiável | Fechado para o boundary adotado: Supabase SSR + PostgREST com JWT verificado por request; RLS deriva ator de `auth.uid()` e valida membership/Tenant no mesmo request. GUC `app.*` e contexto escolhido no browser não são usados. Helper privilegiado só pode entrar após revisão de função específica. | F1-01 resolvido; implementação F1-04 |
| Sessão | Contrato fechado: JWT de 3600 s, refresh rotation; cookie SSR host-only, Path=/, SameSite=Lax, Secure em HTTPS e sem expiração curta; Origin/Host para métodos inseguros; logout local; `getUser` para detecção imediata quando exigida. Plano Free não fornece timeout provider absoluto/inatividade; gate pré-produção: upgrade compatível ou política de idade app-level implementada/testada. | F1-01 contrato; F1-08 implementação; gate produção |
| Grants | Fechado: `access_grants` atribui Role em Tenant/scope; `role_permissions` mapeia Permission; avaliação expande papéis e aplica deny à permissão efetiva depois da ancestry. Entitlement de plataforma usa catálogo/roles de sistema, nunca delegável por Tenant. Grants especiais seguem roles/presets separados e delegation ceiling. | F1-01 resolvido; schema F1-02/06 |
| Herança | Contrato fechado: DAG de ancestry versionado; allow herda somente por aresta explícita e permission marcada descendants; deny na mesma scope ou ancestral vence; sibling/descendente não se aplica; ancestry inválida nega. Até catálogo/adapter F1-06, avaliador permanece scope exato. | F1-01 resolvido; F1-06 implementação |
| Convites | Resolvido no contrato: token aleatório 256-bit, SHA-256 persistido, email normalizado, TTL 7 dias; aceite vincula email verificado, consome condicionalmente e cria membership/grant atomicamente, com delegation ceiling revalidado; reemissão revoga anteriores. Falta implementar e testar no banco. | F1-01 resolvido; F1-09 implementação |
| Lifecycle | Matriz Tenant/Membership definida na SPEC-002, incluindo estados terminais, reativação de membership revogada somente por convite e serialização/atomicidade com audit; falta codificar e testar em migration/RPC. | F1-01 contrato; F1-02/04 implementação |
| Audit | Contrato fechado: ator autenticado/verificado obrigatório, allowlist de actor_type/event payload; falhas pré-auth permanecem nos logs Supabase Auth e nenhum email/IP não verificado entra em audit da aplicação. `tenant_id NULL` somente para evento platform-scoped. Falta writer/schema/tests. | F1-01 contrato; F1-07 implementação |
| Ambiente | `PMO Control` (ref `xsznvegtaukrvvrgubnn`) foi designado DEV em 2026-10-26. CLI oficial 2.122.0 via `pnpm dlx` gerou migration; Supabase MCP aplicou-a e validou SQL no banco. `psql` e autenticação/link local da CLI ainda não estão disponíveis. Sem Docker. | F0-07 parcial |

Responsável pela continuação técnica: desenvolvimento. As decisões de boundary RLS e normalização RBAC podem orientar a migration. Pendências de sessão, convite, lifecycle e ambiente ainda impedem concluir F1-01 e habilitar Auth.

## Primeira implementação

`apps/web/src/modules/identity/domain/authorization.ts` implementa avaliação pura
de grants de permissão em escopo exato, sem SDK ou dependência de Next.js.
Exige identidade/sessão válidas, Tenant e membership ativos, correspondência de
ator/Tenant/recurso, permissão, política de dados e workflow. Validade temporal é
`[startsAt, expiresAt)` em milissegundos; revogação bloqueia o grant.
Não há cache de decisões, privilégio implícito de papel ou wildcard de permissão.

Allow em outro escopo não é herdado. Enquanto a ancestralidade não estiver
implementada, deny ativo da mesma permissão/ator/Tenant em outro escopo bloqueia
conservadoramente, inclusive quando poderia ser disjunto. Operações `platform.*`
são recusadas por esse avaliador de negócio.

Este módulo recebe fatos de adapters confiáveis; ele NÃO autentica uma requisição,
valida JWT, carrega grants ou implementa RLS. Não deve receber um DTO do browser.
O adapter futuro deve expandir roles em permissões do catálogo, carregar todos os
grants relevantes (incluindo denies), validar estado atual na transação e nunca
aceitar flags de política/workflow enviadas pelo cliente.

## Evidência e limites

Validação local em 2026-10-26: 32 testes passaram; ESLint, geração de tipos Next,
`tsc --noEmit` e `next build --webpack` passaram. Comandos executados diretamente
com Node sobre as ferramentas instaladas. Node emite aviso de detecção de ESM ao
carregar o arquivo TypeScript no runner; isso não impediu os testes.

Na continuação, a avaliação de autorização passou a negar com `invalid_context`
entradas runtime malformadas (coleção de grants ausente, scope inválido e deny
malformado) em vez de lançar exceção. TypeScript, ESLint e os 32 testes locais
passaram. A evidência permanece somente de domínio, sem provar API, banco ou RLS.

`apps/web/tests/authorization.test.mjs`: testes de AC-003-01/02/03/04/06/07 e
TC-003-09, incluindo dois Tenants, IDs forjados, expiração, revogação e separação
de publicação/correção. Cobertura parcial de domínio; não comprova proteção de
API, persistência, política por campo, delegação ou paridade RLS (TC-003-08).

`pnpm test` usa o test runner do Node 24.12.0, sem novas dependências. O workflow
web passa a executar esses testes; execução remota ainda não realizada.

## Hardening do banco DEV — 2026-10-26

O advisor encontrou `public.rls_auto_enable()` como SECURITY DEFINER executável
por `anon` e `authenticated`. A função pertence a um event trigger ativo que
habilita RLS em tabelas novas de `public`; não foi removida nem desativada. A
migration `20261026163821_restrict_rls_event_trigger_execution.sql` revogou
EXECUTE de `PUBLIC`, `anon` e `authenticated`, preservando o privilégio do
proprietário.

Verificação inicial no projeto DEV: migration consta no histórico remoto; uma
tabela probe criada em transação teve RLS habilitado pelo event trigger e foi
removida com rollback; `anon`/`authenticated` não executam a função, `postgres`
continua executando. Naquela etapa não havia tabelas de aplicação.

## Gate de CI de banco — smoke check inicial

O workflow `.github/workflows/ci.yml` agora observa `supabase/**`. O job
`database-rls` roda somente em push para `main` ou `workflow_dispatch` na branch
`main`, dentro do
GitHub Environment `supabase-dev`; pull requests não recebem a URL do banco.
Ele exige a variável `SUPABASE_PROJECT_REF=xsznvegtaukrvvrgubnn` e o secret
`SUPABASE_DB_URL`, confere o ref fixado como DEV e executa
`supabase/tests/context_rls_smoke.sql` com `psql`.

O smoke check cria dois usuários, dois Tenants, memberships ativas e uma
membership revogada em uma transação, assume `authenticated` e verifica falta de
contexto, isolamento entre atores/Tenants, invisibilidade da membership revogada
e ausência de privilégios de escrita. O script termina em `ROLLBACK`. Ele não
aplica migrations nem substitui a suite de policies/RPCs de negócio. F0-08 segue
parcial até os secrets/vars do Environment serem configurados e o job passar em
CI; forged IDs, atomicidade de audit e constraints same-tenant continuam como
cobertura futura. Não executar `db reset --linked`.

Referência de provedor: [sessões Supabase](https://supabase.com/docs/guides/auth/sessions).
JWT válido não substitui a revalidação de acesso atual; controles de duração
precisam ser reconciliados com o plano/configuração antes da integração.


## Preparação SSR — 2026-10-26

Pacotes `@supabase/ssr` 0.12.7 e `@supabase/supabase-js` 2.118.0 fixados no
manifest/lockfile. Clients para browser e servidor foram preparados com cookie
store do Next e o Proxy do Next.js 16 usa `getClaims()` para verificar/renovar
tokens. Configuração aceita somente URL HTTPS ou localhost e chave publicável.
O proxy não concede acesso a Tenant nem protege endpoints de negócio sozinho.
Login permanece desabilitado e `.env.example` continua sem credenciais. O adapter
de membership agora existe; somente a policy de leitura mínima foi aplicada, e
as demais policies/RPCs e os testes de isolamento ainda faltam. O fluxo não
depende de Docker.

Referência técnica: [SSR no Supabase com Next.js](https://supabase.com/docs/guides/auth/server-side/creating-a-client?framework=nextjs).

## Desenho inicial de schema — 2026-10-26

As migrations `20261026185335_create_identity_access_foundation.sql` e
`20261026185430_index_identity_access_foreign_keys.sql` foram aplicadas no
projeto DEV (PostgreSQL 17.11). Criaram as nove tabelas F1-02 vazias, ativaram
RLS sem policies e revogaram privilégios de `PUBLIC`, `anon`, `authenticated` e
`service_role`. Verificação de catálogo confirmou 9/9 tabelas com RLS ativo,
zero policies e zero privilégios SELECT/INSERT para essas roles; histórico
remoto coincide com os timestamps locais. Nenhum login foi habilitado.

Contrato fechado para role: templates de produto são materializados por Tenant;
roles de plataforma são globais; criação/edição de role customizada fica fora do
MVP. O convite usa `grant_payload` v1 allowlisted para role/scope; acceptance
revalida tudo contra catálogo e teto do emissor.

Contrato de ator fechado: usuários usam `auth.uid()`; serviços/jobs usam IDs
estáveis de catálogo versionado na aplicação, validados pelo writer (não por FK
polimórfica). Inserção direta de audit pela API ou `service_role` é proibida.

Na primeira verificação, o advisor de segurança reportou 9 findings INFO
`rls_enabled_no_policy`. Após a policy de leitura mínima, restam 7 dessas
informações nas tabelas ainda fechadas. O advisor de performance não tem FKs sem
índice após a segunda migration; os 20 findings INFO restantes são índices ainda
sem uso em tabelas vazias. FKs compostas para scopes de recursos serão adicionadas
junto aos schemas desses recursos. F1-02 foi aplicado; F1-03, F1-04, F1-05,
F0-07 e F0-08 seguem parciais.

## Contexto confiável de request — 2026-10-26

`apps/web/src/modules/identity/application/resolve-request-context.ts` implementa
a decisão pura para não autenticado, sem membership, escolha de Tenant, seleção
inválida e contexto resolvido. `apps/web/src/server/infrastructure/supabase/request-context.ts`
adapta Supabase SSR: `getClaims()` fornece o ator; uma consulta PostgREST por
request relê memberships ativas e Tenant ativo; correlation ID é gerado no
servidor. Falhas do banco/RLS dão `context_unavailable`, sem serem convertidas
em “sem membership”. A migration `20261026190349_enable_self_membership_context_read.sql`
concede somente SELECT nessas duas tabelas por policies restritas a `auth.uid()`.
O adapter ainda não autoriza grants/permissions. Foi conectado a
`GET /api/v1/session/tenants`, que retorna apenas os Tenants ativos próprios com
`private, no-store`. A leitura própria foi validada em transação com dois
Tenants; operação de negócio continua bloqueada até policies/RPC específicas e
CI de isolamento por tabela.

## Policy mínima de leitura do contexto — 2026-10-26

Migration `20261026190349_enable_self_membership_context_read.sql` aplicada ao
DEV. `authenticated` recebeu somente SELECT em `memberships` e `tenants`;
membership retorna só linha própria ativa, e Tenant retorna só ativo com
membership própria ativa. Não foi concedido INSERT/UPDATE/DELETE nem acesso a
`anon` ou `service_role`. Catálogo confirmou RLS, policies e privilégios nas duas
tabelas; advisor de segurança reduziu os findings `rls_enabled_no_policy` de 9
para 7 (INFO nas tabelas ainda fechadas). Advisor de performance continua sem
FKs sem índice.

## Validação de isolamento e seleção — 2026-10-26

Uma transação no DEV criou dois usuários sintéticos, dois Tenants, memberships
ativas para seus respectivos atores e uma membership revogada. Sob
`SET LOCAL ROLE authenticated` com `auth.uid()` de cada ator, cada um viu uma
membership ativa e um Tenant; o Tenant do outro ator retornou zero linhas; a
membership revogada não apareceu. A transação terminou em `ROLLBACK`, e a
consulta posterior confirmou zero usuários de fixture persistidos.

`GET /api/v1/session/tenants` e `POST /api/v1/session/tenant` usam o resolver
server-side. POST aceita somente `tenantId`, exige Origin/Host da origem canônica
(`APP_ORIGIN`; default local localhost), revalida membership/Tenant e não grava
seleção como autoridade. Respostas são `private, no-store`; seleção de Tenant
não autorizado retorna 404 não revelador. ESLint e typecheck passaram; testes
automatizados e integração do login continuam pendentes.

## Catálogo inicial RBAC — 2026-10-26

O módulo `apps/web/src/modules/identity/domain/permission-catalog.ts` versiona
`rbac-v1`, metadados de scope/classificação/sensibilidade e nove presets de
papéis. O avaliador puro agora nega permission keys desconhecidas e ações
aplicadas a um tipo de scope incompatível. Herança permanece desabilitada.
`supabase/seed.sql` carregou no DEV 99 permissions, os dois papéis globais de
plataforma e sete vínculos role_permission. Verificação confirmou RLS ativo e
nenhum privilégio SELECT para `authenticated` em `permissions`, `roles` e
`role_permissions`. As tabelas permanecem inacessíveis pela API. Presets Tenant
serão materializados por Tenant no onboarding; grants, expansão no adapter,
delegation ceiling, policies/RPCs de administração e CI ainda estão pendentes.
Não houve mudança de schema nesta fatia.

`apps/web/src/modules/identity/application/prepare-tenant-role-presets.ts`
prepara os sete registros Tenant e seus vínculos permissionados de forma
determinística, rejeita Tenant ID malformado e falha se um preset Tenant incluir
permission de plataforma. O planner permanece puro; os mesmos presets foram
espelhados em tabela privada versionada para uso pela transação de provisionamento.

`apps/web/src/modules/identity/domain/platform-authorization.ts` adiciona uma
avaliação pura separada de membership Tenant: só considera grants de plataforma
com `tenant_id NULL`, scope `platform/platform`, janela válida e deny explícito
prioritário. O adapter de criação não confia nesse avaliador puro: o banco repete
a checagem do grant atual dentro da transação.

## Provisionamento transacional de Tenant — 2026-10-26

A migration `20261026210156_provision_tenant_with_platform_grant.sql` foi aplicada
no DEV e registrada no histórico Supabase. A rota `POST /api/v1/tenants` valida
origem, JSON estrito, slug, nome, motivo e chave UUID de idempotência. Supabase SSR
valida a sessão; o RPC deriva `auth.uid()` novamente e exige grant ativo de
plataforma para `tenant.lifecycle.create`, negando se houver deny ativo. Em uma
única transação, cria Tenant, sete roles, 107 associações permissionadas e evento
append-only de audit com ator, motivo, correlation ID e idempotency key. Replay
idêntico retorna o Tenant; ator/payload diferente com a mesma chave dá conflito.
O operador não recebe membership implicitamente; o convite do primeiro
administrador é uma etapa pendente antes de o Tenant ficar operacional.

O wrapper em `public` é SECURITY INVOKER; o helper SECURITY DEFINER reside em
`private`, usa `search_path` vazio e SQL qualificado, requer `auth.uid()`, e tem
EXECUTE concedido somente a `authenticated`. API ACL consultada no DEV confirmou
sem EXECUTE para `anon` ou `service_role`; a tabela de presets tem RLS e nenhum
SELECT para `authenticated`/`anon`. Advisors agora reportam oito INFO
`rls_enabled_no_policy` (incluindo a tabela privada, sem grant de leitura); não
foram encontrados avisos de exposição por essa migration. O primeiro operador
tem uma conta Auth confirmada e grant ativo `platform_admin` com
`tenant.lifecycle.create`; a consulta confirmou janela válida, ausência de deny
e um evento de bootstrap. Um evento corretivo append-only registra que a
execução foi feita via Supabase MCP `execute_sql` e substitui o rótulo de canal
incorreto no evento inicial. A rota HTTP ainda não foi validada com uma sessão
real, pois o login da aplicação continua sem integração. O procedimento manual
para novos ambientes está em `supabase/operations/bootstrap-first-platform-admin.sql`;
ele exige conta Auth confirmada, verificação do ref DEV e ausência de grants prévios.
`pnpm typecheck` e `pnpm lint` passaram após a implementação.

## Atualização de validação no DEV — 2026-10-27

O primeiro convite de administrador foi emitido e aceito com a sessão real do
operador Auth confirmado. A verificação posterior confirmou, no Tenant sintético
`pmo-dev-validacao-20261026`, uma membership ativa, um grant `tenant_admin`, um
convite `first_admin` aceito com token hash de 32 bytes e os eventos de auditoria
de emissão e ativação. A navegação autenticada abriu `/workspace` com esse Tenant
selecionado. O link foi compartilhado manualmente; nenhum e-mail foi enviado.

Convites `tenant_member` continuam pendentes. Embora `membership.invite` exista
nos presets, o fluxo de aceite implementado aceita somente `first_admin`, e o
servidor ainda não dispõe de validação completa de delegation ceiling e
compatibilidade entre papel, scope e recurso. Implementar emissão comum antes
desses controles permitiria atribuir capacidades fora do escopo autorizado. A
próxima etapa é fechar os RPCs/policies de membership e grants (F1-05/F1-06/F1-10)
e só então habilitar papéis/scope que o servidor consiga validar; e-mail e criação
de contas Auth continuam sendo uma etapa separada.

## Diretório mínimo de membros — 2026-10-27

A migration `20261027132120_list_tenant_membership_boundary.sql` foi aplicada
no DEV. `private.list_tenant_members` deriva o ator de `auth.uid()`, exige
membership e Tenant ativos, permission `membership.view` no scope exato do
Tenant e ausência de deny ativo. O wrapper público é `SECURITY INVOKER`; o helper
privado usa `search_path` vazio e não concede SELECT direto nas tabelas. A
projeção entrega identificador, nome de exibição, status e papéis no scope Tenant,
sem e-mail, tokens ou assignments de Portfolio/Project.

A rota `GET /api/v1/tenants/{tenantId}/members` e o painel no workspace foram
validados na sessão autenticada de DEV. Em 2026-10-27, a migration
`20261027134145_assign_tenant_role_with_ceiling.sql` adicionou catálogo privado
rbac-v1 de permission/scope e RPC transacional de atribuição Tenant; a rota
`POST /api/v1/access-grants` aceita apenas outro membro ativo do mesmo Tenant.
O RPC exige `membership.invite` no scope Tenant exato, revalida cada permissão
do papel contra allow/deny ativo do ator, falha fechado para scope desconhecido,
e registra grant e audit atomicamente com chave idempotente. Lint, typecheck e
advisors foram conferidos. Nenhuma atribuição foi criada: o Tenant sintético só
tem o administrador atual e self-grant é negado. Advisors passaram de 8 para 9
INFO de RLS fechada, incluindo catálogo privado; permanecem o aviso de password
leak e um FK sem índice. Convite comum, lifecycle e grants Portfolio/Project
seguem pendentes.

## Regra pura de delegation ceiling — 2026-10-27

`apps/web/src/modules/identity/domain/delegation.ts` adiciona `canDelegateRole`:
valida papel ativo do Tenant correto, permissão `membership.invite` no Tenant e
todas as permissions do papel pretendido no scope exato, usando o avaliador que
rejeita grants expirados/revogados e aplica deny. Scope incompatível, papel de
plataforma e permission fora do catálogo falham fechados. ESLint e typecheck
passaram. A função pura não tem autoridade própria; as mutations limitadas de
grant e convite repetem a checagem na transação do banco. Não há atribuição fora
do Tenant nesta etapa.

## Convites de membros comuns — 2026-10-27

A migration `20261027135220_invite_tenant_members_with_delegation.sql` foi
aplicada ao DEV. A checagem de assinatura encontrou chamada a
`jsonb_object_length`, inexistente no PostgreSQL do DEV; a migration forward-fix
`20261027135719_fix_invitation_grant_payload_validation.sql` substituiu-a por
validação JSONB disponível e foi confirmada no corpo da função implantada.
`POST /api/v1/tenants/{tenantId}/invitations` gera token
aleatório de 256 bits e persiste somente SHA-256; o RPC exige membership e Tenant
ativos, `membership.invite` exato, papel Tenant de sistema e ceiling completo do
emissor. Reemissão para o mesmo endereço revoga o convite pendente anterior e
audita a mudança. `POST /api/v1/invitations/accept` agora despacha first-admin e
tenant-member para handlers isolados. Aceite comum exige e-mail Auth confirmado,
trava Tenant/memberships antes do convite, revalida emissor e permissions atuais,
e atualiza membership/grant/convite/audit em transação. Membership suspensa não
é reativada por convite. O workspace mostra formulário para papel Tenant e link
manual; nenhum e-mail é enviado.

O catálogo contém 99 permissions, comparando com 99 cadastradas; RPCs privados e
wrappers têm EXECUTE apenas para `authenticated`, nunca `anon`. Advisors
continuam nos mesmos níveis: 9 INFO de RLS em tabelas fechadas, 1 WARN de
proteção a senha vazada e 1 INFO de FK sem índice. Nenhum convite foi emitido e
nenhuma membership foi alterada; o fluxo requer uma segunda conta Auth para
validação ponta a ponta. `pnpm lint`, `pnpm typecheck` e `git diff --check`
passaram. A documentação de API, banco, UI, critérios e checklist foi alinhada.
