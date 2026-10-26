# AI BYOK Configuration Guide

**Status:** Approved

## Fluxo

Tenant Admin autorizado → escolher provider → informar credential →
validar → selecionar modelos/policies → ativar.

## Segurança

Chave é mascarada e nunca retornada em claro.

## MVP

OpenAI primeiro; arquitetura preparada para providers adicionais.

## Falha

Credencial inválida desabilita função de IA afetada, não o core do PMO
Control.
