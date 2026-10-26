# SPEC-014 — Status Update — Business Rules

**Status:** Draft — política e métricas MVP definidas; revisão de implementação pendente

- **BR-SU-001 — Draft only:** somente draft pode ser editado; publicação cria versão histórica imutável.
- **BR-SU-002 — Authorization:** `status.update.publish` no Project scope, membership ativa e Tenant ativo são revalidados imediatamente antes do commit.
- **BR-SU-003 — Preconditions:** status pertence ao Tenant/Project, está publicável, passa checklist e corresponde à versão esperada.
- **BR-SU-004 — Atomic publication:** estado `published`, Publication, Snapshot e evento outbox/audit confirmam juntos ou nenhum confirma.
- **BR-SU-005 — Direct publish:** PM com grant explícito pode publicar sem segunda aprovação no workflow padrão do MVP.
- **BR-SU-006 — Determinism:** KPI e Calculated RAG vêm de regras versionadas determinísticas; LLM não governa cálculo. Override autorizado preserva Calculated RAG.
- **BR-SU-007 — Audit:** registrar actor, Tenant/Project, IDs, versão de regra, timestamp, correlation ID e resumo minimizado; nunca secrets.
- **BR-SU-008 — Idempotency:** retry com mesma chave/request retorna mesma publicação; chave com request distinto é conflito.
- **BR-SU-009 — Post-commit:** projeções, notificações e integrações são assíncronas e retry-safe; falha não desfaz publicação.
- **BR-SU-010 — Correction:** PMO Admin ou Project Manager explicitamente grantado com `status.update.correct` informa motivo; correção cria publicação sucessora ligada à anterior, sem editar histórico.
- **BR-SU-011 — Cadence:** um ciclo mensal por Project; `reporting_period` é o primeiro dia do mês representado como DATE, `status_date` é o último dia do mês no fuso do Tenant, e vencimento padrão é o quinto dia de semana (segunda–sexta) do mês seguinte; feriados não alteram o vencimento no MVP. Um draft ativo por Project/período; reabertura exige grant e motivo.
- **BR-SU-012 — Required checklist:** Project ativo com gerente responsável; período/data válidos; resumo executivo entre 20 e 2.000 caracteres; progresso atual informado; cada indicador N/A traz motivo; todo risco Red aberto tem owner e resposta/mitigação ou decisão explícita de aceitar; fontes com versão/as-of consistentes. Checklist falho bloqueia; avisos são exibidos e não bloqueiam.
- **BR-SU-013 — KPI version:** toda publicação grava `kpi_rule_set_version='kpi-v1'`. Progresso planejado/real é média simples dos mesmos marcos/entregas ativos na baseline na data de corte; itens cancelados por decisão aprovada antes do corte são excluídos. Schedule variance days = forecast finish − baseline finish em dias corridos; percent = days ÷ baseline duration days ×100. Cost variance percent = (forecast at completion − approved budget) ÷ approved budget ×100. On-time delivery = entregas aceitas até baseline date ÷ entregas com baseline date no período ×100. Divisor ausente/zero retorna `null` com `not_applicable` e motivo; nunca inventar zero.
- **BR-SU-014 — Consistent cut:** consolidar sob snapshot consistente do banco; cada fonte inclui ID/version/as-of e tenant. Se fonte mudar durante preparação, revalidar no publish; divergência bloqueia ou exige novo preview.

`kpi-v1` e a cadência mensal são defaults MVP, configuráveis por decisão explícita sem reescrever histórico. RAG usa `rag-v1` da Spec 015. Aprovação separada de publicação não é requisito do fluxo padrão.
