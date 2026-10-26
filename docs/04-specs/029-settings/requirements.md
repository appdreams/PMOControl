# SPEC-029 — Settings — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 029

## Objetivo e regra de domínio

Configurações são tenant-scoped e tipadas; secrets nunca são retornados; mudanças sensíveis auditadas.

## Requisitos funcionais testáveis

- **FR-029-01:** consultar/listar Settings somente dentro de `Tenant + settings permission`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-029-02:** criar/derivar TenantSetting usando apenas campos aceitos pelo domínio: `tenant_id, key, value_schema_version, value_redacted, updated_by, updated_at`; validar required fields e relações autorizadas.
- **FR-029-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-029-04:** executar operações governadas: getSettings, updateSetting, resetSetting, rotateSecretReference.
- **FR-029-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-029-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-029-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-029-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-029-09:** Enforce the domain invariant: Configurações são tenant-scoped e tipadas; secrets nunca são retornados; mudanças sensíveis auditadas.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-029-01` authorized query → `AC-029-01` → `TC-029-01`.
- `FR-029-02`, `FR-029-04` primary create/command → `AC-029-02` → `TC-029-01/02`.
- `FR-029-03` version/lifecycle → `AC-029-05` → `TC-029-03/05`.
- `FR-029-05` Tenant/source relationship → `AC-029-04` → `TC-029-04/05`.
- `FR-029-06` audit/post-commit → `AC-029-02` → `TC-029-06`.
- `FR-029-07` data policy/export → `AC-029-04` → `TC-029-07`.
- `FR-029-08` UI states/error surfaces → `AC-029-05` → `TC-029-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-029-09` domain invariant → `AC-029-06` → `TC-029-10`.
