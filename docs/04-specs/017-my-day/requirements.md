# SPEC-017 — My Day — Requirements

**Status:** Draft — projeção/query especificada; contrato de origem pendente

## Natureza do módulo

`MyDayItem` é exclusivamente uma leitura/projeção. Não cria nem edita entidades operacionais; ações encaminham o usuário para a fonte oficial.

- **FR-017-01:** consultar apenas `Actor + authorized Projects` após resolver Tenant/Membership e permissions server-side.
- **FR-017-02:** derivar os campos `actor_id, project_id, source_type, source_id, exception_type, due_at, severity, action_url` de fontes oficiais autorizadas, com timestamp/version de origem.
- **FR-017-03:** identificar claramente estado temporal `Current` ou `Published` e origem (`source_type`, `source_id`) de cada exceção quando aplicável.
- **FR-017-04:** não permitir write de negócio na projeção; `getMyDay / filterItems / dismissReminder` não altera fontes oficiais.
- **FR-017-05:** omitir/mascarar dados sem data policy e impedir agregação que revele recursos não autorizados.
- **FR-017-06:** apresentar refresh/as-of time, empty, loading, partial-data, stale-data e failure states.

## Fora de escopo

Criar ou manter uma cópia editável de risco, ação, orçamento, status ou snapshot dentro da projeção.


## Acceptance/test traceability

- `FR-017-01` authorized query → `AC-017-01` → `TC-017-01`.
- `FR-017-02`, `FR-017-04` primary create/command → `AC-017-02` → `TC-017-01/02`.
- `FR-017-03` version/lifecycle → `AC-017-05` → `TC-017-03/05`.
- `FR-017-05` Tenant/source relationship → `AC-017-04` → `TC-017-04/05`.
- `FR-017-06` audit/post-commit → `AC-017-02` → `TC-017-06`.
- `FR-017-07` data policy/export → `AC-017-04` → `TC-017-07`.
- `FR-017-08` UI states/error surfaces → `AC-017-05` → `TC-017-08`; module-specific extensions remain listed in acceptance/tests.


## Requisito de invariante por domínio

- **FR-017-09:** Enforce the domain invariant: Workspace agrega exceções de fontes oficiais autorizadas e não cria nem duplica tarefas.


- `FR-017-09` domain invariant → `AC-017-06` → `TC-017-10`.
