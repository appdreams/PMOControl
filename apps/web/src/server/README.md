# Camada server-side

Route Handlers são pontos de entrada HTTP, não o lugar para concentrar SQL, autorização e regras de negócio. Eles validam a requisição e chamam um caso de uso do módulo responsável.

- Não confiar em Tenant, usuário, role ou permission enviados no body/query.
- Resolver sessão e contexto autorizado no servidor para cada operação.
- Use `resolveSupabaseRequestContext(tenantSelector)` from the server-only Supabase infrastructure adapter. It verifies `getClaims()`, reloads the actor's active memberships and Tenant states on every call, and generates a fresh server correlation ID. A selector never proves access; the adapter returns only a Tenant verified through current membership.
- Treat `context_unavailable` as a fail-closed backend/RLS error (503); do not convert it into “no memberships” or continue to a data operation. F1-05 grants only the resolver's self-membership/active-Tenant reads; positive and negative two-Tenant authorization checks are still required before route integration.
- Validar dados externos em runtime; tipos TypeScript não validam arquivos ou requests.
- Manter segredos apenas em variáveis server-side e nunca retorná-los ao browser ou registrá-los em logs.
- Usar transações PostgreSQL para invariantes críticas; tarefas não críticas e demoradas seguem o fluxo Inngest.
- Manter a regra de domínio independente de Next.js e dos SDKs de infraestrutura.

O health endpoint público em `src/app/api/health/route.ts` revela somente o estado geral do serviço.
