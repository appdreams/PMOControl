# Camada server-side

Route Handlers são pontos de entrada HTTP, não o lugar para concentrar SQL, autorização e regras de negócio. Eles validam a requisição e chamam um caso de uso do módulo responsável.

- Não confiar em Tenant, usuário, role ou permission enviados no body/query.
- Resolver sessão e contexto autorizado no servidor para cada operação.
- Validar dados externos em runtime; tipos TypeScript não validam arquivos ou requests.
- Manter segredos apenas em variáveis server-side e nunca retorná-los ao browser ou registrá-los em logs.
- Usar transações PostgreSQL para invariantes críticas; tarefas não críticas e demoradas seguem o fluxo Inngest.
- Manter a regra de domínio independente de Next.js e dos SDKs de infraestrutura.

O health endpoint público em `src/app/api/health/route.ts` revela somente o estado geral do serviço.
