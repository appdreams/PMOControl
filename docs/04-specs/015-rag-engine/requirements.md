# SPEC-015 — RAG Engine — Requirements

**Status:** Draft — algoritmo MVP definido; integração transversal pendente  
**Spec:** 015

## Objetivo e regra de domínio

Calculated RAG usa `rag-v1` (pior caso dos indicadores de prazo, custo, marcos, issues críticas e riscos), é preservado; ausência obrigatória gera `incomplete`. Override muda somente Effective RAG, exige grant, justificativa e audit.

## Requisitos funcionais testáveis

- **FR-015-01:** consultar/listar RAG Engine somente dentro de `Project`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-015-02:** avaliar RAG com fontes carregadas pelo servidor e persistir `tenant_id, project_id, as_of, evaluation_status, calculated_rag, effective_rag, rule_version_id, normalized_inputs_json, inputs_hash`.
- **FR-015-03:** avaliações e versões de regra são append-only; override registra transição própria com optimistic concurrency.
- **FR-015-04:** executar operações governadas: evaluateRag, getRagHistory, overrideRag, revokeOverride.
- **FR-015-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-015-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-015-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-015-08:** states de loading, empty, validation error, forbidden, conflict, incomplete e failure são distinguíveis na UI sem revelar dados protegidos.
- **FR-015-09:** avaliação persiste `rule_set_version`, data de corte, valores de entrada normalizados e hash; repetir mesmos inputs e versão gera o mesmo resultado.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e recalcular snapshots históricos permanecem fora do MVP. Thresholds `rag-v1` são defaults de produto para o MVP; alterações exigem nova rule version e não reescrevem avaliações/publicações anteriores.

## Rastreabilidade

Contrato canônico: `business-rules.md`, `database.md`, `api.md`, `permissions.md`, `acceptance-criteria.md` e `test-cases.md`; PDD §15, `docs/06-data/tables.md`, `docs/08-api/rag-api.md`, SPEC-003 permission matrix e `docs/11-testing/rag-testing.md`.


## Acceptance/test traceability

- `FR-015-01` authorized query → `AC-015-01` → `TC-015-01`.
- `FR-015-02`, `FR-015-04` evaluate/override commands → `AC-015-02/03` → `TC-015-01/02`.
- `FR-015-03` version/lifecycle → `AC-015-05` → `TC-015-03/05`.
- `FR-015-05` Tenant/source relationship → `AC-015-04` → `TC-015-04/05`.
- `FR-015-06` audit/post-commit → `AC-015-02` → `TC-015-06`.
- `FR-015-07` data policy/export → `AC-015-04` → `TC-015-07`.
- `FR-015-08` UI states/error surfaces → `AC-015-05` → `TC-015-08`.
- `FR-015-09` reproducibility/incomplete → `AC-015-06` → `TC-015-10/11`.
