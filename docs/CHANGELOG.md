# PMO Control --- Documentation Changelog

Todas as mudanças semanticamente relevantes na documentação devem ser
registradas aqui.

O histórico detalhado permanece no Git.

Formato inspirado em Keep a Changelog, adaptado ao projeto.

## \[Unreleased\]

### Added
- Encerramento export-first inicia agora por RPC/rota exclusiva de plataforma, com versão, idempotência, transição para `termination_pending` e audit atômico; nenhum export ou purge é marcado como concluído sem artefato verificável. Smoke DEV transacional passa com rollback.
- Revogação isolada de grants Portfolio/Project ganhou RPC/rota versionada e idempotente, com audit atômico e proteção do papel `project_manager`, validada em smoke DEV revertido.
- CI do Supabase DEV executa smokes transacionais de identidade, grants, Portfolio/Project e início do encerramento além do teste de isolamento RLS.
- Cobertura de resolução do contexto autenticado adicionada para Tenant selecionado, ator/seletor forjados, memberships inativas e falha fechada. `pnpm test` (66), `pnpm lint` e `pnpm typecheck` passaram.
- No GitHub, criado o Environment `supabase-dev` e configurada a variável `SUPABASE_PROJECT_REF`. O secret de conexão continua pendente; o workflow local com job RLS também precisa ser publicado no `main` antes da execução automatizada.
- Validação adicional de RLS no Supabase DEV usando as duas contas Auth ativas atuais: contexto ausente não revela memberships nem Tenants, e cada ator consulta apenas suas memberships ativas e os Tenants correspondentes. Transação revertida sem fixtures persistentes. O smoke automatizado em GitHub Actions continua pendente de configuração/verificação do Environment `supabase-dev`.
- Fundação de UI compartilhada em `apps/web/src/components/ui` com `Button`, `TextField`, `SelectField`, `TextAreaField` e `Feedback`, foco visível e mensagens semânticas. Aplicada ao perfil, seletor de organização, convite scoped e grant de recurso. Workspace autenticado oferece navegação por âncoras para perfil, membros e portfólios/projetos. Lint, typecheck e conferência da tela autenticada no browser passaram.
- Padronização completa dos formulários Portfolio/Project com os componentes compartilhados: criar/editar/arquivar Portfolio e Project, associar/remover vínculo e atribuir gerente. Mantidos validação, versões, estados pending e contratos das APIs. Lint, typecheck e workspace local conferidos.
- Padronização do provisionamento de Tenant e da gestão de membros: campos, motivos, convite do primeiro administrador, feedback de erro/estado, ações destrutivas de revogar e controles para suspender/reativar. Os contratos e regras de autorização foram preservados. Lint, typecheck, `git diff --check` e workspace autenticado conferidos.
- Perfil próprio com nome de exibição: migration `20261027205134_require_user_display_names.sql` cria perfis para usuários atuais e Auth futuros, torna `display_name` obrigatório e adiciona RPCs isoladas para leitura/atualização pelo próprio ator. Metadados Auth são apenas sugestão; sem nome disponível, o e-mail local-part serve temporariamente e o workspace pede o nome real. Lista de membros e seletor de gerente atualizam o nome após salvar.
- Correção da troca de gerente após validação real no DEV: a auditoria mostrou que `mobitx.ds@gmail.com` selecionou `pvinicius@gmail.com`, já gerente, e a versão do Projeto subiu sem troca; tentativas subsequentes ficaram em conflito com a versão anterior. A migration `20261027203631_prevent_noop_project_manager_assignment.sql` agora exclui o gerente atual dos candidatos e rejeita no-op. A UI recarrega Projeto/candidatos ao receber HTTP 409. No DEV, uma validação autenticada confirmou que a seleção sem mudança é rejeitada sem incrementar a versão; gerente continua `pvinicius@gmail.com`, versão 2. `pnpm lint`, `pnpm typecheck` e `pnpm test` (60) passaram. A transferência ainda depende de outra membership ativa no Tenant.
- Troca do gerente responsável do Projeto na migration `20261027191449_assign_project_manager.sql`, com seletor mínimo de membros ativos, permissão `project.assign` no scope exato, validação de versão, motivo, idempotência e audit. O campo `project_manager_id`, a revogação do papel anterior e a concessão do novo gerente ocorrem atomicamente. Smoke DEV passou com rollback, inclusive seletor, transferência entre dois membros sintéticos, replay e versão stale; typecheck e lint passaram. Segunda conta Auth confirmada, membership ativa e `pmo_admin` no Portfolio. Projeto `Validação de troca de gerente` criado no DEV; a segunda conta recebeu `pmo_admin` no scope exato e auditoria confirmada. A troca real exige um ator com `project.assign` distinto do gerente alvo; os dois membros atuais não atendem a essa condição.
- Gestão independente temporal de associações Projeto–Portfólio nas migrations `20261027184547_manage_portfolio_project_associations.sql` e `20261027185024_fix_stale_association_conflict.sql`: lista de Projetos autorizados ainda não associados, link/unlink com permissões sensíveis no Portfolio, visibilidade exata no Projeto, versão, motivo, idempotência e audit atômico. A remoção preserva Projeto e histórico; UI e rotas estão integradas. O smoke DEV passou com rollback para link/unlink, replay, conflito de versão antiga e relink histórico; advisors sem novo finding de segurança.
- Edição e arquivamento de Portfolios/Projects: migration `20261027183256_update_archive_resources.sql`, RPCs versionadas, rotas PATCH/POST, flags de capacidade por grant e formulários de workspace. Mutations exigem grant de escopo exato, versão, motivo e chave idempotente; evento audit ocorre na mesma transação. Smoke DEV passou com rollback para update, replay, versão stale e archive; `pnpm test` (60), lint, typecheck e migration foram verificados.
- Primeira fatia operacional de Portfolio/Project no DEV: migration `20261027181701_portfolio_project_read_create.sql`, RPC/API tenant-scoped de listagem e criação e UI no workspace. Criação verifica grants exatos, associa o Project ao Portfolio na mesma transação, concede somente acesso inicial ao recurso criado e registra audit/idempotência. Smoke SQL foi revertido após sucesso; 58 testes, lint e typecheck passaram. Update/archive e gestão separada de associação foram implementados em fatias seguintes.
- Atribuição de papéis em recursos: migrations `20261027175329_assign_resource_roles.sql`, `20261027175837_list_resource_grant_targets.sql` e `20261027180442_move_resource_targets_private.sql` criam `membership.grant` Tenant-scoped, RPC/API e lista protegida de recursos ativos; a consulta privilegiada fica no schema privado e o wrapper público usa `SECURITY INVOKER`. Workspace inclui formulário por membro para conceder papel em Portfolio/Project. A operação rejeita deny, autoatribuição, Tenant Admin em scope de recurso e cruza Tenant, valida compatibilidade do papel, suporta replay idempotente e registra audit atomicamente. Smoke DEV passou com rollback; lint, typecheck e 55 testes passaram. CRUD de recursos e validação real com segunda membership ainda pendem.
- Convites com grants exatos de Tenant, Portfolio ou Project: as migrations `20261027165200_invite_members_at_resource_scopes.sql` e `20261027165727_list_delegable_invitation_scopes.sql` validam recurso same-Tenant, `membership.invite`, teto de delegação por permission no scope, deny, Auth confirmado e grant/audit atômicos. A API/UI lista somente recursos onde ao menos um papel é delegável. Smoke no DEV cobriu emissão/aceite nos três scopes, cross-Tenant e deny com rollback; 55 testes, lint e typecheck passaram.
- Política de domínio para delegação scoped: `getRolePermissionsForScope` filtra permissões de preset pelo scope permitido no catálogo, e `canDelegateRole` exige concessão exata do emissor no recurso além de `membership.invite` no Tenant. Quatro testes adicionados; validação local passou com 52 testes, lint e typecheck. As RPCs ainda não aceitam convites por Portfolio/Project.
- Fundação DB inicial de Portfolio/Project aplicada no Supabase DEV nas migrations `20261027163212_portfolio_project_scope_foundation.sql` e `20261027163415_index_portfolio_project_foreign_keys.sql`: tabelas `portfolios`, `projects`, vínculo temporal `portfolio_projects` e referências de scope de `access_grants` com FKs compostas same-Tenant. RLS está ativo e grants diretos permanecem revogados enquanto não há boundary/API de negócio. Smoke SQL transacional confirmou relações same-Tenant, rejeição cross-Tenant (`23503`), grants de scope válidos e ausência de acesso direto; rollback não deixou fixtures.
- A lista de papéis do convite comum agora considera permissões dos presets do ator e compatibilidade com o scope Tenant. O teste sintético confirmou emissão/aceite de Tenant Admin, com membership, grant e audit revertidos; a validação real aguarda segunda conta Auth. Papéis de produto ainda dependem de suporte a scope Portfolio/Project.
- Tenant Admin/PMO Admin can suspend and reactivate another membership with reason, version check and atomic audit. Suspension preserves grants; the last active Tenant Admin and self-transitions are protected. Migration `20261027155632_manage_tenant_membership_lifecycle.sql` applied to DEV; positive transitions, versions, retained grant and audit validated in a rolled-back transaction; no fixtures remain.
- Revogação administrativa de membership por Tenant com motivo, versão esperada, proteção do último administrador, grants revogados e audit atômico. Migration `20261027154433_revoke_tenant_membership.sql` aplicada ao DEV; fixtures transacionais validaram autorização, permission deny, versão obsoleta e proteção do último administrador sem deixar dados persistentes.

