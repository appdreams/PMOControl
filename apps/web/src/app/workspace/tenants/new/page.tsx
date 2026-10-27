import Link from "next/link";
import { Suspense } from "react";
import { redirect } from "next/navigation";
import { LogoutButton } from "../../../LogoutButton";
import { NewTenantForm } from "./NewTenantForm";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { getSupabasePublicConfig } from "@/server/infrastructure/supabase/config";

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

async function NewTenantContent({ searchParams }: { searchParams: PageProps<"/workspace/tenants/new">["searchParams"] }) {
  if (!getSupabasePublicConfig()) redirect("/");
  const params = await searchParams;
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.auth.getClaims();
  if (error || typeof data?.claims?.sub !== "string") redirect("/");

  const requestedTenantId = typeof params.tenantId === "string" ? params.tenantId : null;
  let initialTenant: Parameters<typeof NewTenantForm>[0]["initialTenant"];
  let resumeFailed = false;
  if (params.tenantId !== undefined) {
    if (!requestedTenantId || !UUID_PATTERN.test(requestedTenantId)) {
      resumeFailed = true;
    } else {
      const { data: setup, error: setupError } = await supabase.rpc("get_first_tenant_admin_context", {
        p_tenant_id: requestedTenantId,
      });
      if (!setupError && typeof setup === "object" && setup !== null && !Array.isArray(setup) &&
          setup.tenantId === requestedTenantId && typeof setup.name === "string" && typeof setup.slug === "string" &&
          typeof setup.firstAdminActivated === "boolean" && typeof setup.pendingInvitation === "boolean") {
        initialTenant = {
          id: setup.tenantId,
          name: setup.name,
          slug: setup.slug,
          firstAdminActivated: setup.firstAdminActivated,
          pendingInvitation: setup.pendingInvitation,
        };
      } else {
        resumeFailed = true;
      }
    }
  }

  return <main className="workspace-screen">
    <header className="workspace-header">
      <Link href="/workspace" className="brand" aria-label="Voltar ao PMO Control">
        <span className="brand-symbol" aria-hidden="true"><i /><i /><i /></span>
        <span className="brand-wordmark"><strong>PMO</strong><small>CONTROL</small></span>
      </Link>
      <LogoutButton />
    </header>
    <section className="workspace-card" aria-labelledby="new-tenant-title">
      <p className="workspace-eyebrow">Área da plataforma</p>
      <h1 id="new-tenant-title">Provisionar organização</h1>
      <p>Tenant, presets de RBAC e auditoria serão criados em uma transação.</p>
      {resumeFailed ? <div className="auth-status auth-status-error" role="alert">
        Não foi possível retomar esta etapa. O Tenant pode não existir, já ter outro responsável ou sua sessão não ter autorização para convidar o primeiro administrador.
        <p><Link className="workspace-link" href="/workspace/tenants/new">Voltar ao provisionamento</Link></p>
      </div> : <NewTenantForm initialTenant={initialTenant} />}
    </section>
  </main>;
}

export default function NewTenantPage(props: PageProps<"/workspace/tenants/new">) {
  return <Suspense fallback={<main className="workspace-screen" aria-busy="true"><p role="status">Validando acesso…</p></main>}>
    <NewTenantContent searchParams={props.searchParams} />
  </Suspense>;
}
