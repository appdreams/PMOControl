# SPEC-015 — RAG Engine — Business Rules

**Status:** Draft — defaults determinísticos `rag-v1` definidos; sujeitos a versionamento explícito

- **BR-015-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-015-02 — Invariant:** Calculated RAG é determinístico e preservado; override muda Effective RAG, exige justificativa e audit.
- **BR-015-03 — Lifecycle:** RagEvaluation só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-015-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-015-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-015-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-015-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.

## Algoritmo determinístico MVP — versão `rag-v1`

Calcular os indicadores na data de corte do status, usando somente fontes autorizadas e valores normalizados. `Green=0`, `Amber=1`, `Red=2`; `Calculated RAG` é o maior nível de severidade entre os indicadores aplicáveis (regra do pior caso, sem média). Ausência de dado não equivale a Green: se faltar qualquer entrada obrigatória, avaliação fica `incomplete`, conserva o último resultado publicado e exige resolução antes da publicação.

| Indicador | Green | Amber | Red |
|---|---|---|---|
| Variação de prazo (`forecast_finish` vs `baseline_finish`) | <= 5% da duração baseline e <= 10 dias | >5% ou >10 dias, mas <=15% e <=30 dias | >15% ou >30 dias |
| Variação de custo (`forecast_at_completion` vs `approved_budget`) | <= 5% | >5% e <=10% | >10% |
| Marcos estratégicos vencidos e não concluídos | 0 | 1 | >=2 |
| Issue crítica aberta bloqueando caminho crítico | 0 | 1 | >=2 ou qualquer bloqueio com impacto de segurança/compliance |
| Riscos | nenhum risco score >=16 | risco score 16–19 sem materialização | risco materializado ou score >=20 |

Percentuais usam denominador positivo; se baseline de duração ou orçamento for zero/nulo, o indicador correspondente é `not_applicable` somente quando o domínio confirma ausência legítima; caso contrário, avaliação é `incomplete`. Risco score usa probabilidade 1–5 × impacto 1–5. Regras/thresholds são versionados em `rag_rule_versions`; qualquer alteração cria nova versão efetiva a partir de uma data, sem recalcular snapshots históricos.

`Effective RAG` inicia igual a `Calculated RAG`. Override exige `projects.{projectId}.rag-evaluations.override`, justificativa não vazia (mínimo 10 caracteres), actor e timestamp, e persiste evento imutável com valor anterior/novo e expiração opcional. Override expirado/revogado restaura o valor calculado atual sem alterar avaliações anteriores. Nenhum LLM participa do cálculo.
