# Administrative & Support Access

**Status:** Draft — política de produto; procedimento operacional requer validação

## Platform Admin

Somente a equipe da plataforma cria, suspende e encerra tenants, além de administrar quotas e saúde da plataforma. Platform Admin não tem acesso automático a conteúdo de negócio.

## Acesso de suporte a dados de cliente

Default deny. Acesso ao conteúdo só para ticket/incidente legítimo e quando dados operacionais não bastarem:

1. Registrar ticket/incident ID, tenant, recurso/categorias, finalidade e solicitante.
2. Aprovador da plataforma diferente do solicitante autoriza; conteúdo sensível requer consentimento explícito do contato do cliente, salvo emergência documentada.
3. Conceder acesso Just-in-Time, tenant/resource-scoped, read-only por padrão e por até 60 minutos. Escrita/exportação requer permissão específica e justificativa.
4. Operador usa conta individual e MFA corporativo (MFA para usuários finais permanece fora do MVP).
5. Auditar concessão, aprovador, ator, tenant, escopo, início/fim, operações e revogação, sem registrar secrets ou conteúdo integral.
6. Revogar ao expirar/fechar ticket; revisar break-glass em até um dia útil.

Break-glass somente para conter incidente ativo, com motivo, escopo mínimo, alerta de segurança e revisão independente posterior. Sem contas compartilhadas. Acesso privilegiado falha fechado se autorização, escopo ou expiração não puderem ser verificados.

## Platform Root Admin — Project purge

Entitlement explícito `platform.projects.purge` permite somente metadados mínimos, preview, confirmação e acompanhamento do purge. Não dá acesso ao conteúdo de negócio e não substitui o workflow de suporte/JIT. Cada uso exige motivo e confirmação, revalidação server-side, audit append-only e respeito a retention/legal hold; Platform Admin comum não possui a capability por padrão.
