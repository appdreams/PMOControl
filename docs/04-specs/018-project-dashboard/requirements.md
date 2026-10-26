# SPEC-018 — Project Dashboard — Requirements

**Status:** Draft — projeção/query especificada; contrato de origem pendente

## Natureza do módulo

`ProjectDashboardProjection` é exclusivamente uma leitura/projeção. Não cria nem edita entidades operacionais; ações encaminham o usuário para a fonte oficial.

- **FR-018-01:** consultar apenas `Project` após resolver Tenant/Membership e permissions server-side.
- **FR-018-02:** derivar os campos `temporal_mode, as_of, current_progress, published_progress, rag, forecast, budget_summary, milestone_summary, risk_summary, issue_summary` de fontes oficiais autorizadas, com timestamp/version de origem.
- **FR-018-03:** identificar claramente estado temporal `Current` ou `Published` e origem (`source_type`, `source_id`) de cada exceção quando aplicável.
- **FR-018-04:** não permitir write de negócio na projeção; `getProjectDashboard` não altera fontes oficiais.
- **FR-018-05:** omitir/mascarar dados sem data policy e impedir agregação que revele recursos não autorizados.
- **FR-018-06:** apresentar refresh/as-of time, empty, loading, partial-data, stale-data e failure states.

## Fora de escopo

Criar ou manter uma cópia editável de risco, ação, orçamento, status ou snapshot dentro da projeção.


## Acceptance/test traceability

- `FR-018-01` authorized query → `AC-018-01` → `TC-018-01`.
- `FR-018-02`, `FR-018-04` primary create/command → `AC-018-02` → `TC-018-01/02`.
- `FR-018-03` version/lifecycle → `AC-018-05` → `TC-018-03/05`.
- `FR-018-05` Tenant/source relationship → `AC-018-04` → `TC-018-04/05`.
- `FR-018-06` audit/post-commit → `AC-018-02` → `TC-018-06`.
- `FR-018-07` data policy/export → `AC-018-04` → `TC-018-07`.
- `FR-018-08` UI states/error surfaces → `AC-018-05` → `TC-018-08`; module-specific extensions remain listed in acceptance/tests.


## Requisito de invariante por domínio

- **FR-018-09:** Enforce the domain invariant: Projeção identifica Current vs Published e não permite edição direta dos fatos.


- `FR-018-09` domain invariant → `AC-018-06` → `TC-018-10`.
