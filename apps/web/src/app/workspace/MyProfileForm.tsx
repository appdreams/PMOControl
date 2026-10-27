"use client";

import { useEffect, useState, type FormEvent } from "react";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";
import { TextField } from "@/components/ui/TextField";

type Profile = { displayName: string; complete: boolean };

export function MyProfileForm() {
  const [profile, setProfile] = useState<Profile | null>(null);
  const [displayName, setDisplayName] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);

  useEffect(() => {
    let active = true;
    void fetch("/api/v1/me/profile", { cache: "no-store" })
      .then(async (response) => {
        const result = await response.json() as { profile?: Profile; error?: { message?: string } };
        if (!response.ok || !result.profile || typeof result.profile.displayName !== "string" || typeof result.profile.complete !== "boolean") {
          throw new Error(result.error?.message ?? "Não foi possível carregar seu perfil.");
        }
        if (active) {
          setProfile(result.profile);
          setDisplayName(result.profile.complete ? result.profile.displayName : "");
        }
      })
      .catch((error: unknown) => {
        if (active) {
          setIsError(true);
          setMessage(error instanceof Error ? error.message : "Não foi possível carregar seu perfil.");
        }
      })
      .finally(() => { if (active) setLoading(false); });
    return () => { active = false; };
  }, []);

  async function saveProfile(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSaving(true); setIsError(false); setMessage("Salvando seu nome…");
    try {
      const response = await fetch("/api/v1/me/profile", {
        method: "PATCH", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ displayName }),
      });
      const result = await response.json() as { profile?: Profile; error?: { message?: string } };
      if (!response.ok || !result.profile) throw new Error(result.error?.message ?? "Não foi possível salvar seu nome.");
      setProfile(result.profile);
      setDisplayName(result.profile.displayName);
      setMessage("Nome atualizado. Ele aparecerá para os membros da organização.");
      window.dispatchEvent(new Event("pmo-profile-updated"));
    } catch (error) {
      setIsError(true);
      setMessage(error instanceof Error ? error.message : "Não foi possível salvar seu nome.");
    } finally { setSaving(false); }
  }

  return <section id="my-profile" className="user-profile" aria-labelledby="user-profile-title">
    <h2 id="user-profile-title">Meu perfil</h2>
    <p>Este nome será exibido para os outros membros e na seleção de gerente de projeto.</p>
    {profile && !profile.complete && <Feedback>Informe seu nome. Até lá, as listas usam um identificador provisório da conta.</Feedback>}
    {loading ? <p role="status">Carregando seu perfil…</p> : <form className="tenant-provision-form" onSubmit={(event) => void saveProfile(event)}>
      <TextField id="my-profile-display-name" label="Nome de exibição" required minLength={2} maxLength={120} autoComplete="name"
        placeholder="Seu nome" value={displayName} onChange={(event) => setDisplayName(event.target.value)} disabled={saving} />
      <Button type="submit" disabled={saving || displayName.trim().length < 2}>
        {saving ? "Salvando…" : "Salvar nome"}
      </Button>
      {message && <Feedback tone={isError ? "error" : message.startsWith("Nome atualizado") ? "success" : "info"}>{message}</Feedback>}
    </form>}
  </section>;
}
