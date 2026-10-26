# SPEC-023 — Time Machine — Permissions

**Status:** Draft — matriz de leitura; grants finais na Spec 003

- `snapshot.view`: read no scope `Project/Snapshot`.
- Cada seção/campo ainda exige permission/data policy da fonte; projeção não amplia acesso.
- Não há create/edit/delete de negócio neste módulo. Reminder dismissal em My Day só altera preferência pessoal, não Action/Issue/Risk. Refresh/rebuild de projeção é service role, não permission de usuário.
- Export/AI consome somente a mesma projeção autorizada e verifica policy no destino.
