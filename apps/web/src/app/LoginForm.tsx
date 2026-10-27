"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { createSupabaseBrowserClient } from "@/server/infrastructure/supabase/browser";

function Icon({ name }: { name: "mail" | "lock" | "eye" | "arrow" }) {
  const common = { fill: "none", stroke: "currentColor", strokeWidth: 2, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  const paths = {
    mail: <><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m4 7 8 6 8-6" /></>,
    lock: <><rect x="4" y="10" width="16" height="11" rx="2" /><path d="M8 10V7a4 4 0 0 1 8 0v3m-4 4v3" /></>,
    eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" /></>,
    arrow: <><path d="M5 12h14" /><path d="m13 6 6 6-6 6" /></>,
  };
  return <svg aria-hidden="true" viewBox="0 0 24 24" {...common}>{paths[name]}</svg>;
}

export function LoginForm({ configured, initialNotice = "", redirectTo = "/workspace" }: { configured: boolean; initialNotice?: string; redirectTo?: string }) {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState(initialNotice || (configured
    ? "Informe suas credenciais para entrar."
    : "O serviço de autenticação ainda não está configurado neste ambiente."));
  const [error, setError] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(false);
    setPending(true);
    setMessage("Validando suas credenciais…");
    try {
      const supabase = createSupabaseBrowserClient();
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: email.trim().toLowerCase(),
        password,
      });
      if (signInError) {
        setError(true);
        setMessage("Não foi possível entrar. Confira seu e-mail e sua senha e tente novamente.");
        return;
      }
      router.replace(redirectTo);
      router.refresh();
    } catch {
      setError(true);
      setMessage("O serviço de autenticação está temporariamente indisponível.");
    } finally {
      setPending(false);
    }
  }

  return (
    <form className="login-form" onSubmit={handleSubmit} aria-describedby="auth-status">
      <label htmlFor="email">E-mail</label>
      <div className="input-wrap">
        <span className="field-icon"><Icon name="mail" /></span>
        <input id="email" name="email" type="email" autoComplete="email" placeholder="seu@email.com" required disabled={!configured || pending} value={email} onChange={(event) => setEmail(event.target.value)} aria-describedby="auth-status" />
      </div>
      <label htmlFor="password">Senha</label>
      <div className="input-wrap">
        <span className="field-icon"><Icon name="lock" /></span>
        <input id="password" name="password" type={showPassword ? "text" : "password"} autoComplete="current-password" placeholder="Sua senha" required disabled={!configured || pending} value={password} onChange={(event) => setPassword(event.target.value)} aria-describedby="auth-status" />
        <button type="button" className="password-eye" aria-label={showPassword ? "Ocultar senha" : "Mostrar senha"} aria-pressed={showPassword} onClick={() => setShowPassword((visible) => !visible)} disabled={!configured || pending}><Icon name="eye" /></button>
      </div>
      <div className="form-options">
        <span className="remember"><span aria-hidden="true">✓</span> Lembrar de mim</span>
        <Link className="text-button" href="/recuperar-senha">Esqueceu sua senha?</Link>
      </div>
      <button className="submit-button" type="submit" disabled={!configured || pending}>
        {pending ? "Entrando…" : "Entrar"} {!pending && <Icon name="arrow" />}
      </button>
      <p className={`auth-status${error ? " auth-status-error" : ""}`} id="auth-status" role={error ? "alert" : "status"} aria-live="polite"><span aria-hidden="true">i</span> {message}</p>
    </form>
  );
}
