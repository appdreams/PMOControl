# SPEC-023 — Time Machine — Requirements

**Status:** Draft — projeção/query especificada; contrato de origem pendente

## Natureza do módulo

`SnapshotComparison` é exclusivamente uma leitura/projeção. Não cria nem edita entidades operacionais; ações encaminham o usuário para a fonte oficial.

- **FR-023-01:** consultar apenas `Project/Snapshot` após resolver Tenant/Membership e permissions server-side.
- **FR-023-02:** derivar os campos `from_snapshot_id, to_snapshot_id, sections, diff, generated_at` de fontes oficiais autorizadas, com timestamp/version de origem.
- **FR-023-03:** identificar claramente estado temporal `Current` ou `Published` e origem (`source_type`, `source_id`) de cada exceção quando aplicável.
- **FR-023-04:** não permitir write de negócio na projeção; `listTimeline / getHistoricalView / compareSnapshots` não altera fontes oficiais.
- **FR-023-05:** omitir/mascarar dados sem data policy e impedir agregação que revele recursos não autorizados.
- **FR-023-06:** apresentar refresh/as-of time, empty, loading, partial-data, stale-data e failure states.

## Fora de escopo

Criar ou manter uma cópia editável de risco, ação, orçamento, status ou snapshot dentro da projeção.


## Acceptance/test traceability

- `FR-023-01` authorized query → `AC-023-01` → `TC-023-01`.
- `FR-023-02`, `FR-023-04` primary create/command → `AC-023-02` → `TC-023-01/02`.
- `FR-023-03` version/lifecycle → `AC-023-05` → `TC-023-03/05`.
- `FR-023-05` Tenant/source relationship → `AC-023-04` → `TC-023-04/05`.
- `FR-023-06` audit/post-commit → `AC-023-02` → `TC-023-06`.
- `FR-023-07` data policy/export → `AC-023-04` → `TC-023-07`.
- `FR-023-08` UI states/error surfaces → `AC-023-05` → `TC-023-08`; module-specific extensions remain listed in acceptance/tests.


## Requisito de invariante por domínio

- **FR-023-09:** Enforce the domain invariant: Visão histórica deriva somente de snapshots publicados, nunca do estado atual retroprojetado.


- `FR-023-09` domain invariant → `AC-023-06` → `TC-023-10`.
