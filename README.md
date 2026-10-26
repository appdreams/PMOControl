# PMO Control

Plataforma de governança e acompanhamento de projetos e portfólios.

## Aplicação

A aplicação web inicial fica em [`apps/web`](apps/web). O stack definido é Next.js + TypeScript, Supabase/PostgreSQL/Auth/Storage e Inngest, conforme os ADRs em [`docs/03-adrs`](docs/03-adrs).

```powershell
cd apps/web
pnpm dev
```

Abra `http://localhost:3000` no navegador. Use `pnpm lint`, `pnpm typecheck` e `pnpm build` nessa pasta conforme a implementação avançar.

Para provisionar o ambiente local, iniciar o Supabase e entender os serviços que ainda precisam de credenciais, consulte [`docs/12-devops/development-setup.md`](docs/12-devops/development-setup.md).

## Organização

- [`docs/`](docs): documentação do produto, Specs, UX, dados, segurança e operação.
- [`apps/web/`](apps/web): aplicação Next.js.
- `apps/web/src/modules/`: módulos de domínio do monólito modular.
- `apps/web/src/shared/`: recursos realmente compartilhados entre módulos.
- `apps/web/src/server/`: composição server-side e infraestrutura, sem regras escondidas em rotas ou componentes.
