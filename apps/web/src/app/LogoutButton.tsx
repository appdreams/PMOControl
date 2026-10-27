"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

export function LogoutButton() {
  const router = useRouter();
  const [pending, setPending] = useState(false);
  const [error, setError] = useState(false);

  async function logout() {
    setPending(true);
    setError(false);
    try {
      const response = await fetch("/api/v1/auth/logout", { method: "POST", cache: "no-store" });
      if (!response.ok) throw new Error("logout_failed");
      router.replace("/");
      router.refresh();
    } catch {
      setError(true);
      setPending(false);
    }
  }

  return <div className="workspace-logout">
    <button type="button" className="text-button" onClick={logout} disabled={pending}>
      {pending ? "Saindo…" : "Sair"}
    </button>
    {error && <span role="alert">Não foi possível encerrar a sessão. Tente novamente.</span>}
  </div>;
}
