# Retention & Archival

**Status:** Draft — defaults de produto; validação jurídica/contratual pendente

## Política recomendada para o MVP

Os prazos abaixo são defaults operacionais configuráveis, não prazos legais universais. Antes de produção, confirmar finalidade, retenção e exceções por categoria e contrato. A LGPD exige necessidade e término do tratamento conforme finalidade; a ANPD esclarece que não há um prazo único de retenção estabelecido pela lei.

| Categoria | Default recomendado | Tratamento |
|---|---:|---|
| Dados operacionais de projeto/tenant ativo | Durante a vigência | Arquivar quando fora de uso; acesso segue policy. |
| Tenant encerrado | Exportação antes do encerramento; janela de 90 dias após export pronto | Depois da janela, eliminar ou anonimizar salvo hold/obrigação. |
| Publicações e snapshots | Vigência + 90 dias pós-encerramento | Imutáveis; exportados junto aos dados; purge apenas no workflow de encerramento/retention. |
| Audit/security events | 12 meses por default | Append-only e acesso restrito; minimizar PII. Ajustar por contrato/incidente/obrigação. |
| Logs operacionais/telemetria identificável | 30 dias | Minimizar conteúdo; não confundir log técnico com trilha de auditoria. |
| Backups | Rotação com expiração em até 35 dias | Expiração automática; dados apagados podem persistir até o fim da janela. |
| Convites de membership | 7 dias | Single-use; expirado/revogado não pode ser aceito. |
| Import staging e arquivos temporários | 30 dias após conclusão/falha | Apagar após relatório, salvo evidência classificada necessária. |
| Conteúdo de prompt/output/grounding de IA | Não persistir por padrão; metadados técnicos até 30 dias | BYOK não autoriza retenção do conteúdo pelo produto. |
| Ledger detalhado de uso/custo de IA | 12 meses por default, configurável por contrato | Manter somente metadados de uso/custo sem prompt/grounding/segredo; resumos agregados conforme obrigação financeira/contrato; revisão jurídica antes de produção. |
| Metadados de entrega de notificações | 90 dias | Manter somente status/timestamps e identificadores minimizados. |

## Arquivamento, exclusão e pedidos de titulares

- Usuário comum pode arquivar/fechar registros conforme permissão; hard delete não é ação normal.
- Pedido de titular inicia triagem de identidade, escopo, finalidade, obrigação de retenção e vínculos; executar exportação, correção, eliminação ou anonimização aplicável e registrar decisão sem duplicar dados pessoais no audit.
- Não excluir automaticamente entidade de negócio inteira se isso afetar auditoria ou terceiros; conservar apenas o mínimo permitido quando houver hipótese aplicável.
- Legal hold suspende purge no escopo abrangido; aplicar/remover hold exige autorização e auditoria.
- Purge é idempotente, tenant-scoped, observável e retomável.

## Encerramento do Tenant

Somente a equipe da plataforma inicia encerramento. Bloquear novas operações e credenciais de integração, gerar e verificar export completo, disponibilizar ao contato autorizado e notificá-lo; iniciar 90 dias após a exportação estar pronta/disponível. O contato pode contestar completude de forma fundamentada em até 30 dias; contestação válida pausa purge apenas para o escopo contestado até resolução auditada. Ausência de resposta não prolonga o prazo de 90 dias. Ao final, executar purge/anonymization em storage e projeções, salvo hold/obrigação. Backups expiram no ciclo de até 35 dias. Registrar atores, datas, escopo, identidade da exportação, exceções e conclusão, sem incluir conteúdo exportado no audit.

## Fontes oficiais consultadas

- Lei nº 13.709/2018 (LGPD), arts. 15–16: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm
- ANPD, Perguntas Frequentes: https://www.gov.br/anpd/pt-br/acesso-a-informacao/perguntas-frequentes

## Exclusão definitiva de Project pelo Platform Root Admin

Exclusão de Project não é encerramento de Tenant nem archive. O comando `platform.projects.purge` exige operador autorizado, preview atual, motivo, confirmação explícita vinculada ao código do Project e audit append-only. A operação bloqueia novas escritas e apaga em fases idempotentes os dados operacionais cujo purge é permitido.

Publicações, snapshots, audit, registros sob legal hold e dados ainda dentro do prazo de retenção permanecem imutáveis em arquivo histórico restrito. Mantém-se somente tombstone/identidade mínima para resolver referências; nunca preservar conteúdo operacional além do necessário. Holds não são removidos pelo purge. Dependências externas ao Project não sofrem cascade implícito. O status final separa apagados, preservados por política e bloqueados; esses dados retidos seguem a rotina central de expiração/purge. O Platform Root Admin não recebe acesso ao conteúdo de negócio durante o procedimento.
