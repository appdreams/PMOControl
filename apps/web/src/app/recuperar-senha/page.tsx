import Link from "next/link";
import { Suspense } from "react";
import { RecoveryForm } from "../RecoveryForm";
import { getSupabasePublicConfig } from "@/server/infrastructure/supabase/config";

async function RecoveryContent({ searchParams }: PageProps<"/recuperar-senha">) {
  const params = await searchParams;
  return <main className="auth-standalone">
    <Link href="/" className="brand" aria-label="PMO Control, página inicial">
      <span className="brand-symbol" aria-hidden="true"><i /><i /><i /></span>
      <span className="brand-wordmark"><strong>PMO</strong><small>CONTROL</small></span>
    </Link>
    <RecoveryForm configured={Boolean(getSupabasePublicConfig())} invalidLink={params.link === "invalid"} />
  </main>;
}

export default function RecoverPasswordPage(props: PageProps<"/recuperar-senha">) {
  return <Suspense fallback={<main className="auth-standalone" aria-busy="true"><p role="status">Carregando recuperação de senha…</p></main>}>
    <RecoveryContent {...props} />
  </Suspense>;
}
