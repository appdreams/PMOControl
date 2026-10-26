# PMO Control --- Documentation Changelog

Todas as mudanças semanticamente relevantes na documentação devem ser
registradas aqui.

O histórico detalhado permanece no Git.

Formato inspirado em Keep a Changelog, adaptado ao projeto.

## \[Unreleased\]

### Added

- Findings semânticos e remediações registradas em `SDD-AUDIT-REPORT.md`.
- Contratos de cálculo determinístico `rag-v1` e snapshot imutável/hash `snapshot-v1` nas Specs 015/016, PDD, Data, API e Testing.
- Cadência mensal, checklist de publicação e fórmulas reproduzíveis `kpi-v1` definidos na Spec 014 e refletidos em PDD, banco, API, UX e casos de teste.
- Matriz explícita de presets RBAC e shape de contexto RLS confiável adicionados; políticas de segurança e UX de Status mantidas em Draft até verificação.
- Achados F-006/F-008 avançados: roles/denies e contexto RLS detalhados; passos UX de Status mapeados a FR/permission/AC/TC. Manifests dos domínios não reauditados rebaixados para Draft.
- Adicionado crosswalk inicial para 32 telas UX, depois ampliado para 33 com a configuração/uso de IA por Tenant; inclui telas de administração de Tenant/acesso e índice central de rotas/allowlists de API.
- Criado coverage register RLS para as tabelas canônicas; anotado que execução não é possível neste workspace, que contém apenas documentação. A contagem atual reconciliada é 58, com uma linha por tabela.
- Corrigidos os mapas FR/AC/TC de Multi-Tenancy, RBAC e Audit; varreduras estáticas confirmaram IDs válidos nas 29 Specs e nenhum link Markdown local ausente.
- Fechadas recomendações de transferência de administrador Tenant e contestação de export; rastreabilidade e política export-first atualizadas.
- Audit report registra os gates de runtime indisponíveis porque este workspace contém somente documentação; nenhum teste de aplicação foi alegado.
- Adicionadas as tabelas canônicas `tenant_export_disputes`, `decision_comments` e `notification_preferences`, com cobertura RLS; inventário atualizado para 58 tabelas.
- Auditoria de acompanhamento identificou que várias Specs ainda contêm cláusulas genéricas em DB/API/AC/testes; relatório mantém F-004/F-007 abertos e distingue validação estática de aprovação semântica.
- Aprofundados contratos de banco e API por operação nas Specs 004–013, 020–022, 024–026 e 028–029; estados, prioridade, relacionamentos, constraints e grants foram alinhados ao PDD/RBAC.
- Reconciliados relacionamentos canônicos de TenantExportDispute, DecisionComment e NotificationPreference no modelo de dados e no registro RLS.
- SPEC-025/PDD atualizados para credenciais BYOK próprias por Tenant, três modelos de complexidade, roteamento automático determinístico/versionado e ledger append-only de uso/custo com permissões segregadas.
- Adicionadas APIs lógicas para configurar/validar/rotacionar/desabilitar provider, consultar/exportar gastos e uma tela administrativa de configuração/uso; telemetria diferencia valores reportados, estimados e indisponíveis.
- Catálogo de dados/RLS expandido de 58 para 60 tabelas (`ai_provider_configs`, `ai_usage_records`); roteabilidade e tela nova ligada à rastreabilidade UX, PDD, RBAC e eventos.
- Allowlist MVP de provedores AI definida: OpenAI GPT, Google Gemini, Anthropic Claude, Meta Llama, DeepSeek e OpenRouter; adapters/capabilities são validados, IDs de endpoint ficam na allowlist da plataforma e credenciais/modelos permanecem separados por Tenant/provedor.
- Adicionada à SPEC-028 a importação de dataset de projeto por workbook `.xlsx` v1 com template vazio e exemplo sintético, seletor tenant-scoped, validação por célula, carga inicial sem prompt, modo append insert-only e restart atômico protegido que preserva o histórico imutável.
- Definidos valores padrão iniciais por Tenant para tipos/criticidade de marcos, categorias/tendências de riscos e origem de ações; Specs 007/009/011, seed de referência, contrato de importação, guia leigo e validações das planilhas alinhados.
- Criada a fundação da aplicação em `apps/web` com Next.js + TypeScript, layout inicial em pt-BR, health endpoint, regras de organização modular, exemplo de ambiente e workflow de CI. Nenhum módulo de negócio ou schema de banco foi iniciado.
- Preparação para desenvolvimento local: workflow GitHub Actions de lint/typecheck/build, Supabase local versionado, Node.js fixado, `.gitignore` raiz e guia de provisionamento; primeira migration e configuração de serviços hospedados permanecem portões da fatia Identity & Access.
- Matriz RLS normalizada para listar individualmente cada uma das 60 tabelas canônicas; reconciliação estática encontrou correspondência 60/60, sem substituir execução de políticas.
- Corrigida a nulabilidade de orçamento/forecast financeiro antes da baseline aprovada; índice de Issues alinhado a `priority` e nível de Risk à avaliação atual.
- Endpoints das Specs agora distinguem payloads lógicos definidos do contrato OpenAPI compilável ainda pendente; checagem final de links locais passou (0 quebrados) e 29 pastas de Specs foram encontradas.

-   Root documentation governance files.
-   Master README.
-   Master Manifest.
-   Master Traceability.
-   Dependency Map.
-   Implementation Plan.
-   MVP Checklist.
-   Documentation Changelog.

### Changed

- Status de aprovação das Specs alterado para Draft até revisão semântica.
- Contratos iniciais de autenticação, multi-tenancy e publicação de status detalhados; critérios/testes transacionais de Status adicionados.
- Publicação no PDD esclarece atomicidade autoritativa e efeitos assíncronos pós-commit.
- Manifest e Traceability agora declaram o limite da cobertura atual.
- Decisões MVP registradas: email/senha (MFA posterior, sem SSO), lifecycle de tenant pela plataforma, memberships múltiplas, convite de 7 dias, quotas por plano, encerramento export-first, defaults de retenção, suporte JIT e publicação/correção direta por PM autorizado.
- Alinhados workflow de Status e política de publicação direta entre PDD, journeys, functional map, MVP scope, foundation, architecture, API, Specs e workflow tests; approval por segunda pessoa removida como requisito padrão.
- Defaults de retenção por categoria e encerramento export-first documentados, sujeitos à revisão jurídica/contratual.
- Baseline SDD 1.0 permanece bloqueada até remediação restante e re-auditoria.
- Matriz de rastreabilidade reforçada para publicação → RAG → snapshot → API/permissões/AC/testes; outros domínios ainda precisam revisão equivalente.

### Deprecated

-   None.

### Removed

-   None.

### Security

-   None.

### Architecture

-   Estrutura documental principal consolidada de `00-foundation` a
    `13-guides`.

## Regras de atualização

Registrar aqui mudanças como: - novo módulo/Spec; - alteração de
workflow crítico; - mudança de modelo de autorização; - mudança
arquitetural importante; - nova integração oficial; - mudança de
estratégia de AI/BYOK; - alteração de snapshot/RAG/publicação; -
depreciação ou remoção de capacidade; - mudança relevante de segurança.

Correções ortográficas e ajustes editoriais sem efeito semântico não
precisam de entrada individual.
- Adicionadas exclusão definitiva de Project por entitlement exclusivo Platform Root Admin (com confirmação, purge retomável e retenção histórica) e interação global Box Focus por duplo clique/teclado; Specs 003/005, PDD, UX, retenção, segurança, API e rastreabilidade atualizados.
