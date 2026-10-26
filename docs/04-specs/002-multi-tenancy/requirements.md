# SPEC-002 — Multi-Tenancy — Requirements

**Status:** Draft — decisões MVP incorporadas; contrato completo pendente

Tenant é fronteira de autorização aplicada em servidor e banco; `tenant_id` do cliente não prova acesso. Recursos de negócio pertencem a um Tenant, salvo catálogos globais declarados.

- **FR-002-01:** somente equipe da plataforma cria tenants; criação deve incluir slug único, estado inicial e primeiro administrador/membership de forma consistente.
- **FR-002-02:** somente equipe da plataforma pode suspender/reativar ou iniciar encerramento de tenant; operações exigem ator e motivo auditados.
- **FR-002-03:** usuário pode ter membership em vários tenants e escolhe uma membership ativa após login; o servidor valida membership em toda operação e descarta contexto anterior na troca.
- **FR-002-04:** convite vincula e-mail, Tenant e grants propostos; é single-use, expira em 7 dias, pode ser revogado e não autoaprova grants além dos permitidos ao convidante.
- **FR-002-05:** negar leitura, alteração, enumeração, exportação e vínculo cross-tenant por IDs, filtros, jobs, uploads, storage, webhooks ou endpoints internos.
- **FR-002-06:** validar same-tenant para relações pai/filho no domínio e impor integridade no banco quando suportado.
- **FR-002-07:** encerramento bloqueia novas operações, entrega export antes de iniciar janela de 90 dias, então executa purge/anonimização salvo legal hold/obrigação aplicável.
- **FR-002-08:** não há limite fixo de tenants/usuários por cliente no MVP; quotas são configuráveis por plano pela equipe da plataforma.
- **FR-002-09:** suspensão bloqueia novas mutações, jobs e integrações, sem apagar dados; reativação restaura somente acessos ainda válidos.
- **FR-002-10:** propagar contexto de Tenant a consultas, comandos, cache, storage, exports, notificações, IA e jobs.
- **FR-002-11:** transferir administração primária somente por solicitação autenticada de administrador atual e confirmação do novo administrador; recuperação sem administrador ativo exige procedimento de suporte JIT e auditoria.
- **FR-002-12:** disponibilizar export de encerramento íntegra a contato autorizado; contestação fundamentada dentro de 30 dias pausa o purge somente para o escopo contestado até resolução registrada.

Falha ao resolver tenant/membership resulta em deny. RLS é defesa adicional. Respostas não revelam recursos de outro Tenant. Prazos de retenção detalhados estão em `docs/06-data/retention-archival.md` e são defaults sujeitos à revisão jurídica/contratual antes de produção.

## Acceptance/test traceability

- `FR-002-01` → `AC-002-01/02` → `TC-002-01/02/03` (provisionamento, negação e slug único).
- `FR-002-02` e `FR-002-09` → `AC-002-02/06` → `TC-002-02/08` (lifecycle, suspensão e reativação).
- `FR-002-03` → `AC-002-03` → `TC-002-04` (seleção e validação da membership ativa).
- `FR-002-04` → `AC-002-04` → `TC-002-05` (single-use, expiração, revogação e identidade alvo).
- `FR-002-05`, `FR-002-06` e `FR-002-10` → `AC-002-05` → `TC-002-06/07` (isolamento, integridade same-tenant e propagação de contexto).
- `FR-002-07` → `AC-002-07` → `TC-002-09/10/11` (export-first, legal hold, janela de purge e backups).
- `FR-002-08` → `AC-002-08` → `TC-002-12` (quota configurada sem limite implícito).
- `FR-002-11` → `AC-002-09` → `TC-002-13` (transferência autenticada, sem grant cross-tenant ou autoelevação).
- `FR-002-12` → `AC-002-10` → `TC-002-14` (contestação tempestiva pausa purge no escopo disputado e exige resolução auditada).
- Idempotência de encerramento/purge → `AC-002-07` → `TC-002-10/11`.
