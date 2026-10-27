"use client";

import Link from "next/link";
import { useSyncExternalStore, useState, type FormEvent } from "react";

type AcceptResponse = { tenant?: { id: string; name: string; invitationKind: "first_admin" | "tenant_member"; roleKey: string | null }; error?: { message?: string } };

function subscribeToHash(onChange: () => void) {
  window.addEventListener("hashchange", onChange);
  return () => window.removeEventListener("hashchange", onChange);
}

function getInviteToken() {
  return new URLSearchParams(window.location.hash.slice(1)).get("token") ?? "";
}

export function AcceptInvitation({ authenticated, alreadyAccepted = false }: { authenticated: boolean; alreadyAccepted?: boolean }) {
  const token = useSyncExternalStore(subscribeToHash, getInviteToken, () => "");
  const loginHref = token ? `/?next=${encodeURIComponent(`/convite/aceitar#token=${encodeURIComponent(token)}`)}` : "/";
  const [pending, setPending] = useState(false);
  const [tenant, setTenant] = useState<AcceptResponse["tenant"]>();
  const [message, setMessage] = useState("");
  const [error, setError] = useState(false);

  async function accept(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPending(true);
    setError(false);
    setMessage("Validando o convite…");
    try {
      const response = await fetch("/api/v1/invitations/accept", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ token }),
      });
      const result = await response.json() as AcceptResponse;
      if (!response.ok || !result.tenant) {
        setError(true);
        setMessage(result.error?.message ?? "O convite não pôde ser aceito.");
        return;
      }
      window.history.replaceState(null, "", `${window.location.pathname}?accepted=1`);
      setTenant(result.tenant);
      setMessage("");
    } catch {
      setError(true);
      setMessage("Não foi possível conectar ao serviço. Tente novamente.");
    } finally {
      setPending(false);
    }
  }

  if (tenant) return <>
    <p className="workspace-eyebrow">Acesso ativado</p>
    <h1>Bem-vindo à {tenant.name}</h1>
    <p>{tenant.invitationKind === "first_admin"
      ? "Você agora é o primeiro administrador desta organização."
      : `Seu acesso foi ativado${tenant.roleKey ? ` como ${tenant.roleKey.replaceAll("_", " ")}` : ""}.`}</p>
    <Link className="workspace-link" href={`/workspace?tenantId=${encodeURIComponent(tenant.id)}`}>Abrir organização</Link>
  </>;

  if (authenticated && alreadyAccepted) return <>
    <p>Este convite já foi processado. Abra o espaço de trabalho para conferir sua organização.</p>
    <Link className="workspace-link" href="/workspace">Ir para o espaço de trabalho</Link>
  </>;

  if (!authenticated) return <>
    <p>Entre com a conta que tem o e-mail confirmado usado no convite.</p>
    <Link className="submit-button" href={loginHref}>Entrar para aceitar</Link>
    {!token && <p className="auth-status auth-status-error" role="alert">O link do convite está incompleto ou foi removido. Solicite um novo link ao responsável.</p>}
  </>;

  return <>
    <p>O acesso será concedido somente se o e-mail confirmado da sua sessão corresponder ao destinatário do convite.</p>
    <form className="tenant-provision-form" onSubmit={accept}>
      <button className="submit-button" type="submit" disabled={!token || pending}>{pending ? "Ativando acesso…" : "Aceitar convite"}</button>
      {message && <p className={`auth-status${error ? " auth-status-error" : ""}`} role={error ? "alert" : "status"}>{message}</p>}
      {!token && <p className="auth-status auth-status-error" role="alert">O link do convite está incompleto ou foi removido. Solicite um novo link ao responsável.</p>}
    </form>
  </>;
}
