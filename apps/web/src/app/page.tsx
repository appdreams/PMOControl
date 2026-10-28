import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import { redirect } from "next/navigation";
import { LoginForm } from "./LoginForm";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { getSupabasePublicConfig } from "@/server/infrastructure/supabase/config";
import { getAuthNotice } from "@/modules/identity/application/auth-notice";

const benefits = [
  { icon: "bars", title: "Visão completa", description: "De projetos e portfólio", tone: "blue" },
  { icon: "brain", title: "Inteligência IA", description: "Insights e recomendações", tone: "purple" },
  { icon: "shield", title: "Governança", description: "Mais controle e menos riscos", tone: "amber" },
  { icon: "rocket", title: "Resultados", description: "Projetos que geram valor real", tone: "green" },
];

function Icon({ name }: { name: string }) {
  const common = { fill: "none", stroke: "currentColor", strokeWidth: 2, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  const paths: Record<string, React.ReactNode> = {
    bars: <><path d="M4 20h16" /><path d="M6 16v-5h3v5M11 16V7h3v9M16 16V4h3v12" /></>,
    brain: <><path d="M12 5a3 3 0 0 0-5.8 1.1A3.5 3.5 0 0 0 5 12a3.5 3.5 0 0 0 2.2 5.9A3 3 0 0 0 12 19Zm0 0a3 3 0 0 1 5.8 1.1A3.5 3.5 0 0 1 19 12a3.5 3.5 0 0 1-2.2 5.9A3 3 0 0 1 12 19Z" /><path d="M12 5v14M8 10h2m4 4h2" /></>,
    shield: <path d="M12 3 20 6v5c0 5-3.4 8.3-8 10-4.6-1.7-8-5-8-10V6l8-3Z" />,
    rocket: <><path d="M5 15c-1.5 1-2 3-2 4 1 0 3-.5 4-2m2-4-3-3c3-5 7-7 13-7 0 6-2 10-7 13l-3-3Z" /><path d="M13 8h.01" /></>,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m4 7 8 6 8-6" /></>,
    lock: <><rect x="4" y="10" width="16" height="11" rx="2" /><path d="M8 10V7a4 4 0 0 1 8 0v3m-4 4v3" /></>,
    eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" /><path d="m4 20 16-16" /></>,
    arrow: <><path d="M5 12h14" /><path d="m13 6 6 6-6 6" /></>,
  };
  return <svg aria-hidden="true" viewBox="0 0 24 24" {...common}>{paths[name] ?? null}</svg>;
}

async function HomeContent({ searchParams }: { searchParams: PageProps<"/">["searchParams"] }) {
  const params = await searchParams;
  const authNotice = getAuthNotice({
    session: typeof params.session === "string" ? params.session : undefined,
    passwordUpdated: typeof params.passwordUpdated === "string" ? params.passwordUpdated : undefined,
  });
  const requestedNext = typeof params.next === "string" ? params.next : "";
  let redirectTo = "/workspace";
  try {
    const nextUrl = new URL(requestedNext, "http://pmo-control.local");
    const inviteToken = new URLSearchParams(nextUrl.hash.slice(1)).get("token") ?? "";
    if (nextUrl.origin === "http://pmo-control.local" && nextUrl.pathname === "/convite/aceitar" && !nextUrl.search && /^[A-Za-z0-9_-]{43}$/.test(inviteToken)) {
      redirectTo = `/convite/aceitar#token=${inviteToken}`;
    }
  } catch { /* Ignore unsafe or malformed post-login paths. */ }
  const configured = Boolean(getSupabasePublicConfig());
  let authenticated = false;
  if (configured) {
    try {
      const supabase = await createSupabaseServerClient();
      const { data } = await supabase.auth.getClaims();
      authenticated = typeof data?.claims?.sub === "string";
    } catch { /* Show the login form when no valid session is available. */ }
  }
  if (authenticated) redirect(redirectTo);

  return (
    <main className="login-screen">
      <Image className="login-background" src="/images/login-background-reference.png" alt="" fill priority sizes="100vw" />
      <div className="login-backdrop" aria-hidden="true" />
      <header className="login-header">
        <Link href="/" className="brand" aria-label="PMO Control, página inicial">
          <span className="brand-symbol" aria-hidden="true"><i /><i /><i /></span>
          <span className="brand-wordmark"><strong>PMO</strong><small>CONTROL</small></span>
        </Link>
      </header>

      <div className="login-content">
        <section className="login-intro" aria-labelledby="intro-title">
          <h1 id="intro-title"><span>PROJETOS MAIS CLAROS.</span><span className="cyan">DECISÕES MAIS INTELIGENTES.</span><span className="gold">RESULTADOS REAIS.</span></h1>
          <p className="intro-copy">O sistema completo para gestão de projetos e portfólio de TI,<br className="desktop-break" /> com governança, dados e Inteligência Artificial.</p>
          <ul className="benefit-list" aria-label="Benefícios do PMO Control">
            {benefits.map((benefit) => (
              <li className="benefit" key={benefit.title}>
                <span className={`benefit-icon ${benefit.tone}`}><Icon name={benefit.icon} /></span>
                <span className="benefit-text"><strong>{benefit.title}</strong><small>{benefit.description}</small></span>
              </li>
            ))}
          </ul>
          <div className="product-shot">
            <Image
              src="/images/login-system-layer-transparent.png"
              alt="Prévia do sistema PMO Control com visão executiva, indicadores, gráficos, riscos e marcos."
              fill
              priority
              sizes="(max-width: 1050px) 55vw, 60vw"
            />
          </div>
        </section>

        <section className="login-panel" aria-labelledby="login-title">
          <div className="panel-heading"><h2 id="login-title">Acesse o<br /><span>PMO Control</span></h2><p>Entre na sua conta para gerenciar seus projetos, portfólio, insights e muito mais.</p></div>
          <LoginForm configured={configured} initialNotice={authNotice} redirectTo={redirectTo} />
          <div className="invite-note"><span>Não tem uma conta?</span> <a href="mailto:suporte@pmocontrol.com.br">Solicitar acesso</a></div>
        </section>
      </div>
      <footer className="login-footer"><span>© 2026 PMO Control</span><span>Seus dados são acessíveis apenas à sua organização.</span></footer>
    </main>
  );
}

export default function Home({ searchParams }: PageProps<"/">) {
  return <Suspense fallback={<main className="login-screen" aria-busy="true"><p role="status">Carregando o PMO Control…</p></main>}>
    <HomeContent searchParams={searchParams} />
  </Suspense>;
}
