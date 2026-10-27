# API Authentication & Authorization

**Status:** Draft — align with SPEC-001/002/003 and trusted RLS context

## Pipeline obrigatório

1.  Authenticate.
2.  Resolve Tenant.
3.  Resolve Membership.
4.  Resolve Scope.
5.  Check Permission.
6.  Apply Data Policy.
7.  Apply Workflow Rule.
8.  Execute.

## Fórmula

`Effective Access = Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

## Proibições

-   confiar em `tenantId` enviado pelo cliente como autoridade;
-   autorizar somente porque resource UUID existe;
-   depender de controle oculto na UI;
-   usar service role como bypass genérico.

## Boundary de identidade e banco

- O app usa Supabase SSR com cookies e Data API/PostgREST autenticada pelo JWT verificado do usuário; nenhuma decisão de autorização confia em `getSession()` ou em metadata editável do JWT.
- O servidor verifica identidade com `getClaims()` (e consulta `getUser()` quando precisa de dados atuais da conta). Cada operação de negócio resolve `auth.uid()`, Tenant e membership vigentes na própria chamada ao banco.
- O resolver server-side cria um `correlation_id` UUID por request, verifica `sub` do JWT e consulta memberships ativas com Tenant ativo via relação PostgREST; não usa cache. O Tenant recebido na rota é apenas seletor: uma membership ativa pode ser selecionada automaticamente, múltiplas exigem escolha explícita e nenhuma/uma seleção inválida retorna deny. IDs disponíveis para escolha vêm somente das memberships do ator verificado.
- Erro de leitura de membership/RLS retorna `context_unavailable` (503); não deve ser tratado como lista vazia ou ausência de membership. F1-05 agora concede somente `SELECT` restrito ao próprio `auth.uid()` para membership ativa e Tenant ativo; testes positivos/negativos de dois Tenants ainda são gate antes de conectar rotas.
- Tenant enviado/selecionado é apenas um seletor. Policies verificam a membership ativa do `auth.uid()` no Tenant do recurso e o estado ativo do Tenant; nenhuma API aceita contexto transaction-local `app.actor_id`/`app.tenant_id` no caminho PostgREST.
- Operações com múltiplas escritas e audit atômicos usam RPC PostgreSQL autenticada no mesmo request/transaction, normalmente `SECURITY INVOKER`; policies e constraints continuam aplicadas. Helpers privilegiados, se indispensáveis para evitar recursão de RLS, ficam em schema não exposto e seguem revisão de função privilegiada.
- A aplicação não usa `service_role` para consultas de usuário nem conexão direta PostgreSQL até existir ADR próprio para outro boundary.
- JWT de acesso tem 3.600 s e refresh-token rotation fica habilitada. O projeto DEV Free não oferece timeout provider de sessão absoluta/inatividade; é gate pré-produção, resolvido por controles do provider em plano compatível ou política de idade de sessão implementada e testada na aplicação.
- Cookies SSR são host-only, `Path=/`, `SameSite=Lax` e `Secure` em HTTPS. Não adicionar `HttpOnly` ao cookie gerenciado pelo browser Supabase, nem expiração curta customizada. Refresh e conteúdo personalizado retornam `Cache-Control: private, no-store`.
- Requisições browser com cookie e método inseguro validam Origin/Host. Logout comum usa escopo local. Use consulta atual ao provider quando o caso de uso exigir detecção imediata de sessão revogada; `getClaims()` sozinho valida JWT ainda não expirado, não estado server-side da sessão.
- `POST /api/v1/session/tenant` exige `Origin` igual a `APP_ORIGIN` e `Host` correspondente. `APP_ORIGIN` é obrigatório em produção; em desenvolvimento local, o default é `http://localhost:3000`. A seleção é apenas resposta/seletor e não é persistida como autoridade.
- Eventos de audit da aplicação exigem ator verificado; tentativas pré-auth ficam no log do provider e não persistem email/IP não verificados.

## AI

Endpoints de Copilot obedecem exatamente ao contexto autorizado do
usuário.
