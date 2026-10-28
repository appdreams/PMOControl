"use client";

import { useEffect, useState, type FormEvent } from "react";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";

type ExportNotice = {
  tenantId: string;
  tenantName: string;
  exportId: string;
  status: "available" | "purge_eligible";
  availableAt: string;
  purgeAfter: string;
  artifactBytes: number;
  firstDownloadedAt: string | null;
  notifiedAt: string;
};

const exportDatasets = [
  ["tenant", "Organização"], ["userProfiles", "Perfis"], ["memberships", "Membros"],
  ["invitations", "Convites"], ["roles", "Papéis"], ["rolePermissions", "Permissões"],
  ["accessGrants", "Acessos"], ["portfolios", "Portfólios"], ["projects", "Projetos"],
  ["portfolioProjects", "Associações"], ["auditEvents", "Auditoria"],
] as const;

function formatDate(value: string): string {
  return new Intl.DateTimeFormat("pt-BR", { dateStyle: "medium", timeZone: "UTC" }).format(new Date(value));
}

export function TenantExportNotifications() {
  const [exports, setExports] = useState<ExportNotice[] | null>(null);
  const [error, setError] = useState("");
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [downloadError, setDownloadError] = useState("");
  const [disputePendingId, setDisputePendingId] = useState<string | null>(null);
  const [disputeMessage, setDisputeMessage] = useState("");

  useEffect(() => {
    let active = true;
    void fetch("/api/v1/tenant-exports/notifications", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: "{}",
      cache: "no-store",
    }).then(async (response) => {
      const result = await response.json() as { exports?: ExportNotice[]; error?: { message?: string } };
      if (!response.ok || !Array.isArray(result.exports)) throw new Error(result.error?.message ?? "Não foi possível consultar exports disponíveis.");
      if (active) setExports(result.exports);
    }).catch((reason: unknown) => {
      if (active) setError(reason instanceof Error ? reason.message : "Não foi possível consultar exports disponíveis.");
    });
    return () => { active = false; };
  }, []);

  async function download(exportItem: ExportNotice) {
    setPendingId(exportItem.exportId);
    setDownloadError("");
    try {
      const response = await fetch(`/api/v1/tenant-exports/${encodeURIComponent(exportItem.exportId)}/download`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: "{}",
        cache: "no-store",
      });
      if (!response.ok) {
        const result = await response.json() as { error?: { message?: string } };
        throw new Error(result.error?.message ?? "Não foi possível baixar este export.");
      }
      const blob = await response.blob();
      const objectUrl = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = objectUrl;
      anchor.download = `tenant-export-${exportItem.exportId}.json`;
      document.body.append(anchor);
      anchor.click();
      anchor.remove();
      URL.revokeObjectURL(objectUrl);
      setExports((current) => current?.map((item) => item.exportId === exportItem.exportId
        ? { ...item, firstDownloadedAt: item.firstDownloadedAt ?? new Date().toISOString() }
        : item) ?? current);
    } catch (reason) {
      setDownloadError(reason instanceof Error ? reason.message : "Não foi possível baixar este export.");
    } finally { setPendingId(null); }
  }

  async function fileDispute(exportItem: ExportNotice, event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setDisputePendingId(exportItem.exportId);
    setDisputeMessage("");
    const form = event.currentTarget;
    const values = new FormData(form);
    const reason = values.get("reason");
    const selected = values.getAll("datasets");
    if (typeof reason !== "string" || selected.length === 0 || !selected.every((value) => typeof value === "string")) {
      setDisputeMessage("Informe o motivo e ao menos um conjunto de dados.");
      setDisputePendingId(null);
      return;
    }
    try {
      const response = await fetch(`/api/v1/tenant-exports/${encodeURIComponent(exportItem.exportId)}/disputes`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ reason, datasets: selected, idempotencyKey: crypto.randomUUID() }),
        cache: "no-store",
      });
      const result = await response.json() as { error?: { message?: string }; dispute?: { disputeId?: string } };
      if (!response.ok || typeof result.dispute?.disputeId !== "string") {
        throw new Error(result.error?.message ?? "Não foi possível registrar a contestação.");
      }
      form.reset();
      setDisputeMessage("Contestação registrada. A equipe responsável analisará o caso antes do purge.");
    } catch (reason) {
      setDisputeMessage(reason instanceof Error ? reason.message : "Não foi possível registrar a contestação.");
    } finally { setDisputePendingId(null); }
  }

  if (exports === null && !error) return null;
  if (exports?.length === 0 && !error) return null;
  return <section className="tenant-export-notifications" aria-labelledby="tenant-export-notifications-title" aria-live="polite">
    <h2 id="tenant-export-notifications-title">Exports disponíveis</h2>
    <p>Arquivos de encerramento disponíveis para download seguro.</p>
    {error && <Feedback tone="error">{error}</Feedback>}
    {downloadError && <Feedback tone="error">{downloadError}</Feedback>}
    {exports?.map((item) => <article className="tenant-export-notice" key={item.exportId}>
      <div>
        <h3>{item.tenantName}</h3>
        <p>Disponível em {formatDate(item.availableAt)} · remoção prevista após {formatDate(item.purgeAfter)}.</p>
        <p>{Math.ceil(item.artifactBytes / 1024)} KB · {item.firstDownloadedAt ? "Já baixado" : "Ainda não baixado"}</p>
      </div>
      <Button type="button" disabled={pendingId !== null} onClick={() => void download(item)}>
        {pendingId === item.exportId ? "Validando arquivo…" : "Baixar export"}
      </Button>
      <details className="tenant-export-dispute">
        <summary>Contestar dados da exportação</summary>
        <form onSubmit={(event) => void fileDispute(item, event)}>
          <label>Motivo<textarea name="reason" required minLength={1} maxLength={1000} /></label>
          <fieldset>
            <legend>Quais conjuntos estão incompletos?</legend>
            {exportDatasets.map(([key, label]) => <label key={key}>
              <input type="checkbox" name="datasets" value={key} /> {label}
            </label>)}
          </fieldset>
          <Button type="submit" disabled={disputePendingId !== null}>
            {disputePendingId === item.exportId ? "Enviando…" : "Enviar contestação"}
          </Button>
        </form>
        {disputeMessage && <Feedback tone={disputeMessage.startsWith("Contestação") ? "success" : "error"}>{disputeMessage}</Feedback>}
      </details>
    </article>)}
  </section>;
}
