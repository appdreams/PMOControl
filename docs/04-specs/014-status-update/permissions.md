# SPEC-014 — Status Update — Permissions

**Status:** Draft — política MVP alinhada à matriz SPEC-003; review de grants físicos pendente

## Permissions

- `status.update.view`: leitura de status no Project scope.
- `status.update.create`: criar draft para Project autorizado.
- `status.update.edit`: alterar draft apenas com versão atual.
- `status.update.validate`: validar draft; não publica.
- `status.update.publish`: publicar diretamente no fluxo padrão MVP; Project Manager é elegível quando grant explícito para o Project, PMO Admin/PM conforme grants explícitos.
- `status.update.correct`: corrigir publicação por nova sucessora; exige motivo e grant explícito. Não altera snapshot antigo.

A publicação não exige aprovação de segunda pessoa no fluxo padrão. Nenhum papel nomeado recebe automaticamente permission fora do scope concedido. Tenant, membership ativa, Project scope, permission e versão são revalidados no servidor imediatamente antes do commit. `Platform Admin` não ganha acesso ao conteúdo do Project por administrar a plataforma.

Exportações respeitam permissions e data policy; acesso financial/confidential não decorre de acesso ao status. Todos os grants são deny-by-default. Presets por papel estão em `docs/04-specs/003-rbac/permissions.md`; grants são atribuídos por scope e não ampliam acesso por nome do papel.
