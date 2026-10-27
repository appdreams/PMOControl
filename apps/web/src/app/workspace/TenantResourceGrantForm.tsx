"use client";

import { useEffect, useState, type FormEvent } from "react";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";
import { SelectField } from "@/components/ui/SelectField";
import { TextAreaField } from "@/components/ui/TextAreaField";

const ROLE_OPTIONS = [
  ["pmo_admin", "Administrador PMO"], ["pmo", "PMO"],
  ["project_manager", "Gerente de projetos"], ["contributor", "Colaborador"],
  ["executive", "Executivo"], ["viewer", "Visualizador"],
] as const;
type Resource = { scopeType: "portfolio" | "project"; scopeId: string; label: string };

export function TenantResourceGrantForm({ tenantId, subjectId, memberLabel }: {
  tenantId: string; subjectId: string; memberLabel: string;
}) {
  const [resources, setResources] = useState<Resource[] | null>(null);
  const [scopeKey, setScopeKey] = useState("");
  const [roleKey, setRoleKey] = useState<string>("viewer");
  const [reason, setReason] = useState("Acesso ao recurso");
  const [idempotencyKey, setIdempotencyKey] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState(false);
  const [pending, setPending] = useState(false);
  const [loadError, setLoadError] = useState(false);
  const [completedAssignment, setCompletedAssignment] = useState("");
  const selected = resources?.find((resource) => `${resource.scopeType}:${resource.scopeId}` === scopeKey);

  useEffect(() => {
    let active = true;
    void fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/resource-grant-targets`, { cache: "no-store" })
      .then(async (response) => {
        const data = await response.json() as { resources?: Resource[] };
        if (!response.ok || !Array.isArray(data.resources)) throw new Error("Não foi possível carregar os recursos.");
        if (active) {
          setResources(data.resources);
          const first = data.resources[0];
          setScopeKey(first ? `${first.scopeType}:${first.scopeId}` : "");
          setLoadError(false);
        }
      }).catch(() => {
        if (active) {
          setLoadError(true);
        }
      });
    return () => { active = false; };
  }, [tenantId]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!selected) return;
    setPending(true); setError(false); setMessage("Registrando papel e auditoria…");
    try {
      const requestKey = idempotencyKey || crypto.randomUUID();
      setIdempotencyKey(requestKey);
      const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/resource-grants`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ subjectId, roleKey, scopeType: selected.scopeType, scopeId: selected.scopeId,
          reason, idempotencyKey: requestKey }),
      });
      const data = await response.json() as { grant?: { grantId?: string }; error?: { message?: string } };
      if (!response.ok || typeof data.grant?.grantId !== "string") {
        setError(true); setMessage(data.error?.message ?? "Não foi possível atribuir este papel."); return;
      }
      setIdempotencyKey("");
      setCompletedAssignment(`${selected.scopeType}:${selected.scopeId}:${roleKey}`);
      setMessage("Papel atribuído e registrado na auditoria.");
    } catch {
      setError(true); setMessage("Não foi possível conectar ao serviço. Tente novamente.");
    } finally { setPending(false); }
  }

  return <form className="tenant-provision-form tenant-resource-grant-form" onSubmit={(event) => void submit(event)}>
    <h4>Atribuir papel de recurso para {memberLabel}</h4>
    {resources === null && !loadError ? <p role="status">Carregando recursos…</p> : loadError || resources === null ?
      <p role="alert">Não foi possível carregar os recursos. Feche e tente novamente.</p> : resources.length === 0 ?
      <p role="status">Não há Portfolios ou Projetos ativos nesta organização para receber um papel.</p> : <>
        <SelectField id={`resource-grant-scope-${subjectId}`} label="Recurso" value={scopeKey} onChange={(event) => { setIdempotencyKey(""); setMessage(""); setScopeKey(event.target.value); }} disabled={pending}>
          {resources.map((resource) => <option key={`${resource.scopeType}:${resource.scopeId}`} value={`${resource.scopeType}:${resource.scopeId}`}>
            {resource.scopeType === "portfolio" ? "Portfólio" : "Projeto"} · {resource.label}
          </option>)}
        </SelectField>
        <SelectField id={`resource-grant-role-${subjectId}`} label="Papel" value={roleKey} onChange={(event) => { setIdempotencyKey(""); setMessage(""); setRoleKey(event.target.value); }} disabled={pending}>
          {ROLE_OPTIONS.map(([key, label]) => <option value={key} key={key}>{label}</option>)}
        </SelectField>
        <TextAreaField id={`resource-grant-reason-${subjectId}`} label="Motivo" required maxLength={1000} rows={2}
          value={reason} onChange={(event) => { setIdempotencyKey(""); setMessage(""); setReason(event.target.value); }} disabled={pending} />
        <Button type="submit" disabled={pending || !selected || reason.trim().length === 0 || completedAssignment === `${selected?.scopeType}:${selected?.scopeId}:${roleKey}`}>
          {pending ? "Atribuindo…" : completedAssignment === `${selected?.scopeType}:${selected?.scopeId}:${roleKey}` ? "Papel atribuído" : "Atribuir papel"}
        </Button>
      </>}
    {message && <Feedback tone={error ? "error" : completedAssignment ? "success" : "info"}>{message}</Feedback>}
  </form>;
}
