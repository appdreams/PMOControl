"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo, useRef, useState, type FormEvent } from "react";
import { generateTenantSlug } from "@/modules/identity/domain/tenant-slug";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";
import { TextAreaField } from "@/components/ui/TextAreaField";
import { TextField } from "@/components/ui/TextField";

type ProvisionResponse = { tenant?: { id: string; name: string; slug: string }; error?: { message?: string } };
type InvitationResponse = { invitation?: { url: string; expiresAt: string }; error?: { message?: string } };
type TenantSetup = { id: string; name: string; slug: string; firstAdminActivated: boolean; pendingInvitation: boolean };

export function NewTenantForm({ initialTenant }: { initialTenant?: TenantSetup }) {
  const router = useRouter();
  const idempotencyKey = useRef<string | null>(null);
  const idempotencyFingerprint = useRef<string | null>(null);
  const [displayName, setDisplayName] = useState("");
  const [reason, setReason] = useState("");
  const [pending, setPending] = useState(false);
  const [tenant, setTenant] = useState<TenantSetup | ProvisionResponse["tenant"]>(initialTenant);
  const [error, setError] = useState("");
  const [adminEmail, setAdminEmail] = useState("");
  const [invitationReason, setInvitationReason] = useState("Ativação inicial do administrador da organização");
  const [invitationUrl, setInvitationUrl] = useState("");
  const [invitationPending, setInvitationPending] = useState(false);
  const [invitationError, setInvitationError] = useState("");
  const [copyStatus, setCopyStatus] = useState("");
  const generatedSlug = useMemo(() => generateTenantSlug(displayName.trim()), [displayName]);

  async function inviteFirstAdmin(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!tenant) return;
    setInvitationPending(true);
    setInvitationError("");
    setInvitationUrl("");
    setCopyStatus("");
    try {
      const response = await fetch(`/api/v1/tenants/${tenant.id}/invitations/first-admin`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: adminEmail.trim(), reason: invitationReason.trim() }),
      });
      const result = await response.json() as InvitationResponse;
      if (!response.ok || !result.invitation) {
        setInvitationError(result.error?.message ?? "Não foi possível gerar o convite.");
        return;
      }
      setInvitationUrl(result.invitation.url);
    } catch {
      setInvitationError("Não foi possível conectar ao serviço. Tente novamente.");
    } finally {
      setInvitationPending(false);
    }
  }

  async function copyInvitation() {
    try {
      await navigator.clipboard.writeText(invitationUrl);
      setCopyStatus("Link copiado.");
    } catch {
      setCopyStatus("Selecione e copie o link manualmente.");
    }
  }

  async function createTenant(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPending(true);
    setError("");
    const requestFingerprint = JSON.stringify({
      slug: generatedSlug,
      displayName: displayName.trim(),
      reason: reason.trim(),
    });
    let requestIdempotencyKey = idempotencyKey.current;
    if (!requestIdempotencyKey || idempotencyFingerprint.current !== requestFingerprint) {
      requestIdempotencyKey = crypto.randomUUID();
      idempotencyKey.current = requestIdempotencyKey;
      idempotencyFingerprint.current = requestFingerprint;
    }
    try {
      const response = await fetch("/api/v1/tenants", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ displayName: displayName.trim(), reason: reason.trim(), idempotencyKey: requestIdempotencyKey }),
      });
      const result = await response.json() as ProvisionResponse;
      if (!response.ok || !result.tenant) {
        if (response.status === 409) {
          setError("Já existe uma organização com esse nome ou a solicitação entrou em conflito. Ajuste o nome e tente novamente.");
          return;
        }
        setError(result.error?.message ?? "Não foi possível provisionar a organização.");
        return;
      }
      setTenant(result.tenant);
      router.replace(`/workspace/tenants/new?tenantId=${encodeURIComponent(result.tenant.id)}`);
    } catch {
      setError("Não foi possível conectar ao serviço. Tente novamente.");
    } finally {
      setPending(false);
    }
  }

  if (tenant) return <div aria-live="polite">
    <p className="workspace-eyebrow">Tenant criado</p>
    <h1>{tenant.name}</h1>
    <p>Identificador: <code>{tenant.slug}</code></p>
    {"firstAdminActivated" in tenant && tenant.firstAdminActivated ? <>
      <h2>Primeiro administrador ativado</h2>
      <p>Esta organização já possui uma membership ativa ou um convite bootstrap aceito.</p>
    </> : <>
    <h2>Convidar primeiro administrador</h2>
    <p>O convite concede o papel Tenant Admin depois que a pessoa entrar com uma conta Auth cujo e-mail confirmado corresponda ao endereço convidado.</p>
    {"pendingInvitation" in tenant && tenant.pendingInvitation && <Feedback>Há um link pendente, mas o token não pode ser recuperado depois que esta tela for fechada. Gere outro link para revogar o anterior e copiar o novo.</Feedback>}
    <form className="tenant-provision-form" onSubmit={inviteFirstAdmin}>
      <TextField id="first-admin-email" label="E-mail do primeiro administrador" type="email" autoComplete="email" required maxLength={320} value={adminEmail} onChange={(event) => setAdminEmail(event.target.value)} disabled={invitationPending || Boolean(invitationUrl)} />
      <TextAreaField id="first-admin-reason" label="Motivo do convite" required maxLength={1000} rows={2} value={invitationReason} onChange={(event) => setInvitationReason(event.target.value)} disabled={invitationPending || Boolean(invitationUrl)} />
      <Button type="submit" disabled={invitationPending || Boolean(invitationUrl)}>{invitationPending ? "Gerando link…" : ("pendingInvitation" in tenant && tenant.pendingInvitation ? "Gerar novo link" : "Gerar convite")}</Button>
      {invitationError && <Feedback tone="error">{invitationError}</Feedback>}
      {invitationUrl && <>
        <TextField id="first-admin-link" label="Link de uso único, válido por 7 dias" type="text" readOnly value={invitationUrl} onFocus={(event) => event.currentTarget.select()} aria-describedby="first-admin-link-note" />
        <Button type="button" onClick={copyInvitation}>Copiar link do convite</Button>
        <p className="auth-status" id="first-admin-link-note" role="status">Compartilhe o link diretamente com o destinatário. Nenhum e-mail é enviado pelo sistema. {copyStatus}</p>
        <button className="workspace-link" type="button" onClick={() => setInvitationUrl("")}>Gerar outro link (revoga o anterior)</button>
      </>}
    </form>
    </>}
    <Link className="workspace-link" href="/workspace">Voltar ao espaço de trabalho</Link>
  </div>;

  return <form className="tenant-provision-form" onSubmit={createTenant}>
    <TextField id="tenant-display-name" label="Nome da organização" required maxLength={160} value={displayName} onChange={(event) => setDisplayName(event.target.value)} disabled={pending} aria-describedby="tenant-slug-preview" />
    <p className="auth-status" id="tenant-slug-preview" aria-live="polite">
      Identificador gerado automaticamente: {generatedSlug ? <code>{generatedSlug}</code> : "insira um nome que gere pelo menos 3 letras ou números"}
    </p>
    <TextAreaField id="tenant-reason" label="Motivo do provisionamento" required maxLength={1000} rows={3} value={reason} onChange={(event) => setReason(event.target.value)} disabled={pending} />
    <Button type="submit" disabled={pending || !generatedSlug}>{pending ? "Provisionando…" : "Criar organização"}</Button>
    {error && <Feedback tone="error">{error}</Feedback>}
    <p className="auth-status">A criação exige o grant de plataforma `tenant.lifecycle.create`. O usuário atual não recebe membership automaticamente.</p>
  </form>;
}
