# Ambiente de desenvolvimento

**Status:** Preparado para iniciar a primeira fatia de implementação; serviços externos e primeiro contrato de banco ainda precisam ser habilitados.

## Ferramentas locais

- Node.js `24.12.0` (fixado em `.nvmrc`).
- pnpm `11.25.0` (fixado no `package.json` da aplicação).
- Git.
- Docker Desktop e Supabase CLI para executar Supabase local.

## Iniciar a aplicação

No PowerShell, a partir da raiz do repositório:

```powershell
cd apps/web
pnpm install --frozen-lockfile
Copy-Item .env.example .env.local
pnpm dev
```

Abra `http://localhost:3000`. A página inicial e `GET /api/health` funcionam sem credenciais externas. Os comandos de qualidade são `pnpm lint`, `pnpm typecheck` e `pnpm build`.

## Supabase local

`supabase/config.toml` define os serviços locais de Auth, Postgres, Storage, Studio e caixa de e-mail de desenvolvimento. Com Docker Desktop e Supabase CLI instalados, na raiz do repositório:

```powershell
supabase start
supabase status
```

Copie o Project URL e a chave `anon` mostrados por `supabase status` para `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_ANON_KEY` em `apps/web/.env.local`. O Inbucket local recebe mensagens de autenticação; não envie e-mails reais pelo ambiente local.

O cadastro público está desabilitado para respeitar o modelo de acesso por convite. A autenticação da aplicação ainda não foi conectada ao Supabase.

## Segurança de configuração

- `.env.local` e demais arquivos `.env.*` ficam fora do Git; somente `.env.example` é versionado.
- Nunca use chaves `service_role`, senha do banco ou segredos em variáveis `NEXT_PUBLIC_*`.
- A chave `anon` pode ser usada no cliente apenas depois da implementação das políticas RLS; ela não concede autorização de negócio.
- Credenciais de desenvolvimento, preview e produção devem ser distintas.
- Nenhuma credencial real ou projeto hospedado foi configurado neste repositório.

## Integrações e deploy

O workflow `.github/workflows/ci.yml` roda lint, verificação TypeScript e build nas alterações da aplicação. A primeira execução no repositório conectado passou no commit `efd6d159`. O workflow não aplica migrations nem faz deploy.

Vercel, Supabase hospedado, Inngest e SMTP precisam ser provisionados pela equipe responsável. Adicione as variáveis de cada ambiente no gerenciador de segredos do serviço; não as inclua no Git. Inngest e SMTP entram quando os respectivos fluxos forem implementados.

## Portão para a primeira fatia vertical

O bootstrap permite iniciar UI e código de domínio sem depender de serviços hospedados. Antes de implementar persistência/autenticação multi-tenant, concluir e revisar a primeira migration para Identity & Access (`user_profiles`, `tenants`, `memberships`, `roles`, `permissions`, `role_permissions`, `access_grants`), suas policies RLS e testes negativos de isolamento. Não conectar dados de clientes nem criar projeto Supabase de produção antes desses controles.

## Provisionamento para equipe

1. Clonar o repositório e instalar as versões listadas em Ferramentas locais.
2. Copiar `.env.example` para `.env.local`.
3. Para trabalho de UI/domínio, iniciar Next.js localmente.
4. Para trabalho de banco/Auth, iniciar Supabase local e usar apenas dados sintéticos.
5. Abrir Pull Request; o workflow executa as três verificações de qualidade.
6. Configurar serviços hospedados e segredos apenas após aprovação do responsável por infraestrutura.
