# PMO Control Web

Aplicação Next.js + TypeScript do PMO Control.

## Desenvolvimento local

Requer Node.js `24.12.0` e pnpm `11.25.0`. Na primeira instalação, execute:

```powershell
pnpm install
pnpm dev
```

O servidor abre em `http://localhost:3000`. Copie `.env.example` para `.env.local`; configure `APP_ORIGIN` somente quando usar outra origem local. Em produção, `APP_ORIGIN` é obrigatório para validar requests autenticadas por cookie. Consulte [`docs/12-devops/development-setup.md`](../../docs/12-devops/development-setup.md) para configurar o projeto Supabase hospedado de desenvolvimento. O app Next roda localmente sem Docker. Nunca coloque credenciais privadas em variáveis `NEXT_PUBLIC_*`.

## Comandos

- `pnpm dev` — servidor local.
- `pnpm lint` — análise estática.
- `pnpm typecheck` — verificação de tipos TypeScript.
- `pnpm build` — compilação para produção com Webpack; o servidor de desenvolvimento usa Turbopack.
- `pnpm start` — servir a compilação.

## Arquitetura

As regras de domínio ficam independentes do Next.js em `src/modules`. Route Handlers são entradas server-side; casos de uso mediam acesso ao domínio e à infraestrutura. Operações com efeitos externos ou duração longa devem usar Inngest. Veja `src/modules/README.md` e `src/server/README.md`.
