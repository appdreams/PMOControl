# SPEC-002 — Multi-Tenancy — API

**Status:** Draft — lifecycle and invitation route contract defined; implementation review pending  
**Spec:** 002  
**Módulo:** Multi-Tenancy

## Contexto e autorização

Tenant context é derivado da sessão/membership verificada no servidor. O cliente não escolhe um `tenant_id` arbitrário para ampliar acesso. Todas as rotas administrativas ainda aplicam permission e scope server-side.

## Operações de domínio

- `POST /api/v1/tenants`: cria Tenant e primeira membership administrativa; requer permissão de provisionamento de plataforma.
- `GET /api/v1/tenants`: lista somente Tenants visíveis ao ator conforme política de plataforma.
- `GET /api/v1/tenants/{tenantId}`: requer acesso administrativo ao Tenant; recursos de outro Tenant retornam resposta não reveladora.
- `PATCH /api/v1/tenants/{tenantId}`: altera campos administrativos permitidos; alterações de estado são comandos separados e auditados.
- `POST /api/v1/tenants/{tenantId}/suspend` e `/reactivate`: comandos administrativos, idempotentes, com motivo obrigatório e audit.
- `POST /api/v1/tenants/{tenantId}/invitations`: cria convite com papel/escopo permitido e validade limitada.
- `POST /api/v1/invitations/{token}/accept`: valida token único/expirável, identidade verificada e membership resultante.
- `GET /api/v1/session/tenants`: retorna somente memberships ativas do ator.
- `POST /api/v1/session/tenant`: troca para membership ativa; invalida contexto e caches tenant-scoped.

Os caminhos são contratos lógicos sujeitos à convenção/versionamento global de `docs/08-api`; não implicam implementação existente.

## Regras de request/response

- Validar payload server-side e derivar `actor_id` da sessão verificada.
- Não aceitar actor, papel, scope ou tenant como autoridade a partir do body.
- Criação de Tenant + primeiro administrador é atômica ou compensada sem Tenant órfão.
- Mutação de status requer `expected_version` ou mecanismo equivalente de concorrência.
- Repetição de convite/ativação deve ter semântica idempotente documentada.
- Não incluir tokens de convite, recovery ou sessão em logs e respostas após uso.
- Coleções usam cursor pagination para resultados grandes, filtros/sort allowlisted e limite máximo server-side conforme `docs/08-api/{conventions,pagination-filtering-sorting}.md`.
- Toda rota externa usa prefixo `/api/v1`; campos JSON são camelCase, datas ISO 8601 e timestamps UTC.
- Provisionamento inicial exige sessão autenticada de operador da plataforma e grant `tenant.lifecycle.create`; não existe endpoint público de criação de Tenant.
- Quotas são lidas/configuradas por endpoints de administração da plataforma; ausência de quota explícita significa ausência de limite comercial específico, sem remover controles de capacidade/abuso.
- `POST /api/v1/tenants/{tenantId}/admin-transfer` exige administrador atual autenticado, identidade verificada do novo administrador e `expectedVersion`; fluxo de recuperação segue aprovação independente no procedimento JIT.
- `POST /api/v1/tenants/{tenantId}/export-disputes` exige contato de export autorizado, motivo e escopo; só é aceito até 30 dias após notificação de disponibilidade. A resolução é comando restrito à equipe da plataforma e auditado.

## Erros mínimos

`401` sessão ausente/inválida; `403` operação não permitida; `404` recurso oculto por política; `409` conflito de estado/slug/membership; `422` payload ou transição inválida; `429` limite excedido. Respostas não devem permitir enumeração cross-tenant.

## Limites ainda dependentes da implementação

Schemas OpenAPI completos, limites numéricos de página/tamanho, campos allowlisted por payload e códigos de erro estáveis devem ser materializados no contrato executável da API. Os defaults e convenções acima são normativos para o MVP.
