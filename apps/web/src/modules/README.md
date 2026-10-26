# Módulos do monólito

Cada módulo é dono de suas entidades, regras e casos de uso. Organize o código por domínio, não por tipo global de arquivo:

```text
<module>/
  domain/          entidades, regras e contratos do domínio
  application/     casos de uso e orquestração
  infrastructure/  persistência e adapters externos
  interfaces/      Route Handlers, DTOs e contratos de entrada/saída
```

Direção das dependências: `interfaces → application → domain`. A infraestrutura implementa contratos definidos para as camadas internas. O domínio não importa Next.js, Supabase, Inngest ou SDKs de provedores.

Regras de autorização são verificadas no servidor em cada operação. Componentes de UI não são a autoridade de acesso. Cada módulo deve seguir sua Spec e manter limites claros; só compartilhar código quando houver um conceito realmente transversal.
