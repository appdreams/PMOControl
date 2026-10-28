"use client";

import { useEffect, useState } from "react";
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

function formatDate(value: string): string {
  return new Intl.DateTimeFormat("pt-BR", { dateStyle: "medium", timeZone: "UTC" }).format(new Date(value));
}

export function TenantExportNotifications() {
  const [exports, setExports] = useState<ExportNotice[] | null>(null);
  const [error, setError] = useState("");
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [downloadError, setDownloadError] = useState("");

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
    </article>)}
  </section>;
}
