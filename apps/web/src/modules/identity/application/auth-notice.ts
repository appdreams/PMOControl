export function getAuthNotice(params: { session?: string; passwordUpdated?: string }): string {
  if (params.session === "expired") {
    return "Sua sessão terminou ou não é mais válida. Entre novamente para continuar.";
  }
  if (params.passwordUpdated === "1") return "Senha atualizada. Entre com sua nova senha.";
  return "";
}
