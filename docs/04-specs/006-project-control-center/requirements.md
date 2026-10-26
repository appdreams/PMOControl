# SPEC-006 — Project Control Center — Requirements

**Status:** Draft — projeção/query especificada; contrato de origem pendente

## Natureza do módulo

`ProjectControlSummary` é exclusivamente uma leitura/projeção. Não cria nem edita entidades operacionais; ações encaminham o usuário para a fonte oficial.

- **FR-006-01:** consultar apenas `Project scope` após resolver Tenant/Membership e permissions server-side.
- **FR-006-02:** derivar os campos `current_rag, published_rag, progress, forecast_end_date, budget_variance, critical_risks, open_issues, overdue_actions, next_milestone, source_versions` de fontes oficiais autorizadas, com timestamp/version de origem.
- **FR-006-03:** identificar claramente estado temporal `Current` ou `Published` e origem (`source_type`, `source_id`) de cada exceção quando aplicável.
- **FR-006-04:** não permitir write de negócio na projeção; `getControlCenter` não altera fontes oficiais.
- **FR-006-05:** omitir/mascarar dados sem data policy e impedir agregação que revele recursos não autorizados.
- **FR-006-06:** apresentar refresh/as-of time, empty, loading, partial-data, stale-data e failure states.

## Fora de escopo

Criar ou manter uma cópia editável de risco, ação, orçamento, status ou snapshot dentro da projeção.


## Acceptance/test traceability

- `FR-006-01` authorized query → `AC-006-01` → `TC-006-01`.
- `FR-006-02`, `FR-006-04` primary create/command → `AC-006-02` → `TC-006-01/02`.
- `FR-006-03` version/lifecycle → `AC-006-05` → `TC-006-03/05`.
- `FR-006-05` Tenant/source relationship → `AC-006-04` → `TC-006-04/05`.
- `FR-006-06` audit/post-commit → `AC-006-02` → `TC-006-06`.
- `FR-006-07` data policy/export → `AC-006-04` → `TC-006-07`.
- `FR-006-08` UI states/error surfaces → `AC-006-05` → `TC-006-08`; module-specific extensions remain listed in acceptance/tests.


## Requisito de invariante por domínio

- **FR-006-09:** Enforce the domain invariant: É projeção derivada; comandos gravam nas fontes oficiais e toda seção respeita permission própria.


- `FR-006-09` domain invariant → `AC-006-06` → `TC-006-10`.
