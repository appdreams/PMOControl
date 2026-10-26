import Link from "next/link";

export default function Home() {
  return (
    <main className="shell">
      <header className="topbar">
        <Link className="brand" href="/" aria-label="PMO Control, página inicial">
          <span className="brand-mark" aria-hidden="true">P</span>
          <span>PMO Control</span>
        </Link>
        <span className="environment-tag">Ambiente de desenvolvimento</span>
      </header>

      <section className="welcome" aria-labelledby="welcome-title">
        <p className="eyebrow">Fundação do produto</p>
        <h1 id="welcome-title">Governança clara para projetos que importam.</h1>
        <p className="intro">
          A aplicação está inicializada. Os módulos de negócio serão habilitados
          conforme as especificações e os controles de segurança forem implementados.
        </p>
        <div className="status-card" role="status">
          <span className="status-indicator" aria-hidden="true" />
          <div>
            <strong>Base técnica criada</strong>
            <p>Next.js, TypeScript, estilos e estrutura inicial configurados.</p>
          </div>
        </div>
      </section>

      <footer className="footer">PMO Control · MVP em construção</footer>
    </main>
  );
}