- Convites comuns de membros com ceiling transacional RBAC, token hash-only de sete dias, reemissão/revogação auditada, aceite com e-mail Auth confirmado e formulário de link manual no workspace; migration aplicada no DEV como `20261027135220_invite_tenant_members_with_delegation.sql`.
- Migration forward-fix `20261027135719_fix_invitation_grant_payload_validation.sql` substitui `jsonb_object_length`, indisponível no PostgreSQL do DEV, por validação estrutural JSONB compatível; função aplicada e metadata confirmada.

- Preparada infraestrutura Supabase SSR para Next.js 16 com dependências fixadas, clientes cookie-based de servidor/browser e Proxy que verifica/renova JWT por `getClaims()`. Login segue inativo até migration/RLS e validação de membership; guia local atualizado para chave publicável.

- Projeto Supabase `PMO Control` designado como DEV; migration `20261026163821_restrict_rls_event_trigger_execution.sql` remove execução por API da função SECURITY DEFINER usada pelo event trigger de RLS, sem desativá-lo. O probe confirmou que novas tabelas recebem RLS e os advisors ficaram sem findings.

- Iniciados F1-01/F1-13: revisão parcial de Identity & Access, avaliador puro de autorização por escopo exato e testes negativos de domínio. Workflow web inclui testes; Auth, migrations, RLS, herança e delegação permanecem pendentes.

