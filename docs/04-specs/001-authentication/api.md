# SPEC-001 — Authentication — API

**Status:** Draft — implementação parcial; validação integrada pendente

## Provider e limites

Login/logout/recuperação de senha usam Supabase Auth com e-mail e senha. MFA e SSO Google/Microsoft não fazem parte do MVP. Segredos e tokens são tratados pelo provider e nunca enviados a APIs de negócio como prova isolada de tenant permission.

## Operações lógicas

- Login delega e-mail/senha a `supabase.auth.signInWithPassword` no browser; erros públicos não distinguem conta inexistente de credencial inválida.
- `POST /api/v1/auth/logout`: valida Origin/Host e encerra somente a sessão atual (`scope: local`).
- `GET /api/v1/me/profile`: retorna o nome de exibição e se o usuário concluiu o próprio perfil; resposta `private, no-store`.
- `PATCH /api/v1/me/profile`: grava um nome de exibição de 2 a 120 caracteres somente para o ator autenticado; valida Origin/Host e não aceita `user_id` no payload.
- Recovery usa `supabase.auth.resetPasswordForEmail` com resposta neutra; `/auth/callback` troca o código PKCE por sessão SSR.
- Redefinição autenticada usa `supabase.auth.updateUser({ password })`; após sucesso, encerra a sessão local.
- `GET /api/session`: retorna ator mínimo e memberships ativas autorizadas.
- `POST /api/session/tenant`: seleciona membership ativa; servidor invalida contexto/caches anteriores e resolve permissions novamente.
- Convites e criação/administração de memberships são definidos na Spec 002; não criar membership via endpoint genérico de auth.

## Segurança e erros

Aplicar rate limit a login/recovery; validar e-mail e payload server-side; não registrar credenciais/tokens; usar cookies/headers seguros definidos pela arquitetura. `401` para credencial/sessão inválida; `403` para membership sem acesso; recovery usa resposta indistinguível para endereço existente/inexistente. Toda operação de negócio revalida sessão e membership; client-supplied `actor_id`, role ou `tenant_id` não autorizam.

## Contrato de sessão e navegador

- Access token JWT: 3.600 segundos; refresh-token rotation do Supabase permanece habilitada. O projeto DEV está no plano Free e, portanto, não declara timeout absoluto ou por inatividade fornecido pelo provider. A decisão é um gate antes de produção: habilitar os controles do provider após mudança de plano ou entregar política de idade de sessão na aplicação.
- Cookies SSR: host-only, `Path=/`, `SameSite=Lax`, `Secure` em HTTPS; sem `HttpOnly` (o cliente Supabase no browser precisa ler o refresh token) e sem `Max-Age`/`Expires` curto customizado. Respostas de refresh/sessão usam `Cache-Control: private, no-store`.
- `POST`/métodos inseguros vindos do navegador validam `Origin` contra a origem da aplicação e `Host`; rejeitar origem ausente ou divergente quando a chamada usa cookie.
- Logout padrão encerra a sessão atual com escopo local; logout global exige ação explícita. Para operação que exija percepção imediata de revogação de conta/sessão, consultar o provider (`getUser`); `getClaims` verifica assinatura/expiração, não revogação server-side de um JWT ainda válido.
- Falha de login anterior a ator verificado fica nos logs do Supabase Auth. Não gravar email/IP não verificados no audit da aplicação.

## Pendências técnicas

Rate-limit adicional da aplicação, SMTP customizado por ambiente, validação integrada com credenciais reais e gate de idade de sessão para produção permanecem pendentes. A allowlist DEV inclui `http://localhost:3000/auth/callback`; não alterar o escopo MVP confirmado (email/senha apenas).
