# Ambiente de desenvolvimento

**Status:** UI/domínio executam localmente; Auth/banco dependem de um projeto Supabase hospedado exclusivo para desenvolvimento.

## Ferramentas locais

- Node.js `24.12.0` (fixado em `.nvmrc`).
- pnpm `11.25.0` (fixado no `package.json` da aplicação).
- Git.
- Supabase CLI para associar o repositório e aplicar migrations no projeto de desenvolvimento.
- `psql` para executar validações SQL no banco hospedado de desenvolvimento.

O fluxo documentado não inicia serviços de banco locais com Docker.

## Iniciar a aplicação

No PowerShell, a partir da raiz do repositório:

```powershell
cd apps/web
pnpm install --frozen-lockfile
Copy-Item .env.example .env.local
pnpm dev
```

Abra `http://localhost:3000`. A página inicial e `GET /api/health` funcionam sem credenciais externas. Os comandos de qualidade são `pnpm lint`, `pnpm typecheck` e `pnpm build`.

Se outra instância ou um lock residual estiver usando `.next`, inicie o servidor com uma pasta de saída isolada: no PowerShell, `$env:NEXT_DIST_DIR='.next-local'; pnpm dev`. Essa pasta permanece ignorada pelo Git.

## Supabase de desenvolvimento hospedado

Use um projeto Supabase hospedado e dedicado ao desenvolvimento, separado de preview/produção e com dados exclusivamente sintéticos. O projeto `PMO Control` (`xsznvegtaukrvvrgubnn`) foi designado DEV em 2026-10-26 e recebeu as migrations iniciais de Identity & Access. Antes de qualquer operação, confira o project ref e confirme que os dados continuam exclusivamente sintéticos.

```powershell
supabase login
supabase link --project-ref <DEV_PROJECT_REF>
supabase migration list --linked
supabase db push --linked --dry-run
```

Revise o SQL e a lista antes de aplicar. Então aplique apenas no projeto de desenvolvimento com `supabase db push --linked` e confira o histórico com `supabase migration list --linked`. O arquivo `supabase/seed.sql` mantém dados de catálogo idempotentes. Depois de confirmar o dry-run, `supabase db push --linked --include-seed` aplica migrations pendentes e executa o seed remoto; esse comando exige a CLI autenticada e corretamente vinculada ao DEV. Os presets de Tenant só são materializados junto ao onboarding de um Tenant real.

Para validar RLS sem Docker, execute `supabase/tests/context_rls_smoke.sql` usando `psql` e a URL direta do banco DEV:

```powershell
psql --no-psqlrc --set ON_ERROR_STOP=1 --file supabase/tests/context_rls_smoke.sql $env:SUPABASE_DB_URL
```

O script cria usuários, tenants e memberships sintéticos em uma transação, assume `authenticated`, verifica contexto ausente, isolamento entre dois atores, membership revogada e privilégios somente de leitura, e termina com `ROLLBACK`. O workflow executa esse smoke check em `push` para `main` ou manualmente na branch `main`, dentro do GitHub Environment protegido `supabase-dev`; pull requests executam somente os quality gates sem receber secrets. Configure nesse Environment o secret `SUPABASE_DB_URL` (URL PostgreSQL direta do DEV, usando credencial administrativa de banco) e a variável `SUPABASE_PROJECT_REF=xsznvegtaukrvvrgubnn`. O workflow falha se o ref não corresponder ao DEV designado. Não armazene a URL em repositório, logs ou `.env.example`. O comando `supabase test db` fica fora do fluxo porque executa `pg_prove` em um container. Nunca use essa URL em produção.

Não use `supabase start` nem `supabase db reset --linked`: o reset remoto apaga o schema do projeto conectado. `supabase/config.toml` permanece versionado para comandos da CLI e configurações do projeto.