- Primeira tela de acesso da SPEC-001 em `apps/web`: layout responsivo pt-BR com campos de e-mail/senha, recuperação e orientação de convite; controles permanecem desabilitados até integração segura com Auth. ESLint, TypeScript e build de produção passaram localmente em 2026-10-26; revisão visual pelo navegador isolado não foi possível.
- Findings semânticos e remediações registradas em `SDD-AUDIT-REPORT.md`.
- Contratos de cálculo determinístico `rag-v1` e snapshot imutável/hash `snapshot-v1` nas Specs 015/016, PDD, Data, API e Testing.
- Cadência mensal, checklist de publicação e fórmulas reproduzíveis `kpi-v1` definidos na Spec 014 e refletidos em PDD, banco, API, UX e casos de teste.
- Matriz explícita de presets RBAC e shape de contexto RLS confiável adicionados; políticas de segurança e UX de Status mantidas em Draft até verificação.
- Achados F-006/F-008 avançados: roles/denies e contexto RLS detalhados; passos UX de Status mapeados a FR/permission/AC/TC. Manifests dos domínios não reauditados rebaixados para Draft.
- Adicionado crosswalk inicial para 32 telas UX, depois ampliado para 33 com a configuração/uso de IA por Tenant; inclui telas de administração de Tenant/acesso e índice central de rotas/allowlists de API.
- Criado coverage register RLS para as tabelas canônicas; anotado que execução não é possível neste workspace, que contém apenas documentação. A contagem atual reconciliada é 58, com uma linha por tabela.
- Corrigidos os mapas FR/AC/TC de Multi-Tenancy, RBAC e Audit; varreduras estáticas confirmaram IDs válidos nas 29 Specs e nenhum link Markdown local ausente.
- Fechadas recomendações de transferência de administrador Tenant e contestação de export; rastreabilidade e política export-first atualizadas.
- Audit report registra os gates de runtime indisponíveis porque este workspace contém somente documentação; nenhum teste de aplicação foi alegado.
- Adicionadas as tabelas canônicas `tenant_export_disputes`, `decision_comments` e `notification_preferences`, com cobertura RLS; inventário atualizado para 58 tabelas.
- Auditoria de acompanhamento identificou que várias Specs ainda contêm cláusulas genéricas em DB/API/AC/testes; relatório mantém F-004/F-007 abertos e distingue validação estática de aprovação semântica.
- Aprofundados contratos de banco e API por operação nas Specs 004–013, 020–022, 024–026 e 028–029; estados, prioridade, relacionamentos, constraints e grants foram alinhados ao PDD/RBAC.
- Reconciliados relacionamentos canônicos de TenantExportDispute, DecisionComment e NotificationPreference no modelo de dados e no registro RLS.
- SPEC-025/PDD atualizados para credenciais BYOK próprias por Tenant, três modelos de complexidade, roteamento automático determinístico/versionado e ledger append-only de uso/custo com permissões segregadas.
- Adicionadas APIs lógicas para configurar/validar/rotacionar/desabilitar provider, consultar/exportar gastos e uma tela administrativa de configuração/uso; telemetria diferencia valores reportados, estimados e indisponíveis.
- Catálogo de dados/RLS expandido de 58 para 60 tabelas (`ai_provider_configs`, `ai_usage_records`); roteabilidade e tela nova ligada à rastreabilidade UX, PDD, RBAC e eventos.
- Allowlist MVP de provedores AI definida: OpenAI GPT, Google Gemini, Anthropic Claude, Meta Llama, DeepSeek e OpenRouter; adapters/capabilities são validados, IDs de endpoint ficam na allowlist da plataforma e credenciais/modelos permanecem separados por Tenant/provedor.
- Adicionada à SPEC-028 a importação de dataset de projeto por workbook `.xlsx` v1 com template vazio e exemplo sintético, seletor tenant-scoped, validação por célula, carga inicial sem prompt, modo append insert-only e restart atômico protegido que preserva o histórico imutável.
- Definidos valores padrão iniciais por Tenant para tipos/criticidade de marcos, categorias/tendências de riscos e origem de ações; Specs 007/009/011, seed de referência, contrato de importação, guia leigo e validações das planilhas alinhados.
- Criada a fundação da aplicação em `apps/web` com Next.js + TypeScript, layout inicial em pt-BR, health endpoint, regras de organização modular, exemplo de ambiente e workflow de CI. Nenhum módulo de negócio ou schema de banco foi iniciado.
- Preparação para desenvolvimento local: workflow GitHub Actions de lint/typecheck/build, Supabase local versionado, Node.js fixado, `.gitignore` raiz e guia de provisionamento; primeira migration e configuração de serviços hospedados permanecem portões da fatia Identity & Access.
- CI remoto executado com sucesso após gerar os tipos do Next antes do typecheck; checklist e setup atualizados com o estado verificado.
- Matriz RLS normalizada para listar individualmente cada uma das 60 tabelas canônicas; reconciliação estática encontrou correspondência 60/60, sem substituir execução de políticas.
- Corrigida a nulabilidade de orçamento/forecast financeiro antes da baseline aprovada; índice de Issues alinhado a `priority` e nível de Risk à avaliação atual.
- Endpoints das Specs agora distinguem payloads lógicos definidos do contrato OpenAPI compilável ainda pendente; checagem final de links locais passou (0 quebrados) e 29 pastas de Specs foram encontradas.

