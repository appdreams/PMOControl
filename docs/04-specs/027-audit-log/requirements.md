# SPEC-027 — Audit Log — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 027

## Objetivo e regra de domínio

Eventos append-only para usuários comuns; payload minimizado, sem secrets, com integridade e acesso restrito.

## Ator e payload de autenticação

- Evento de aplicação exige ator autenticado/verificado. `actor_id` é obrigatório e `actor_type` é allowlist (`user`, `platform_service`, `system_job`), derivado do contexto de execução confiável. `user` usa `auth.uid()`; serviços/jobs usam IDs estáveis de um catálogo versionado pela aplicação, validados por par ID/tipo no writer. Ator anônimo ou email informado não pode ser usado para atribuir evento.
- Tentativas de login falhas pré-autenticação permanecem no log do provider. Não copiar email, IP ou credencial para `audit_events`.
- `event_type`, `source`, `reason_code` e chaves do payload usam allowlist por comando. Valores livres não podem conter password, token, cookie, authorization header, segredo BYOK ou conteúdo de formulário. Guardar IDs internos e códigos enumerados, nunca snapshot de credenciais.
- Evento de plataforma pode ter `tenant_id = NULL` somente para ação genuinamente platform-scoped; idempotency key continua única nesse escopo.

## Requisitos funcionais testáveis

- **FR-027-01:** consultar/listar Audit Log somente dentro de `Tenant + audit permission`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-027-02:** append AuditEvent only through trusted domain/outbox writer; derive actor/tenant from verified execution context and validate schema/redaction.
- **FR-027-03:** deny application-role insert/update/delete and all client-side event mutation; correction creates a new linked event.
- **FR-027-04:** executar operações governadas: appendAuditEvent, queryAuditEvents, exportAuditEvidence.
- **FR-027-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-027-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-027-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-027-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.
- **FR-027-09:** event required by a sensitive command commits atomically with that command; event failure aborts source mutation.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-027-01` → `AC-027-01` → `TC-027-02/04` (consulta autorizada e escopo).
- `FR-027-02` e `FR-027-04` → `AC-027-02/05` → `TC-027-01/02/09` (escrita interna, comandos governados e exportação).
- `FR-027-03` → `AC-027-06` → `TC-027-10` (append-only e ausência de mutação pelo cliente).
- `FR-027-05` → `AC-027-04` → `TC-027-04/05` (ownership e isolamento tenant).
- `FR-027-06` e `FR-027-09` → `AC-027-02` → `TC-027-01/03` (evento obrigatório na mesma transação da mutação de origem).
- `FR-027-07` → `AC-027-05` → `TC-027-09` (autorização e data policy na consulta/exportação).
- `FR-027-08` → `AC-027-05` → `TC-027-08` (estados de erro sem revelar recurso protegido).
