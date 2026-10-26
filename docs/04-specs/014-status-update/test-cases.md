# SPEC-014 — Status Update — Test Cases

**Status:** Draft — fixtures para KPI-v1/cadência mensal descritas  
**Spec:** 014

## Publicação — integração/transação

- **TC-014-01:** Publicação válida grava Publication, Snapshot, status e outbox atomicamente.
- **TC-014-02:** Injetar falha antes de cada gravação/commit: nenhuma publicação/snapshot parcial permanece.
- **TC-014-03:** Falha no consumidor pós-commit não reverte snapshot; retry conclui projeção sem duplicar notificação/efeito.
- **TC-014-04:** Repetir mesma chave e payload retorna mesma publicação; chave repetida com payload distinto dá conflito.
- **TC-014-05:** Publicar versão stale ou publicar duas vezes com chaves distintas não cria publicação duplicada.

## Autorização e isolamento

- **TC-014-06:** Sem sessão, sem membership ativa, Tenant suspenso, permission ausente ou scope incorreto: negar.
- **TC-014-07:** Alterar Project/status/tenant ID no path/body/filtros não permite acesso cross-tenant.
- **TC-014-08:** Revogar permission entre leitura e publish: revalidação no comando nega.
- **TC-014-09:** Recursos/relacionamentos de Tenants diferentes não entram no snapshot.

## Domínio e histórico

- **TC-014-10:** Validar campos obrigatórios e checklist; mensagens identificam campos sem expor dados restritos.
- **TC-014-11:** Calculated RAG é reproduzível com a mesma versão de regra e entradas; override não sobrescreve valor calculado.
- **TC-014-12:** Mutação de status publicado é recusada; correção cria nova publicação sucessora conforme policy.
- **TC-014-13:** Snapshot representa dados no ponto de commit; mudança operacional posterior não o altera.
- **TC-014-14:** Concorrência com `expected_version` retorna conflito sem perder atualização.

## Gates

Cross-tenant, autorização, atomicidade, imutabilidade e idempotência são gates de release. Os testes de KPI/RAG aguardam formalização das regras e fixtures de referência.


## Publicação direta e correção

- **TC-014-15:** Project Manager com grant explícito publica draft válido sem aprovação adicional.
- **TC-014-16:** Papel sem `status.update.publish` não publica mesmo que possa editar.
- **TC-014-17:** PM/PMO Admin sem `status.update.correct` não corrige publicação existente.
- **TC-014-18:** Correção exige motivo não vazio, cria sucessora com vínculo correto e preserva bytes/valores lógicos do snapshot antigo.
- **TC-014-19:** Falha ao criar sucessora preserva publicação anterior e não marca correção como concluída.


## Draft e consolidação

- **TC-014-20:** criar draft autorizado associa Tenant/Project/período; duplicata segue política de ciclo e não cria segundo draft ativo.
- **TC-014-21:** carregar fonte preserva source ID/version/as-of e omite campos sem permission; blocker impede publish e warning não bloqueia automaticamente.
- **TC-014-22:** editar seção draft com versão esperada não altera Risk/Milestone/Financial source; versão stale retorna conflito.
- **TC-014-23:** datas no limite de mês, timezone do Tenant, quinto dia útil, draft duplicado e reabertura autorizada seguem a regra mensal.
- **TC-014-24:** fixtures de `kpi-v1` verificam progresso planned/actual, schedule variance, cost variance e on-time delivery; casos de denominador zero geram N/A + motivo e repetição idêntica preserva resultado.
- **TC-014-25:** se qualquer source version mudar entre preview e publish, o comando bloqueia a versão antiga, atualiza a consolidação e exige confirmação antes do retry.
