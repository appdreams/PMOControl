import Link from "next/link";
import { Suspense } from "react";
import { redirect } from "next/navigation";
import { AcceptInvitation } from "./AcceptInvitation";
import { LogoutButton } from "../../LogoutButton";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { getSupabasePublicConfig } from "@/server/infrastructure/supabase/config";

async function AcceptInvitationContent({ searchParams }: { searchParams: PageProps<"/convite/aceitar">["searchParams"] }) {
  if (!getSupabasePublicConfig()) redirect("/");
  const params = await searchParams;
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.auth.getClaims();
  const authenticated = typeof data?.claims?.sub === "string";

  return <main className="workspace-screen">
    <header className="workspace-header">
      <Link href="/" className="brand" aria-label="PMO Control">
        <span className="brand-symbol" aria-hidden="true"><i /><i /><i /></span>
        <span className="brand-wordmark"><strong>PMO</strong><small>CONTROL</small></span>
      </Link>
      {authenticated && <LogoutButton />}
    </header>
    <section className="workspace-card" aria-labelledby="invitation-title">
      <p className="workspace-eyebrow">Convite de organização</p>
      <h1 id="invitation-title">Aceitar convite</h1>
      <AcceptInvitation authenticated={authenticated} alreadyAccepted={params.accepted === "1"} />
    </section>
  </main>;
}

export default function AcceptInvitationPage(props: PageProps<"/convite/aceitar">) {
  return <Suspense fallback={<main className="workspace-screen" aria-busy="true"><p role="status">Validando convite…</p></main>}>
    <AcceptInvitationContent searchParams={props.searchParams} />
  </Suspense>;
}
