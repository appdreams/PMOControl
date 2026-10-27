"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { createSupabaseBrowserClient } from "@/server/infrastructure/supabase/browser";

export function PasswordResetForm() {
  const router = useRouter();
  const [password, setPassword] = useState("");
  const [confirmation, setConfirmation] = useState("");
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState(false);

  async function updatePassword(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(false);
    if (password !== confirmation) {
      setError(true);
      setMessage("As senhas não correspondem.");
      return;
    }
    setPending(true);
    setMessage("Atualizando sua senha…");
    try {
      const supabase = createSupabaseBrowserClient();
      const { error: updateError } = await supabase.auth.updateUser({ password });
      if (updateError) throw updateError;
      const { error: signOutError } = await supabase.auth.signOut({ scope: "local" });
      if (signOutError) {
        setMessage("Sua senha foi atualizada. Encerre a sessão atual antes de entrar novamente.");
        setPending(false);
        return;
      }
      router.replace("/?passwordUpdated=1");
      router.refresh();
    } catch {
      setError(true);
      setMessage("Não foi possível atualizar a senha. Solicite um novo link e tente novamente.");
      setPending(false);
    }
  }

  return <section className="login-panel recovery-panel" aria-labelledby="reset-title">
    <div className="panel-heading"><h2 id="reset-title">Defina uma<br /><span>nova senha</span></h2>
      <p>Escolha uma senha para acessar sua conta.</p>
    </div>
    <form className="login-form" onSubmit={updatePassword}>
      <label htmlFor="new-password">Nova senha</label>
      <div className="input-wrap"><input id="new-password" type="password" autoComplete="new-password" minLength={8} required disabled={pending} value={password} onChange={(event) => setPassword(event.target.value)} /></div>
      <label htmlFor="confirm-password">Confirme a senha</label>
      <div className="input-wrap"><input id="confirm-password" type="password" autoComplete="new-password" minLength={8} required disabled={pending} value={confirmation} onChange={(event) => setConfirmation(event.target.value)} /></div>
      <button className="submit-button" type="submit" disabled={pending}>{pending ? "Atualizando…" : "Salvar nova senha"}</button>
      {message && <p className={`auth-status${error ? " auth-status-error" : ""}`} role={error ? "alert" : "status"}>{message}</p>}
    </form>
  </section>;
}