-   Root documentation governance files.
-   Master README.
-   Master Manifest.
-   Master Traceability.
-   Dependency Map.
-   Implementation Plan.
-   MVP Checklist.
-   Documentation Changelog.

### Changed

- Documentação de desenvolvimento alterada para usar projeto Supabase hospedado e isolado como ambiente dev; migrations via CLI e validações SQL via `psql`, sem Docker. `supabase start`, reset remoto e uso de projeto de produção ficam fora do fluxo.

- Revisão F1-01 alinhou RLS ao JWT `auth.uid()` por chamada PostgREST, retirou GUC de contexto no boundary HTTP, definiu `access_grants` como atribuição de Role, fechou fluxo seguro de convite e corrigiu idempotência de audit com Tenant nulo. Login/sessão, transições de lifecycle e implementação/testes de banco permanecem pendentes.

- Status de aprovação das Specs alterado para Draft até revisão semântica.
- Contratos iniciais de autenticação, multi-tenancy e publicação de status detalhados; critérios/testes transacionais de Status adicionados.
- Publicação no PDD esclarece atomicidade autoritativa e efeitos assíncronos pós-commit.
- Manifest e Traceability agora declaram o limite da cobertura atual.
- Decisões MVP registradas: email/senha (MFA posterior, sem SSO), lifecycle de tenant pela plataforma, memberships múltiplas, convite de 7 dias, quotas por plano, encerramento export-first, defaults de retenção, suporte JIT e publicação/correção direta por PM autorizado.
- Alinhados workflow de Status e política de publicação direta entre PDD, journeys, functional map, MVP scope, foundation, architecture, API, Specs e workflow tests; approval por segunda pessoa removida como requisito padrão.
- Defaults de retenção por categoria e encerramento export-first documentados, sujeitos à revisão jurídica/contratual.
- Baseline SDD 1.0 permanece bloqueada até remediação restante e re-auditoria.
- Matriz de rastreabilidade reforçada para publicação → RAG → snapshot → API/permissões/AC/testes; outros domínios ainda precisam revisão equivalente.

