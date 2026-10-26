# Connection Lifecycle

**Status:** Approved

## Fluxo

Create → Configure → Authenticate → Validate → Activate → Monitor →
Rotate/Reauthorize → Disable/Revoke.

## Disconnect

Revogar credencial/token quando provider permitir e interromper jobs
futuros.

## Data

Desconectar não apaga automaticamente dados governados já importados;
retenção segue política.

## Audit

Conexão, reautorização, rotação e revogação são eventos sensíveis.
