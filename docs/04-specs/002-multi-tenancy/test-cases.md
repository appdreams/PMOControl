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
- **TC-002-15:** Cada transição Tenant/Membership permitida acima funciona uma vez e registra audit atomicamente; transição proibida, versão obsoleta e replay falham sem estado parcial.
- **TC-002-16:** Suspensão/revogação concorrente com mutação protegida serializa; após commit da suspensão/revogação nenhuma operação subsequente usa membership/grant antigo.
- **TC-002-17:** Nome com acentos/Unicode e pontuação gera slug normalizado determinístico, sem campo editável; payload com slug definido pelo cliente ou nome incapaz de gerar ao menos 3 caracteres ASCII é rejeitado; repetição do nome em outro provisionamento retorna conflito sem Tenant duplicado.
- **TC-002-18:** Primeiro administrador: operador não autorizado/diferente do criador é negado; token é armazenado somente como hash, expira em sete dias, reemissão revoga o anterior e aceite válido cria membership, grant `tenant_admin` e audit em uma transação. Mismatch, expiração, revogação e replay falham sem estado parcial. Convite marcado `tenant_member` não pode passar pelo RPC de aceite bootstrap.
- **TC-002-19:** Diretório de membros exige membership ativa, Tenant ativo e grant exato `membership.view`; deny prevalece. IDs de outro Tenant, ator sem grant, Tenant suspenso e contexto ausente não revelam dados. Resposta não inclui e-mail, token ou grants fora do scope Tenant.
- **TC-002-20:** Convite comum requer `membership.invite` no Tenant exato e ceiling sobre cada permission do papel; token bruto nunca persiste, reemissão revoga pendente anterior e aceite requer e-mail Auth confirmado igual. Expiração, mismatch, role desativado, emissor sem membership/permissão, deny, replay e reativação de membership suspensa falham sem estado parcial. Membership revogada pode voltar apenas por aceite válido; audit e grant/membership commitam atomicamente. Smoke DEV transacional sintético validou emissão/aceite Tenant Admin, Auth confirmado, membership/grant/audit e rollback. E2E real aguarda segunda conta. O endpoint só atribui scope Tenant; presets Portfolio/Project são ocultados pela UI até existir resolução/seleção de escopo.
- **TC-002-21:** Revogação exige `membership.revoke` exato, motivo e versão atual; revoga membership e todos os grants Tenant atomicamente e audita sem e-mail. Negar cross-Tenant, ator sem grant/deny, auto-revogação, último Tenant Admin, versão obsoleta e replay sem escrita parcial.
- **TC-002-22:** Suspensão/reativação exige `membership.manage` exato, motivo e versão atual; mantém grants ao suspender e audita ambas as transições atomicamente. Negar cross-Tenant, ator sem permissão/deny, auto-transição, último Tenant Admin, versão obsoleta, replay divergente e tentativa de reativar membership revogada. DEV fixtures revertidas já cobriram sucesso, falta de permissão, auto-transição, último Tenant Admin, versão/audit/grants; replay divergente e estado revoked permanecem para a suíte completa.

Gates: cross-tenant, bypass por suporte, export incompleto e purge prematuro bloqueiam release.
