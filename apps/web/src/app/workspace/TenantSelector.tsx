"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";
import { SelectField } from "@/components/ui/SelectField";

type TenantOption = Readonly<{ id: string; name: string }>;

export function TenantSelector({ tenants }: { tenants: readonly TenantOption[] }) {
  const router = useRouter();
  const [selectedTenantId, setSelectedTenantId] = useState(tenants[0]?.id ?? "");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");

  async function selectTenant() {
    setPending(true);
    setError("");
    try {
      const response = await fetch("/api/v1/session/tenant", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ tenantId: selectedTenantId }),
      });
      if (!response.ok) throw new Error("selection_failed");
      router.replace(`/workspace?tenantId=${encodeURIComponent(selectedTenantId)}`);
      router.refresh();
    } catch {
      setError("Não foi possível selecionar essa organização. Atualize a lista e tente novamente.");
      setPending(false);
    }
  }

  return <div className="tenant-selection">
    <SelectField id="tenant-choice" label="Organização" value={selectedTenantId} onChange={(event) => setSelectedTenantId(event.target.value)} disabled={pending}>
      {tenants.map((tenant) => <option key={tenant.id} value={tenant.id}>{tenant.name}</option>)}
    </SelectField>
    <Button type="button" disabled={pending || !selectedTenantId} onClick={selectTenant}>{pending ? "Abrindo…" : "Continuar"}</Button>
    {error && <Feedback tone="error">{error}</Feedback>}
  </div>;
}
