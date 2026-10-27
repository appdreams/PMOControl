"use client";

import { useEffect, useState, type FormEvent } from "react";
import { TenantMemberInviteForm } from "./TenantMemberInviteForm";
import { TenantResourceGrantForm } from "./TenantResourceGrantForm";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";
import { TextAreaField } from "@/components/ui/TextAreaField";

type Member = {
  membershipId: string;
  userId: string;
  displayName: string;
  status: "active" | "suspended" | "revoked";
  activatedAt: string;
  version: string;
  tenantRoleKeys: string[];
};

const ROLE_NAMES: Record<string, string> = {
  tenant_admin: "Administrador da organização",
  pmo_admin: "Administrador PMO",
  pmo: "PMO",
  project_manager: "Gerente de projetos",
  contributor: "Colaborador",
  executive: "Executivo",
  viewer: "Visualizador",
};

const STATUS_NAMES: Record<Member["status"], string> = {
  active: "Ativo",
  suspended: "Suspenso",
  revoked: "Revogado",
};

export function TenantMembersPanel({ tenantId, actorId }: { tenantId: string; actorId: string }) {
  const [members, setMembers] = useState<Member[] | null>(null);
  const [message, setMessage] = useState("");
  const [messageError, setMessageError] = useState(false);
  const [action, setAction] = useState<{ membershipId: string; kind: "suspend" | "reactivate" | "revoke" } | null>(null);
  const [actionReason, setActionReason] = useState("");
  const [idempotencyKey, setIdempotencyKey] = useState("");
  const [pendingMembershipId, setPendingMembershipId] = useState<string | null>(null);
  const [grantFormSubjectId, setGrantFormSubjectId] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    async function loadMembers() {
      try {
        const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/members`, { cache: "no-store" });
        const result = await response.json() as { members?: Member[]; error?: { message?: string } };
        if (!response.ok || !Array.isArray(result.members)) {
          throw new Error(result.error?.message ?? "Não foi possível carregar a lista de membros.");
        }
        if (active) { setMembers(result.members); setMessageError(false); }
      } catch (error: unknown) {
        if (active) {
          setMessageError(true);
          setMessage(error instanceof Error ? error.message : "Não foi possível carregar a lista de membros.");
        }
      }
    }
    const refreshAfterProfileUpdate = () => { void loadMembers(); };
    window.addEventListener("pmo-profile-updated", refreshAfterProfileUpdate);
    void loadMembers();
    return () => { active = false; window.removeEventListener("pmo-profile-updated", refreshAfterProfileUpdate); };
  }, [tenantId]);

  const actorMembership = members?.find((member) => member.userId === actorId);
  const mayManageMembership = actorMembership?.tenantRoleKeys.some((key) => key === "tenant_admin" || key === "pmo_admin") ?? false;

  function beginAction(member: Member, kind: "suspend" | "reactivate" | "revoke") {
    setMessage("");
    setMessageError(false);
    setAction({ membershipId: member.membershipId, kind });
    setActionReason("");
    setIdempotencyKey(crypto.randomUUID());
  }

  async function submitAction(event: FormEvent<HTMLFormElement>, member: Member) {
    event.preventDefault();
    if (!idempotencyKey || !action || action.membershipId !== member.membershipId) return;
    const selectedAction = action;
    setPendingMembershipId(member.membershipId);
    setMessage("");
    setMessageError(false);
    try {
      const lifecycle = selectedAction.kind !== "revoke";
      const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/members/${encodeURIComponent(member.membershipId)}/${lifecycle ? "lifecycle" : "revoke"}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...(lifecycle ? { transition: selectedAction.kind } : {}),
          reason: actionReason,
          expectedVersion: member.version,
          idempotencyKey,
        }),
      });
      const result = await response.json() as {
        membership?: { status?: string; version?: string };
        error?: { message?: string };
      };
      const nextStatus: Member["status"] = selectedAction.kind === "revoke" ? "revoked" : selectedAction.kind === "suspend" ? "suspended" : "active";
      if (!response.ok || result.membership?.status !== nextStatus || !result.membership.version) {
        setMessageError(true);
        setMessage(result.error?.message ?? "Não foi possível alterar este acesso.");
        return;
      }
      setMembers((current) => current?.map((item) => item.membershipId === member.membershipId
        ? { ...item, status: nextStatus, version: result.membership!.version!, ...(nextStatus === "revoked" ? { tenantRoleKeys: [] } : {}) }
        : item) ?? null);
      setMessage(selectedAction.kind === "revoke"
        ? "Acesso revogado e registrado na auditoria."
        : selectedAction.kind === "suspend" ? "Acesso suspenso e registrado na auditoria." : "Acesso reativado e registrado na auditoria.");
      setAction(null);
      setIdempotencyKey("");
    } catch {
      setMessageError(true);
      setMessage("Não foi possível conectar ao serviço. Tente novamente.");
    } finally {
      setPendingMembershipId(null);
    }
  }

  return <section id="tenant-members" className="tenant-members" aria-labelledby="tenant-members-title">
    <h2 id="tenant-members-title">Membros da organização</h2>
    <p>Esta lista mostra apenas dados básicos e papéis concedidos no escopo da organização.</p>
    {message && <Feedback tone={messageError ? "error" : message.includes("registrado na auditoria") ? "success" : "info"}>{message}</Feedback>}
    {members === null ?
      <p role="status">Carregando membros…</p> : members.length === 0 ?
        <p>Nenhum membro cadastrado.</p> :
        <ul className="tenant-members-list">
          {members.map((member) => <li key={member.membershipId}>
            <div className="tenant-member-row">
              <div>
                <strong>{member.displayName}</strong>
                <span>{member.tenantRoleKeys.length
                  ? member.tenantRoleKeys.map((key) => ROLE_NAMES[key] ?? key).join(" · ")
                  : "Sem papel no escopo da organização"}</span>
              </div>
              <div className="tenant-member-actions">
                <span className={`tenant-member-status tenant-member-status-${member.status}`}>{STATUS_NAMES[member.status]}</span>
                {mayManageMembership && member.status !== "revoked" && member.userId !== actorId && <>
                  <Button variant="secondary" className="tenant-member-manage" type="button" disabled={pendingMembershipId !== null}
                    onClick={() => beginAction(member, member.status === "active" ? "suspend" : "reactivate")}>
                    {member.status === "active" ? "Suspender" : "Reativar acesso"}
                  </Button>
                  <Button variant="danger" className="tenant-member-revoke" type="button" disabled={pendingMembershipId !== null}
                    onClick={() => beginAction(member, "revoke")}>Revogar acesso</Button>
                  {member.status === "active" && <Button variant="secondary" className="tenant-member-manage" type="button"
                    onClick={() => setGrantFormSubjectId((current) => current === member.userId ? null : member.userId)}>
                    {grantFormSubjectId === member.userId ? "Fechar atribuição" : "Atribuir papel de recurso"}
                  </Button>}
                </>}
              </div>
            </div>
            {grantFormSubjectId === member.userId && member.status === "active" &&
              <TenantResourceGrantForm tenantId={tenantId} subjectId={member.userId}
              memberLabel={member.displayName} />}
            {action?.membershipId === member.membershipId && <form className="tenant-member-revoke-form" onSubmit={(event) => void submitAction(event, member)}>
              <TextAreaField id={`membership-action-reason-${member.membershipId}`} label={action.kind === "revoke" ? "Motivo da revogação" : action.kind === "suspend" ? "Motivo da suspensão" : "Motivo da reativação"} required maxLength={1000} rows={2}
                value={actionReason} onChange={(event) => setActionReason(event.target.value)} disabled={pendingMembershipId !== null} />
              <div>
                <Button variant={action.kind === "revoke" ? "danger" : "secondary"} className={action.kind === "revoke" ? "tenant-member-revoke-form-submit" : "tenant-member-confirm-manage"} type="submit" disabled={pendingMembershipId !== null || actionReason.trim().length === 0}>
                  {pendingMembershipId === member.membershipId ? "Salvando…" : action.kind === "revoke" ? "Confirmar revogação" : action.kind === "suspend" ? "Confirmar suspensão" : "Confirmar reativação"}
                </Button>
                <Button variant="secondary" type="button" disabled={pendingMembershipId !== null} onClick={() => {
                  setAction(null);
                  setIdempotencyKey("");
                }}>Cancelar</Button>
              </div>
            </form>}
          </li>)}
        </ul>}
    <TenantMemberInviteForm tenantId={tenantId} />
  </section>;
}