### Deprecated

-   None.

### Removed

-   None.

### Security

-   None.

### Architecture

-   Estrutura documental principal consolidada de `00-foundation` a
    `13-guides`.

## Regras de atualização

Registrar aqui mudanças como: - novo módulo/Spec; - alteração de
workflow crítico; - mudança de modelo de autorização; - mudança
arquitetural importante; - nova integração oficial; - mudança de
estratégia de AI/BYOK; - alteração de snapshot/RAG/publicação; -
depreciação ou remoção de capacidade; - mudança relevante de segurança.

Correções ortográficas e ajustes editoriais sem efeito semântico não
precisam de entrada individual.
- Adicionadas exclusão definitiva de Project por entitlement exclusivo Platform Root Admin (com confirmação, purge retomável e retenção histórica) e interação global Box Focus por duplo clique/teclado; Specs 003/005, PDD, UX, retenção, segurança, API e rastreabilidade atualizados.
- Plano de desenvolvimento refeito como checklist vivo por fase, com dependências, IDs de tarefa, gates verificáveis e estado atual do GitHub/Supabase; painel MVP alinhado à conexão real e à ausência de migrations.

## 2026-10-27

- Padronizados erros de API versionada com `requestId` no envelope e `X-Request-Id`; handlers inesperados passaram a emitir logs correlacionáveis sem serializar payloads ou mensagens de exceção.
- Checklist atualizado após 68 testes passando, lint e typecheck aprovados. A cobertura de logging de falhas de dependência segue em revisão.

- Mutações de Portfolio/Project agora registram falhas RPC não classificadas com SQLSTATE validado, além de respostas de dependência inválidas ou fora do escopo.

- Todas as respostas HTTP 5xx passaram a gerar log JSON correlacionado; duplicatas por requisição são suprimidas. Build de produção e 69 testes passaram, além de lint e typecheck.

- Publicado o commit `9697590` em `main`; a execução GitHub Actions `40594741068` passou em todos os jobs, incluindo o smoke remoto de RLS no Supabase DEV.
- Confirmada no DEV a trilha separada dos Auth Audit Logs do Supabase para login/logout/signup e ciclos de token; requisitos e checklist agora distinguem auditoria do provedor de eventos de domínio.

- Revisado o plano de fase: contexto de sessão, fronteiras RPC/RLS e catálogo/grants foram concluídos; regressão negativa por rota continua contabilizada em F1-13.
