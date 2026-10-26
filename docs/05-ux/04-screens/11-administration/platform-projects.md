# Screen — Platform Project Purge

**Status:** Draft — workflow privileged and retention behavior defined; implementation/security review pending

## Purpose and users

Console administrativo para remover definitivamente um Project quando necessário. Disponível somente a Platform Root Admin com `platform.projects.purge`. Platform Admin comum, Tenant Admin e usuários do Tenant não veem a ação.

## Project selector and data shown

Listar apenas metadados necessários à identificação: nome/código do Project, nome do Tenant, estado operacional e versão. Não exibir conteúdo de projeto, documentos, riscos, finanças, narrativas, assignments ou relatórios. O servidor autoriza cada consulta e ação; ocultar botão não é controle de segurança.

## Confirmation flow

1. A ação “Excluir definitivamente” solicita preview atualizado do servidor.
2. A prévia informa identidade do Project, contagens por módulo, o que será removido, o que será preservado por histórico/retenção/legal hold e dependências que bloqueiam remoção. Nenhum conteúdo de negócio é mostrado.
3. Exigir motivo e digitação do código exato do Project; só então habilitar a confirmação final.
4. O servidor revalida entitlement, preview/versão, hold e retenção e inicia um purge job idempotente. Não executar purge por chamada GET nem pelo estado de botão client-side.
5. Exibir queued/running/completed/partially-retained/blocked/failed, contagens e audit reference. Falhas podem ser retomadas sem repetir exclusões.

## Data and history

Remover dados operacionais elegíveis do Project em fases; preservar audit, publicações, snapshots, dados sob retenção/hold e identidade mínima/tombstone enquanto existirem referências. Não alterar nem apagar conteúdo histórico imutável. Dependências fora do Project não sofrem cascade implícito. Resultado separa apagados, retidos e bloqueados conforme `docs/06-data/retention-archival.md`.

## States and accessibility

Loading, sem Projects visíveis, forbidden, preview stale, hold/retention, confirmation, queued/running, completed, partially retained, blocked, failure e retry têm mensagens distintas. A confirmação é keyboard accessible, foco fica preso no diálogo e retorna ao acionador ao fechar. Conteúdo nunca é revelado por mensagem de erro.

Behavioral trace: `SPEC-005 FR-005-10/11 → platform.projects.purge → platform Project preview/purge API → AC-005-07/08/09 → TC-005-11–14`.
