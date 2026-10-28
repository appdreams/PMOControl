import Link from "next/link";
import { Suspense } from "react";
import { redirect } from "next/navigation";
import { LogoutButton } from "../LogoutButton";
import { TenantSelector } from "./TenantSelector";
import { TenantMembersPanel } from "./TenantMembersPanel";
import { TenantResourceManagement } from "./TenantResourceManagement";
import { MyProfileForm } from "./MyProfileForm";
import { TenantExportNotifications } from "./TenantExportNotifications";
import { resolveSupabaseRequestContext } from "@/server/infrastructure/supabase/request-context";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { getSupabasePublicConfig } from "@/server/infrastructure/supabase/config";

async function WorkspaceContent({ searchParams }: PageProps<"/workspace">) {
  if (!getSupabasePublicConfig()) redirect("/");
  const params = await searchParams;
  const tenantSelector = typeof params.tenantId === "string" ? params.tenantId : undefined;
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.auth.getClaims();
  if (error || typeof data?.claims?.sub !== "string") redirect("/");

  const resolution = await resolveSupabaseRequestContext(tenantSelector);
  return <main className="workspace-screen">
    <header className="workspace-header">
      <Link href="/" className="brand" aria-label="PMO Control">
        <span className="brand-symbol" aria-hidden="true"><i /><i /><i /></span>
        <span className="brand-wordmark"><strong>PMO</strong><small>CONTROL</small></span>
      </Link>
      <LogoutButton />
    </header>

    <section className="workspace-card" aria-labelledby="workspace-title">
      <TenantExportNotifications />
      {resolution.ok ? <>
        <p className="workspace-eyebrow">Sessão autenticada</p>
        <h1 id="workspace-title">Bem-vindo ao PMO Control</h1>
        <p>Organização selecionada: <strong>{resolution.context.tenantName}</strong>.</p>
        <p className="workspace-note">Portfólios e projetos aparecem conforme as permissões ativas da sua conta.</p>
        <nav className="workspace-nav" aria-label="Navegação do espaço de trabalho">
          <a href="#my-profile">Meu perfil</a>
          <a href="#tenant-members">Membros</a>
          <a href="#tenant-resources">Portfólios e projetos</a>
        </nav>
        <MyProfileForm />
        <TenantMembersPanel tenantId={resolution.context.tenantId} actorId={data.claims.sub} />
        <TenantResourceManagement tenantId={resolution.context.tenantId} />
        <Link className="workspace-link" href="/workspace/tenants/new">Provisionar outro Tenant <span>(requer acesso de plataforma)</span></Link>
      </> : resolution.reason === "tenant_selection_required" ? <>
        <p className="workspace-eyebrow">Sessão autenticada</p>
        <h1 id="workspace-title">Escolha uma organização</h1>
        <p>Seu acesso será conferido novamente ao abrir a organização.</p>
        <MyProfileForm />
        <TenantSelector tenants={resolution.availableTenants?.map(({ tenantId, name }) => ({ id: tenantId, name })) ?? []} />
      </> : resolution.reason === "context_unavailable" ? <>
        <p className="workspace-eyebrow">Sessão autenticada</p>
        <h1 id="workspace-title">Contexto temporariamente indisponível</h1>
        <p>Não foi possível carregar suas organizações agora. Tente novamente.</p>
        <MyProfileForm />
      </> : resolution.reason === "unauthenticated" ? redirect("/") : <>
        <p className="workspace-eyebrow">Sessão autenticada</p>
        <h1 id="workspace-title">Sua conta ainda não pertence a uma organização</h1>
        <p>Dados de Tenant exigem uma membership ativa. Operadores de plataforma podem provisionar uma organização.</p>
        <MyProfileForm />
        <Link className="workspace-link" href="/workspace/tenants/new">Abrir provisionamento de Tenant</Link>
      </>}
    </section>
  </main>;
}

export default function WorkspacePage(props: PageProps<"/workspace">) {
  return <Suspense fallback={<main className="workspace-screen" aria-busy="true"><p role="status">Carregando seu espaço de trabalho…</p></main>}>
    <WorkspaceContent {...props} />
  </Suspense>;
}
