# SPEC-002 — Multi-Tenancy — Test Cases

**Status:** Draft — matriz MVP; integração com RLS/export/purge pendente

- **TC-002-01:** Ator da plataforma autorizado cria tenant e primeiro admin; falha em qualquer etapa não deixa tenant órfão.
- **TC-002-02:** Cliente/tenant admin sem permission de plataforma não pode criar, suspender ou encerrar tenant.
- **TC-002-03:** Tenant slug duplicado gera conflito sem vazamento de dados.
- **TC-002-04:** Múltiplas memberships ativas exibem escolha; membership suspensa/revogada não aparece e não pode ser escolhida.
- **TC-002-05:** Convite válido aceito uma vez; expirado após 7 dias, revogado, e-mail divergente ou segundo uso são recusados.
- **TC-002-06:** Acesso cross-tenant por ID/path/body/filter/join/storage/download/export/job/webhook é negado.
- **TC-002-07:** Relação entre pai/filho de tenants diferentes falha no domínio e na integridade do banco/RLS.
- **TC-002-08:** Tenant suspenso bloqueia mutações, jobs e integrações; leitura/reativação só por fluxo explicitamente autorizado.
- **TC-002-09:** Export de encerramento contém somente conteúdo autorizado do tenant; purge não começa antes de export ready/entregue.
- **TC-002-10:** Legal hold bloqueia purge somente no escopo coberto; remoção autorizada do hold retoma execução idempotente.
- **TC-002-11:** Janela padrão é 90 dias após export pronta; purge remove/anonymiza DB, storage e projeções; backups expiram no limite de 35 dias.
- **TC-002-12:** Quota ausente não cria cap implícito; quota configurada impede apenas novos recursos conforme regra e audita a rejeição.
- **TC-002-13:** Transferência admin requer solicitante ativo, novo e-mail verificado e versão atual; tentativas por membro comum, cross-tenant ou replay são negadas. Recuperação sem admin ativo requer ticket, aprovação independente, escopo e expiração JIT.
- **TC-002-14:** Contestação de export dentro de 30 dias exige motivo/escopo, pausa somente os dados contestados e gera evento auditado; fora do prazo ou por ator não autorizado é recusada; resolução retoma purge idempotente.

Gates: cross-tenant, bypass por suporte, export incompleto e purge prematuro bloqueiam release.
