"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";
import { createSupabaseBrowserClient } from "@/server/infrastructure/supabase/browser";

export function RecoveryForm({ configured, invalidLink = false }: { configured: boolean; invalidLink?: boolean }) {
  const [email, setEmail] = useState("");
  const [pending, setPending] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState(false);

  async function requestRecovery(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPending(true);
    setError(false);
    try {
      const supabase = createSupabaseBrowserClient();
      await supabase.auth.resetPasswordForEmail(email.trim().toLowerCase(), {
        redirectTo: `${window.location.origin}/auth/callback`,
      });
      // Keep the same public response for existing and unknown addresses.
      setSent(true);
    } catch {
      setError(true);
    } finally {
      setPending(false);
    }
  }

  return <section className="login-panel recovery-panel" aria-labelledby="recovery-title">
    <div className="panel-heading"><h2 id="recovery-title">Recuperar<br /><span>sua senha</span></h2>
      <p>Informe seu e-mail. Se houver uma conta associada, enviaremos um link de recuperação.</p>
    </div>
    {invalidLink && <p className="auth-status auth-status-error" role="alert">Esse link expirou ou não é válido. Solicite outro.</p>}
    {sent ? <p className="auth-status" role="status">Se houver uma conta para esse endereço, você receberá instruções para redefinir a senha.</p> :
      <form className="login-form" onSubmit={requestRecovery}>
        <label htmlFor="recovery-email">E-mail</label>
        <div className="input-wrap"><input id="recovery-email" name="email" type="email" autoComplete="email" placeholder="seu@email.com" required disabled={!configured || pending} value={email} onChange={(event) => setEmail(event.target.value)} /></div>
        <button className="submit-button" type="submit" disabled={!configured || pending}>{pending ? "Enviando…" : "Enviar instruções"}</button>
        {error && <p className="auth-status auth-status-error" role="alert">Não foi possível solicitar a recuperação agora. Tente novamente mais tarde.</p>}
        {!configured && <p className="auth-status" role="status">O serviço de autenticação não está configurado neste ambiente.</p>}
      </form>}
    <div className="invite-note"><Link href="/">Voltar para entrar</Link></div>
  </section>;
}
