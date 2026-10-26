# SPEC-019 — Portfolio Dashboard — Requirements

**Status:** Draft — projeção/query especificada; contrato de origem pendente

## Natureza do módulo

`PortfolioDashboardProjection` é exclusivamente uma leitura/projeção. Não cria nem edita entidades operacionais; ações encaminham o usuário para a fonte oficial.

- **FR-019-01:** consultar apenas `Portfolio + authorized Projects` após resolver Tenant/Membership e permissions server-side.
- **FR-019-02:** derivar os campos `temporal_mode, as_of, authorized_project_count, rag_distribution, delivery_metrics, budget_summary, critical_exceptions` de fontes oficiais autorizadas, com timestamp/version de origem.
- **FR-019-03:** identificar claramente estado temporal `Current` ou `Published` e origem (`source_type`, `source_id`) de cada exceção quando aplicável.
- **FR-019-04:** não permitir write de negócio na projeção; `getPortfolioDashboard` não altera fontes oficiais.
- **FR-019-05:** omitir/mascarar dados sem data policy e impedir agregação que revele recursos não autorizados.
- **FR-019-06:** apresentar refresh/as-of time, empty, loading, partial-data, stale-data e failure states.

## Fora de escopo

Criar ou manter uma cópia editável de risco, ação, orçamento, status ou snapshot dentro da projeção.


## Acceptance/test traceability

- `FR-019-01` authorized query → `AC-019-01` → `TC-019-01`.
- `FR-019-02`, `FR-019-04` primary create/command → `AC-019-02` → `TC-019-01/02`.
- `FR-019-03` version/lifecycle → `AC-019-05` → `TC-019-03/05`.
- `FR-019-05` Tenant/source relationship → `AC-019-04` → `TC-019-04/05`.
- `FR-019-06` audit/post-commit → `AC-019-02` → `TC-019-06`.
- `FR-019-07` data policy/export → `AC-019-04` → `TC-019-07`.
- `FR-019-08` UI states/error surfaces → `AC-019-05` → `TC-019-08`; module-specific extensions remain listed in acceptance/tests.


## Requisito de invariante por domínio

- **FR-019-09:** Enforce the domain invariant: Agregação considera somente Projects autorizados; contagens não revelam projetos ocultos.


- `FR-019-09` domain invariant → `AC-019-06` → `TC-019-10`.
