# SPEC-026 — Notifications — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 026

## Objetivo e regra de domínio

Notificação é pós-commit, minimizada e idempotente; falha nunca altera estado oficial.

## Requisitos funcionais testáveis

- **FR-026-01:** consultar/listar Notifications somente dentro de `Recipient/Tenant`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-026-02:** criar/derivar Notification usando apenas campos aceitos pelo domínio: `tenant_id, recipient_id, event_id, type, channel, payload_minimized`; validar required fields e relações autorizadas.
- **FR-026-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-026-04:** executar operações governadas: listInbox, markRead, updatePreferences, enqueueDelivery, retryDelivery.
- **FR-026-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-026-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-026-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-026-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-026-09:** Enforce the domain invariant: Notificação é pós-commit, minimizada e idempotente; falha nunca altera estado oficial.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-026-01` authorized query → `AC-026-01` → `TC-026-01`.
- `FR-026-02`, `FR-026-04` primary create/command → `AC-026-02` → `TC-026-01/02`.
- `FR-026-03` version/lifecycle → `AC-026-05` → `TC-026-03/05`.
- `FR-026-05` Tenant/source relationship → `AC-026-04` → `TC-026-04/05`.
- `FR-026-06` audit/post-commit → `AC-026-02` → `TC-026-06`.
- `FR-026-07` data policy/export → `AC-026-04` → `TC-026-07`.
- `FR-026-08` UI states/error surfaces → `AC-026-05` → `TC-026-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-026-09` domain invariant → `AC-026-06` → `TC-026-10`.