Referências: [Supabase CLI `db push`](https://supabase.com/docs/reference/cli/supabase-db-push), [Supabase CLI `test db`](https://supabase.com/docs/reference/cli/supabase-test-db) e [fluxo local/linked do Supabase](https://supabase.com/docs/guides/local-development/cli-workflows).

`apps/web/.env.local` está preenchido localmente com a URL e a chave publicável do DEV; o arquivo é ignorado pelo Git. Em outra máquina, copie Project URL e publishable key do DEV para `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, e defina `APP_ORIGIN=http://localhost:3000`. Recovery requer `http://localhost:3000/auth/callback` na allowlist de redirect URLs do Auth. O SMTP padrão do Supabase DEV só entrega a endereços da equipe da organização e é best-effort; use SMTP customizado para outros destinatários ou produção. Durante o desenvolvimento, direcione convites/recovery somente para contas da equipe.

O cadastro público está desabilitado para respeitar o modelo de acesso por convite. Login, recovery, redefinição de senha, logout local e workspace pós-login estão conectados. A URL `http://localhost:3000/auth/callback` foi incluída na allowlist do Auth DEV; a sessão real do operador foi validada em 2026-10-26. SMTP customizado permanece desativado, e o SMTP padrão tem limites de destinatários e entrega best-effort.

## Segurança de configuração

- `.env.local` e demais arquivos `.env.*` ficam fora do Git; somente `.env.example` é versionado.
- Nunca use chaves `service_role`, senha do banco ou segredos em variáveis `NEXT_PUBLIC_*`.
- A chave publicável não concede autorização de negócio; acesso depende de Auth e das policies RLS.
- Credenciais de desenvolvimento, preview e produção devem ser distintas.
- Nenhuma credencial de projeto é versionada nem está configurada no `.env.example`.

## Integrações e deploy

O workflow web atual roda lint, typecheck, testes de domínio e build; ele não aplica migrations.

O job atual de banco valida a policy de contexto já aplicada no projeto DEV com `psql`; ele não aplica migrations. O Environment `supabase-dev` precisa de aprovação/regras de branch conforme a governança do repositório. Aplicação automática de migrations fica para um gate separado, com dry-run e revisão explícita. Não requer Docker, não usa secrets em pull requests e não faz deploy para produção.

Vercel, Supabase hospedado, Inngest e SMTP precisam ser provisionados pela equipe responsável. Adicione as variáveis de cada ambiente no gerenciador de segredos do serviço; não as inclua no Git. Inngest e SMTP entram quando os respectivos fluxos forem implementados.

## Portão para a primeira fatia vertical

Antes de conectar persistência/autenticação multi-tenant, concluir e revisar a primeira migration de Identity & Access (`user_profiles`, `tenants`, `memberships`, `roles`, `permissions`, `role_permissions`, `access_grants`), suas policies RLS e testes negativos de isolamento no projeto hospedado de desenvolvimento. Confira o project ref em cada aplicação; não use produção para validar migrations.

### Bootstrap do primeiro operador da plataforma no DEV

O bootstrap é um procedimento manual único, não uma rota web nem uma migration. O arquivo `supabase/operations/bootstrap-first-platform-admin.sql` só deve ser executado pelo dono do projeto no SQL Editor após confirmar o ref `xsznvegtaukrvvrgubnn`, substituir pelo e-mail normalizado de uma conta Auth já existente e confirmada e revisar o motivo. O script falha fechado se o placeholder permanecer, a conta não existir/ser ambígua, o papel/premissão esperados estiverem ausentes ou qualquer grant de plataforma não revogado já existir. A transação insere o grant `platform_admin` e o audit correspondente juntos. Não execute em preview/produção, nem crie grants de plataforma via endpoint público. Após bootstrap, valide a conta com sessão autenticada antes de chamar `POST /api/v1/tenants`.

## Provisionamento para equipe

1. Clonar o repositório e instalar as versões listadas em Ferramentas locais.
2. Copiar `.env.example` para `.env.local`.
3. Para trabalho de UI/domínio, iniciar Next.js localmente.
4. Para trabalho de banco/Auth, usar o projeto hospedado de desenvolvimento com Supabase CLI/psql e dados sintéticos.
5. Abrir Pull Request; CI executa quality gates e, quando habilitado, migrations/testes SQL no projeto remoto de desenvolvimento.
6. Configurar credenciais hospedadas em secrets protegidos do ambiente correspondente.
