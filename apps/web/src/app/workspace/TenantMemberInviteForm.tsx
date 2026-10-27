"use client";

import { useEffect, useState, type FormEvent } from "react";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";
import { SelectField } from "@/components/ui/SelectField";
import { TextAreaField } from "@/components/ui/TextAreaField";
import { TextField } from "@/components/ui/TextField";

const ROLE_OPTIONS = [
  ["tenant_admin", "Administrador da organização"],
  ["pmo_admin", "Administrador PMO"],
  ["pmo", "PMO"],
  ["project_manager", "Gerente de projetos"],
  ["contributor", "Colaborador"],
  ["executive", "Executivo"],
  ["viewer", "Visualizador"],
] as const;

type InvitationResponse = {
  invitation?: { id: string; roleKey: string; scopeType: string; scopeId: string; url: string; expiresAt: string };
  error?: { message?: string };
};

type InvitationScope = { scopeType: "tenant" | "portfolio" | "project"; scopeId: string; label: string; roleKeys: string[] };

export function TenantMemberInviteForm({ tenantId }: { tenantId: string }) {
  const [email, setEmail] = useState("");
  const [roleKey, setRoleKey] = useState<string>("");
  const [reason, setReason] = useState("Acesso à organização");
  const [invitation, setInvitation] = useState<InvitationResponse["invitation"]>();
  const [scopes, setScopes] = useState<InvitationScope[] | null>(null);
  const [scopeKey, setScopeKey] = useState("");
  const [message, setMessage] = useState("");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState(false);
  const [scopeLoadError, setScopeLoadError] = useState(false);
  const selectedScope = scopes?.find((scope) => `${scope.scopeType}:${scope.scopeId}` === scopeKey);
  const availableScopes = scopes ?? [];
  const roleOptions = ROLE_OPTIONS.filter(([key]) => selectedScope?.roleKeys.includes(key));
  const selectedRoleKey = roleOptions.some(([key]) => key === roleKey) ? roleKey : roleOptions[0]?.[0] ?? "";

  useEffect(() => {
    let active = true;
    void fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/invitation-scopes`, { cache: "no-store" })
      .then(async (response) => {
        const result = await response.json() as { scopes?: InvitationScope[] };
        if (!response.ok || !Array.isArray(result.scopes)) throw new Error("scopes unavailable");
        if (active) {
          setScopes(result.scopes);
          const first = result.scopes[0];
          setScopeKey(first ? `${first.scopeType}:${first.scopeId}` : "");
          setScopeLoadError(false);
        }
      })
      .catch(() => { if (active) setScopeLoadError(true); });
    return () => { active = false; };
  }, [tenantId]);

  async function createInvitation(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPending(true);
    setError(false);
    setMessage("Gerando link seguro…");
    try {
      const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/invitations`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, roleKey: selectedRoleKey, reason,
          scopeType: selectedScope?.scopeType, scopeId: selectedScope?.scopeId }),
      });
      const result = await response.json() as InvitationResponse;
      if (!response.ok || !result.invitation) {
        setError(true);
        setMessage(result.error?.message ?? "Não foi possível criar o convite.");
        return;
      }
      setInvitation(result.invitation);
      setMessage("Link criado. Compartilhe-o apenas com a pessoa convidada; ele não será enviado por e-mail.");
    } catch {
      setError(true);
      setMessage("Não foi possível conectar ao serviço. Tente novamente.");
    } finally {
      setPending(false);
    }
  }

  async function copyInvitation() {
    if (!invitation) return;
    try {
      await navigator.clipboard.writeText(invitation.url);
      setMessage("Link copiado. Ele expira em sete dias.");
      setError(false);
    } catch {
      setMessage("Não foi possível copiar automaticamente. Selecione e copie o link abaixo.");
      setError(true);
    }
  }

  return <div className="tenant-invite">
    <h3>Convidar membro</h3>
    <p>O acesso será limitado ao escopo escolhido e só ativa após aceite com e-mail confirmado. Uma nova emissão para o mesmo endereço invalida o link anterior.</p>
    {scopes === null && !scopeLoadError ? <p role="status">Verificando escopos que podem ser delegados…</p> : scopeLoadError ?
      <p role="alert">Não foi possível carregar escopos de convite. Atualize a tela e tente novamente.</p> : availableScopes.length === 0 ?
      <p role="status">Seu acesso atual não permite delegar papéis em nenhum escopo desta organização.</p> : <form className="tenant-provision-form" onSubmit={createInvitation}>
      <SelectField id="tenant-member-scope" label="Escopo de acesso" value={scopeKey} onChange={(event) => setScopeKey(event.target.value)} disabled={pending || Boolean(invitation)}>
        {availableScopes.map((scope) => <option key={`${scope.scopeType}:${scope.scopeId}`} value={`${scope.scopeType}:${scope.scopeId}`}>
          {scope.scopeType === "tenant" ? `Organização · ${scope.label}` : `${scope.scopeType === "portfolio" ? "Portfólio" : "Projeto"} · ${scope.label}`}
        </option>)}
      </SelectField>
      <TextField id="tenant-member-email" label="E-mail da pessoa" type="email" autoComplete="email" required maxLength={320}
        value={email} onChange={(event) => setEmail(event.target.value)} disabled={pending || Boolean(invitation)} />
      <SelectField id="tenant-member-role" label="Papel no escopo escolhido" value={selectedRoleKey} onChange={(event) => setRoleKey(event.target.value)} disabled={pending || Boolean(invitation) || roleOptions.length === 0}>
        {roleOptions.map(([key, name]) => <option key={key} value={key}>{name}</option>)}
      </SelectField>
      <TextAreaField id="tenant-member-reason" label="Motivo do convite" required maxLength={1000} rows={2}
        value={reason} onChange={(event) => setReason(event.target.value)} disabled={pending || Boolean(invitation)} />
      <Button type="submit" disabled={pending || Boolean(invitation) || !selectedScope || !selectedRoleKey}>
        {pending ? "Gerando link…" : "Gerar convite"}
      </Button>
      {invitation && <>
        <label htmlFor="tenant-member-invitation-link">Link de aceite (expira {new Date(invitation.expiresAt).toLocaleDateString("pt-BR")})</label>
        <input id="tenant-member-invitation-link" type="text" readOnly value={invitation.url}
          onFocus={(event) => event.currentTarget.select()} />
        <button className="workspace-link" type="button" onClick={() => void copyInvitation()}>Copiar link</button>
      </>}
      {message && <Feedback tone={error ? "error" : invitation ? "success" : "info"}>{message}</Feedback>}
    </form>}
  </div>;
}
