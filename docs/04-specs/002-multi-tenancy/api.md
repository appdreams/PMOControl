# SPEC-002 — Multi-Tenancy — API

**Status:** In progress — Tenant provisioning, invitations, membership lifecycle and export generation/download/notification are implemented; dispute, legal hold and purge endpoints remain pending.
**Spec:** 002  
**Módulo:** Multi-Tenancy

## Contexto e autorização

Tenant context é derivado da sessão/membership verificada no servidor. O cliente não escolhe um `tenant_id` arbitrário para ampliar acesso. Todas as rotas administrativas ainda aplicam permission e scope server-side.

## Operações de domínio

- `POST /api/v1/tenants`: recebe `displayName`, `reason` e `idempotencyKey`; o servidor deriva o slug determinístico a partir do nome e provisiona Tenant, os sete roles/presets e o evento de audit na mesma transação. Requer sessão de plataforma e permission `tenant.lifecycle.create`. A fatia entregue não cria membership para o operador; o primeiro administrador deverá ser ativado por convite antes de o Tenant ficar operacional.
- `GET /api/v1/tenants`: lista somente Tenants visíveis ao ator conforme política de plataforma.
- `GET /api/v1/tenants/{tenantId}`: requer acesso administrativo ao Tenant; recursos de outro Tenant retornam resposta não reveladora.
- `GET /api/v1/tenants/{tenantId}/members`: requer membership ativa, Tenant ativo e grant exato `membership.view`; deny correspondente prevalece. Retorna ID, nome de exibição, status, versão e papéis concedidos no scope Tenant, sem e-mail, token ou grants de outros scopes. Implementado pela migration `20261027132120_list_tenant_membership_boundary.sql` e pela rota protegida.
- `POST /api/v1/tenants/{tenantId}/members/{membershipId}/revoke`: recebe `{ reason, expectedVersion, idempotencyKey }`. Exige sessão Auth, Origin/Host confiáveis, membership ativa e permission `membership.revoke` no Tenant exato sem deny. A RPC trava o Tenant e as memberships em ordem estável, impede auto-revogação e remoção do último Tenant Admin, confere a versão, revoga membership e todos os grants do usuário no Tenant e grava audit atomicamente. Replays com a mesma chave/payload retornam o resultado anterior; versões obsoletas e transições inválidas falham. A UI não oferece auto-revogação.
- `POST /api/v1/tenants/{tenantId}/members/{membershipId}/lifecycle`: recebe `{ transition: "suspend"|"reactivate", reason, expectedVersion, idempotencyKey }`. Exige sessão Auth, Origin/Host confiáveis e `membership.manage` no Tenant exato sem deny. A RPC trava Tenant e memberships, impede auto-transição, preserva grants durante suspensão e impede suspender o último Tenant Admin. Versão e audit são atômicos; membership revogada não pode ser reativada por esta rota.
- `PATCH /api/v1/tenants/{tenantId}`: altera campos administrativos permitidos; alterações de estado são comandos separados e auditados.
- `POST /api/v1/tenants/{tenantId}/suspend` e `/reactivate`: comandos administrativos, idempotentes, com motivo obrigatório e audit.
- `POST /api/v1/tenants/{tenantId}/invitations`: recebe `{ email, roleKey, reason }`; rota `apps/web/src/app/api/v1/tenants/[tenantId]/invitations/route.ts` gera token aleatório de 256 bits, persiste somente SHA-256 e retorna o link uma vez no fragmento `#token=`. A transação exige Tenant/membership ativos, `membership.invite` exato, papel Tenant de sistema e delegation ceiling completo contra o catálogo `rbac-v1`. Suporta somente escopo Tenant, expira em sete dias e uma nova emissão para mesmo endereço revoga convite pendente anterior; não envia e-mail.
- `GET /api/v1/tenants/{tenantId}/invitation-scopes`: exige Auth, membership e `membership.invite` no Tenant. Retorna somente Tenant/Portfolios/Projects onde o ator pode delegar pelo menos um papel, junto às role keys delegáveis naquele scope exato. Labels de recursos inacessíveis não são listadas.
- `POST /api/v1/tenants/{tenantId}/invitations`: aceita `{ email, roleKey, reason, scopeType?, scopeId? }`; se scope não for enviado, usa o Tenant da rota para compatibilidade. Para Portfolio/Project, a RPC resolve um recurso ativo do mesmo Tenant, exige teto de delegação para todas as permissões aplicáveis ao scope e persiste somente hash do token. Aceite com Auth confirmado revalida emissor, recurso, delegação e grava grant no scope exato na mesma transação da membership/audit. Expira em sete dias; link é manual e reemissão para mesmo e-mail revoga o convite pendente anterior.
- `POST /api/v1/invitations/{token}/accept`: valida token único/expirável, identidade verificada e membership resultante.
- `POST /api/v1/tenants/{tenantId}/invitations/first-admin`: recebe `{ email, reason }`; exige o operador criador do Tenant e grant vigente `tenant.lifecycle.create`, sem deny. Emite somente o preset `tenant_admin`, revoga convite pendente anterior e retorna o link uma única vez, com token no fragmento `#token=`. O sistema não envia e-mail.
- `POST /api/v1/tenants/{tenantId}/termination`: recebe `{ expectedVersion, reason, idempotencyKey }`; exige `tenant.lifecycle.terminate` em grant de plataforma vigente e sem deny. Só inicia a transição `active|suspended → termination_pending`, bloqueando operações normais e registrando audit atomicamente. O endpoint não gera export, não inicia o prazo de purge e não apaga dados; essas etapas dependem de artifact privado verificável, validação/entrega, retenção e checagem de hold/contestação.
- `POST /api/v1/tenants/{tenantId}/export`: solicita exportação com autorização da plataforma; o worker gera e verifica o artifact privado antes de iniciar a retenção de 90 dias.
- `POST /api/v1/tenant-exports/notifications`: o contato autenticado lista avisos de export disponível; o primeiro reconhecimento é idempotente e auditado.
- `POST /api/v1/tenant-exports/{exportId}/download`: o contato designado obtém o artifact privado com verificação de checksum; o primeiro download é auditado uma vez.
- `POST /api/v1/invitations/accept`: recebe `{ token }`; exige sessão Auth com e-mail confirmado correspondente. O RPC encaminha primeiro-admin e membro comum ao handler isolado correto. O convite comum revalida estado de Tenant/membership e delegation ceiling atual do emissor; consome link e cria/reactiva membership, grant e audit atomicamente. Resposta não revela Tenant/e-mail em falha.
- Acceptance requires provider-verified email matching the invite, atomically consumes the token and creates/reactivates Membership plus the scoped role assignment, and rechecks the issuer's delegation ceiling. The public response must not reveal whether a different email or Tenant exists.
- `GET /api/v1/session/tenants`: retorna somente memberships ativas do ator, como `{ tenants: [{ id, name }], selectedTenantId, correlationId }`. Se houver uma única membership ativa, ela é selecionada como sugestão da resposta; com múltiplas, `selectedTenantId` é `null`; sem memberships, retorna lista vazia. Não grava seleção nem transforma o ID em autoridade. Resposta usa `Cache-Control: private, no-store`; erros seguem o envelope global.
- `POST /api/v1/session/tenant`: recebe somente `{ tenantId }`, valida Origin/Host e confirma membership/Tenant ativos no servidor. Retorna `{ tenant: { id, name }, selectedTenantId, correlationId }` para o cliente usar o ID como seletor nas próximas chamadas; não grava Tenant em cookie nem cria autoridade persistida. Cada operação relê membership e estado do Tenant, sem cache. Um ID fora das memberships ativas retorna 404 sem revelar se o Tenant existe.

