# SPEC-016 — Snapshots — Requirements

**Status:** Draft — payload snapshot-v1 definido; alinhamento transversal pendente  
**Spec:** 016

## Objetivo e regra de domínio

Snapshot publicado é imutável; criado na transação da publicação, com payload `snapshot-v1`, hash SHA-256 canônico e vínculo único com a publicação.

## Requisitos funcionais testáveis

- **FR-016-01:** consultar/listar Snapshots somente dentro de `Project/Snapshot`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-016-02:** criar Snapshot na publicação com os campos canônicos e payload requerido definido em `database.md`; validar required fields, policy de campos e relações autorizadas.
- **FR-016-03:** negar update/delete ordinário; `snapshot_version` aumenta somente por nova publicação sucessora, sem alterar payload anterior.
- **FR-016-04:** executar operações governadas: getSnapshot, listSnapshots, compareSnapshots, verifySnapshotHash. `createSnapshot` é comando interno da transação de publish/correct da Spec 014, não endpoint independente.
- **FR-016-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-016-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-016-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-016-08:** states de loading, empty, integrity failure, forbidden e failure são distinguíveis na UI sem revelar dados protegidos.
- **FR-016-09:** verificar hash recalculando JSON canônico e retornar apenas `valid|invalid`; qualquer divergência gera alerta de integridade auditado.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-016-01` authorized query → `AC-016-01` → `TC-016-01`.
- `FR-016-02`, `FR-016-04` publish/query commands → `AC-016-02/06` → `TC-016-01/02`.
- `FR-016-03` immutability/successor → `AC-016-03/06` → `TC-016-06/10`.
- `FR-016-05` Tenant/source relationship → `AC-016-04` → `TC-016-04/05`.
- `FR-016-06` audit/post-commit → `AC-016-02` → `TC-016-06`.
- `FR-016-07` data policy/export → `AC-016-04` → `TC-016-07`.
- `FR-016-08` e `FR-016-09` → `AC-016-06` → `TC-016-02/10` (estado de integridade e validação do hash canônico).