Os caminhos seguem `docs/08-api`. A fundação de convites por recurso está aplicada em `20261027165200_invite_members_at_resource_scopes.sql`; a listagem protegida está em `20261027165727_list_delegable_invitation_scopes.sql`. Smokes transacionais passaram para Tenant/Portfolio/Project, cross-Tenant e deny. Não existe ainda operação de produto para criar o primeiro grant Portfolio/Project; a interface lista apenas scopes delegáveis existentes.

## Regras de request/response

- Validar payload server-side e derivar `actor_id` da sessão verificada.
- Não aceitar actor, papel, scope ou tenant como autoridade a partir do body.
- Criação de Tenant + presets + audit é atômica; o convite do primeiro administrador é uma transação auditada separada, e somente o aceite cria membership e grant.
- Mutação de status requer `expected_version` ou mecanismo equivalente de concorrência.
- Repetição de convite/ativação deve ter semântica idempotente documentada.
- Não incluir tokens de convite, recovery ou sessão em logs e respostas após uso.
- Coleções usam cursor pagination para resultados grandes, filtros/sort allowlisted e limite máximo server-side conforme `docs/08-api/{conventions,pagination-filtering-sorting}.md`.
- Toda rota externa usa prefixo `/api/v1`; campos JSON são camelCase, datas ISO 8601 e timestamps UTC.
- Provisionamento inicial exige sessão autenticada de operador da plataforma e grant `tenant.lifecycle.create`; não existe endpoint público de criação de Tenant.
- Implementação atual de `POST /api/v1/tenants` aceita somente `{ displayName, reason, idempotencyKey }`, rejeita chaves extras como `slug`, deriva o identificador no servidor e deriva o ator de `auth.uid()` dentro do RPC; exige UUID de idempotência. O slug usa NFKD, remove diacríticos, minúsculas, hífens entre grupos não alfanuméricos ASCII e limite de 63 caracteres; nomes sem ao menos três caracteres ASCII alfanuméricos são rejeitados. Repetição idêntica retorna o Tenant criado; a mesma chave com ator/payload diferente retorna conflito. Criação, sete presets e audit são atômicos. Sessão real validou o provisionamento no DEV em 2026-10-26. Os RPCs de primeiro administrador foram aplicados e validados em transação revertida no DEV; token bruto não é persistido nem enviado por e-mail.
- Quotas são lidas/configuradas por endpoints de administração da plataforma; ausência de quota explícita significa ausência de limite comercial específico, sem remover controles de capacidade/abuso.
- `POST /api/v1/tenants/{tenantId}/admin-transfer` exige administrador atual autenticado, identidade verificada do novo administrador e `expectedVersion`; fluxo de recuperação segue aprovação independente no procedimento JIT.
- `POST /api/v1/tenants/{tenantId}/export-disputes` exige contato de export autorizado, motivo e escopo; só é aceito até 30 dias após notificação de disponibilidade. A resolução é comando restrito à equipe da plataforma e auditado.

## Erros mínimos

`401` sessão ausente/inválida; `403` operação não permitida; `404` recurso oculto por política; `409` conflito de estado/slug/membership; `422` payload ou transição inválida; `429` limite excedido. Respostas não devem permitir enumeração cross-tenant.

## Limites ainda dependentes da implementação

Schemas OpenAPI completos, limites numéricos de página/tamanho, campos allowlisted por payload e códigos de erro estáveis devem ser materializados no contrato executável da API. Os defaults e convenções acima são normativos para o MVP.
