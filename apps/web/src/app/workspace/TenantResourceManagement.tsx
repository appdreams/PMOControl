"use client";

import { useCallback, useEffect, useState, type FormEvent } from "react";
import { Button } from "@/components/ui/Button";
import { Feedback } from "@/components/ui/Feedback";
import { SelectField } from "@/components/ui/SelectField";
import { TextAreaField } from "@/components/ui/TextAreaField";
import { TextField } from "@/components/ui/TextField";

type Portfolio = {
  id: string; tenantId: string; name: string; code: string | null; category: string;
  ownerId: string; sponsorId: string | null; status: "active"; startDate: string | null;
  targetEndDate: string | null; version: string; canEdit: boolean; canArchive: boolean; canAssociate: boolean;
};
type Project = {
  id: string; tenantId: string; portfolioId: string; name: string; code: string | null;
  status: string; priority: string; scopeSummary: string | null; projectManagerId: string | null;
  sponsorId: string | null; startDate: string | null; targetEndDate: string | null; version: string;
  associationId: string; associationVersion: string; canEdit: boolean; canArchive: boolean; canRemoveAssociation: boolean; canAssignManager: boolean;
};
type ProjectTarget = { id: string; name: string; code: string | null };
type ManagerCandidate = { userId: string; displayName: string };
type ManagerTargets = { manager: ManagerCandidate | null; candidates: ManagerCandidate[] };
type ProjectList = { projects: Project[]; canCreate: boolean; associableProjects?: ProjectTarget[] };

function parseMessage(data: { error?: { message?: string } }, fallback: string) {
  return data.error?.message ?? fallback;
}

export function TenantResourceManagement({ tenantId }: { tenantId: string }) {
  const [portfolios, setPortfolios] = useState<Portfolio[] | null>(null);
  const [canCreatePortfolio, setCanCreatePortfolio] = useState(false);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [projects, setProjects] = useState<Record<string, ProjectList>>({});
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);
  const [pending, setPending] = useState(false);
  const [portfolioName, setPortfolioName] = useState("");
  const [portfolioCode, setPortfolioCode] = useState("");
  const [portfolioCategory, setPortfolioCategory] = useState("Estratégico");
  const [portfolioReason, setPortfolioReason] = useState("Criação inicial do portfólio");
  const [portfolioKey, setPortfolioKey] = useState("");
  const [projectName, setProjectName] = useState("");
  const [projectCode, setProjectCode] = useState("");
  const [projectPriority, setProjectPriority] = useState("medium");
  const [projectSummary, setProjectSummary] = useState("");
  const [projectReason, setProjectReason] = useState("Criação do projeto");
  const [projectKey, setProjectKey] = useState("");
  const [editingPortfolioId, setEditingPortfolioId] = useState<string | null>(null);
  const [portfolioEdit, setPortfolioEdit] = useState({ name: "", code: "", category: "", reason: "" });
  const [editingProjectId, setEditingProjectId] = useState<string | null>(null);
  const [projectEdit, setProjectEdit] = useState({ name: "", code: "", priority: "medium", scopeSummary: "", reason: "" });
  const [archivePortfolioId, setArchivePortfolioId] = useState<string | null>(null);
  const [archiveProjectId, setArchiveProjectId] = useState<string | null>(null);
  const [archiveReason, setArchiveReason] = useState("");
  const [associationProjectId, setAssociationProjectId] = useState("");
  const [associationReason, setAssociationReason] = useState("Vínculo ao portfólio");
  const [removeAssociationId, setRemoveAssociationId] = useState<string | null>(null);
  const [managerCandidates, setManagerCandidates] = useState<Record<string, ManagerTargets>>({});
  const [managerProjectId, setManagerProjectId] = useState<string | null>(null);
  const [managerSubjectId, setManagerSubjectId] = useState("");
  const [managerReason, setManagerReason] = useState("Atribuição de gerente do projeto");

  const loadPortfolios = useCallback(async () => {
    const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/portfolios`, { cache: "no-store" });
    const data = await response.json() as { portfolios?: Portfolio[]; canCreate?: boolean; error?: { message?: string } };
    if (!response.ok || !Array.isArray(data.portfolios) || typeof data.canCreate !== "boolean") {
      throw new Error(parseMessage(data, "Não foi possível carregar os Portfolios."));
    }
    setPortfolios(data.portfolios);
    setCanCreatePortfolio(data.canCreate);
  }, [tenantId]);

  useEffect(() => {
    let active = true;
    void fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/portfolios`, { cache: "no-store" })
      .then(async (response) => {
        const data = await response.json() as { portfolios?: Portfolio[]; canCreate?: boolean; error?: { message?: string } };
        if (!response.ok || !Array.isArray(data.portfolios) || typeof data.canCreate !== "boolean") {
          throw new Error(parseMessage(data, "Não foi possível carregar os Portfolios."));
        }
        if (active) { setPortfolios(data.portfolios); setCanCreatePortfolio(data.canCreate); }
      }).catch((error: unknown) => {
        if (active) { setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível carregar os Portfolios."); }
      });
    return () => { active = false; };
  }, [tenantId]);

  async function loadProjects(portfolioId: string) {
    const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/projects?portfolioId=${encodeURIComponent(portfolioId)}`, { cache: "no-store" });
    const data = await response.json() as ProjectList & { error?: { message?: string } };
    if (!response.ok || !Array.isArray(data.projects) || typeof data.canCreate !== "boolean") {
      throw new Error(parseMessage(data, "Não foi possível carregar os Projetos."));
    }
    setProjects((current) => ({ ...current, [portfolioId]: { projects: data.projects, canCreate: data.canCreate } }));
  }

  async function loadAssociableProjects(portfolioId: string) {
    const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/portfolios/${encodeURIComponent(portfolioId)}/projects`, { cache: "no-store" });
    const data = await response.json() as { projects?: ProjectTarget[]; error?: { message?: string } };
    if (!response.ok || !Array.isArray(data.projects)) throw new Error(parseMessage(data, "Não foi possível carregar os Projetos disponíveis."));
    setProjects((current) => ({ ...current, [portfolioId]: { ...current[portfolioId], projects: current[portfolioId]?.projects ?? [], canCreate: current[portfolioId]?.canCreate ?? false, associableProjects: data.projects } }));
  }

  async function mutateAssociation(portfolioId: string, project: Project | null, action: "associate" | "remove") {
    setPending(true); setIsError(false); setMessage(action === "associate" ? "Associando Projeto e registrando auditoria…" : "Removendo vínculo e registrando auditoria…");
    const base = `/api/v1/tenants/${encodeURIComponent(tenantId)}/portfolios/${encodeURIComponent(portfolioId)}/projects`;
    try {
      const response = action === "associate"
        ? await fetch(base, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ projectId: associationProjectId, reason: associationReason, idempotencyKey: crypto.randomUUID() }) })
        : await fetch(`${base}/${encodeURIComponent(removeAssociationId ?? "")}`, { method: "DELETE", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ expectedVersion: project?.associationVersion, reason: associationReason, idempotencyKey: crypto.randomUUID() }) });
      const data = await response.json() as { error?: { message?: string } };
      if (!response.ok) throw new Error(parseMessage(data, "Não foi possível alterar o vínculo."));
      setAssociationProjectId(""); setRemoveAssociationId(null); setAssociationReason(action === "associate" ? "Vínculo ao portfólio" : "Remoção do vínculo");
      await loadProjects(portfolioId);
      setMessage(action === "associate" ? "Projeto associado ao portfólio com auditoria registrada." : "Vínculo removido. O Projeto e seu histórico foram preservados.");
    } catch (error) { setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível alterar o vínculo."); }
    finally { setPending(false); }
  }

  async function loadManagerCandidates(project: Project) {
    const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/projects/${encodeURIComponent(project.id)}/manager`, { cache: "no-store" });
    const data = await response.json() as ManagerTargets & { error?: { message?: string } };
    if (!response.ok || !Array.isArray(data.candidates) || !(data.manager === null || typeof data.manager?.userId === "string")) throw new Error(parseMessage(data, "Não foi possível carregar os membros elegíveis."));
    const candidates = data.candidates.filter((candidate) => candidate.userId !== data.manager?.userId);
    setManagerCandidates((current) => ({ ...current, [project.id]: { ...data, candidates } }));
    setManagerSubjectId(""); setManagerReason("Atribuição de gerente do projeto"); setManagerProjectId(project.id);
  }

  async function assignProjectManager(project: Project, portfolioId: string) {
    setPending(true); setIsError(false); setMessage("Atribuindo gerente e registrando auditoria…");
    try {
      const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/projects/${encodeURIComponent(project.id)}/manager`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ subjectId: managerSubjectId, expectedVersion: project.version, reason: managerReason, idempotencyKey: crypto.randomUUID() }),
      });
      const data = await response.json() as { error?: { code?: string; message?: string } };
      if (!response.ok) {
        if (response.status === 409) {
          await loadProjects(portfolioId);
          await loadManagerCandidates(project);
          setMessage("O Projeto foi alterado durante a operação. Atualizei o gerente e os membros disponíveis; revise os dados antes de tentar novamente.");
          return;
        }
        throw new Error(parseMessage(data, "Não foi possível atribuir o gerente."));
      }
      setManagerProjectId(null); setManagerSubjectId(""); await loadProjects(portfolioId);
      setMessage("Gerente atualizado. O acesso do gerente anterior foi encerrado e a alteração foi auditada.");
    } catch (error) { setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível atribuir o gerente."); }
    finally { setPending(false); }
  }

  async function createPortfolio(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPending(true); setIsError(false); setMessage("Criando Portfolio e registrando acesso inicial…");
    const requestKey = portfolioKey || crypto.randomUUID();
    setPortfolioKey(requestKey);
    try {
      const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/portfolios`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name: portfolioName, code: portfolioCode, category: portfolioCategory,
          reason: portfolioReason, idempotencyKey: requestKey }),
      });
      const data = await response.json() as { portfolio?: Portfolio; error?: { message?: string } };
      if (!response.ok || !data.portfolio) throw new Error(parseMessage(data, "Não foi possível criar o Portfolio."));
      setPortfolioName(""); setPortfolioCode(""); setPortfolioKey("");
      await loadPortfolios();
      setMessage("Portfolio criado. Seu acesso de administrador foi registrado na auditoria.");
    } catch (error) {
      setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível criar o Portfolio.");
    } finally { setPending(false); }
  }

  async function createProject(event: FormEvent<HTMLFormElement>, portfolioId: string) {
    event.preventDefault();
    setPending(true); setIsError(false); setMessage("Criando Projeto e registrando acesso inicial…");
    const requestKey = projectKey || crypto.randomUUID();
    setProjectKey(requestKey);
    try {
      const response = await fetch(`/api/v1/tenants/${encodeURIComponent(tenantId)}/projects`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ portfolioId, name: projectName, code: projectCode, priority: projectPriority,
          scopeSummary: projectSummary, reason: projectReason, idempotencyKey: requestKey }),
      });
      const data = await response.json() as { project?: Project; error?: { message?: string } };
      if (!response.ok || !data.project) throw new Error(parseMessage(data, "Não foi possível criar o Projeto."));
      setProjectName(""); setProjectCode(""); setProjectSummary(""); setProjectKey("");
      await loadProjects(portfolioId);
      setMessage("Projeto criado e atribuído ao gerente inicial, com auditoria registrada.");
    } catch (error) {
      setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível criar o Projeto.");
    } finally { setPending(false); }
  }

  async function mutateResource(event: FormEvent<HTMLFormElement>, resource: "portfolio" | "project", item: Portfolio | Project, action: "update" | "archive", portfolioId?: string) {
    event.preventDefault();
    setPending(true); setIsError(false);
    const isArchive = action === "archive";
    setMessage(isArchive ? "Arquivando e registrando auditoria…" : "Salvando alterações e registrando auditoria…");
    const patch = resource === "portfolio" ? portfolioEdit : projectEdit;
    const body = {
      ...(isArchive ? {} : resource === "portfolio"
        ? { name: portfolioEdit.name, code: portfolioEdit.code || null, category: portfolioEdit.category }
        : { name: projectEdit.name, code: projectEdit.code || null, priority: projectEdit.priority, scopeSummary: projectEdit.scopeSummary || null }),
      expectedVersion: item.version,
      reason: isArchive ? archiveReason : patch.reason,
      idempotencyKey: crypto.randomUUID(),
    };
    const base = `/api/v1/tenants/${encodeURIComponent(tenantId)}/${resource === "portfolio" ? "portfolios" : "projects"}/${encodeURIComponent(item.id)}`;
    try {
      const response = await fetch(isArchive ? `${base}/archive` : base, {
        method: isArchive ? "POST" : "PATCH", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body),
      });
      const data = await response.json() as { error?: { message?: string } };
      if (!response.ok) throw new Error(parseMessage(data, "Não foi possível salvar as alterações."));
      if (resource === "portfolio") {
        setEditingPortfolioId(null); setArchivePortfolioId(null); setArchiveReason("");
        await loadPortfolios();
      } else if (portfolioId) {
        setEditingProjectId(null); setArchiveProjectId(null); setArchiveReason("");
        await loadProjects(portfolioId);
      }
      setMessage(isArchive ? "Recurso arquivado e auditado." : "Alterações salvas e auditadas.");
    } catch (error) {
      setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível salvar as alterações.");
    } finally { setPending(false); }
  }

  return <section id="tenant-resources" className="tenant-resources" aria-labelledby="tenant-resources-title">
    <h2 id="tenant-resources-title">Portfólios e projetos</h2>
    <p>Os recursos e suas permissões são limitados à organização selecionada.</p>
    {message && <Feedback tone={isError ? "error" : /criado|associado|removido|atualizado|salvas|auditado/i.test(message) ? "success" : "info"}>{message}</Feedback>}
    {portfolios === null ? <p role="status">Carregando Portfólios…</p> : portfolios.length === 0 ?
      <p>Nenhum Portfólio está disponível para sua conta.</p> : <ul className="tenant-members-list">
      {portfolios.map((portfolio) => <li key={portfolio.id}>
        <div className="tenant-member-row">
          <div><strong>{portfolio.name}</strong><span>{portfolio.code ? `${portfolio.code} · ` : ""}{portfolio.category}</span></div>
          {portfolio.canEdit && <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => {
            setEditingPortfolioId(editingPortfolioId === portfolio.id ? null : portfolio.id);
            setPortfolioEdit({ name: portfolio.name, code: portfolio.code ?? "", category: portfolio.category, reason: "Atualização do portfólio" });
          }}>{editingPortfolioId === portfolio.id ? "Cancelar edição" : "Editar"}</button>}
          {portfolio.canArchive && <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => { setArchivePortfolioId(archivePortfolioId === portfolio.id ? null : portfolio.id); setArchiveReason(""); }}>Arquivar</button>}
          <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => {
            const next = expandedId === portfolio.id ? null : portfolio.id;
            setExpandedId(next);
            if (next && !projects[portfolio.id]) void loadProjects(portfolio.id).catch((error: unknown) => {
              setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível carregar os Projetos.");
            });
          }}>{expandedId === portfolio.id ? "Fechar projetos" : "Abrir projetos"}</button>
        </div>
        {editingPortfolioId === portfolio.id && <form className="tenant-provision-form tenant-project-form" onSubmit={(event) => void mutateResource(event, "portfolio", portfolio, "update")}>
          <h3>Editar portfólio</h3>
          <TextField id={`portfolio-edit-name-${portfolio.id}`} label="Nome" required maxLength={160} value={portfolioEdit.name} onChange={(event) => setPortfolioEdit({ ...portfolioEdit, name: event.target.value })} disabled={pending} />
          <TextField id={`portfolio-edit-code-${portfolio.id}`} label="Código" maxLength={40} value={portfolioEdit.code} onChange={(event) => setPortfolioEdit({ ...portfolioEdit, code: event.target.value })} disabled={pending} />
          <TextField id={`portfolio-edit-category-${portfolio.id}`} label="Categoria" required maxLength={80} value={portfolioEdit.category} onChange={(event) => setPortfolioEdit({ ...portfolioEdit, category: event.target.value })} disabled={pending} />
          <TextAreaField id={`portfolio-edit-reason-${portfolio.id}`} label="Motivo" required maxLength={1000} rows={2} value={portfolioEdit.reason} onChange={(event) => setPortfolioEdit({ ...portfolioEdit, reason: event.target.value })} disabled={pending} />
          <Button type="submit" disabled={pending}>{pending ? "Salvando…" : "Salvar alterações"}</Button>
        </form>}
        {archivePortfolioId === portfolio.id && <form className="tenant-provision-form tenant-project-form" onSubmit={(event) => void mutateResource(event, "portfolio", portfolio, "archive")}>
          <h3>Arquivar portfólio</h3><p>Os projetos ainda ativos precisam ser arquivados primeiro.</p>
          <TextAreaField id={`portfolio-archive-reason-${portfolio.id}`} label="Motivo" required minLength={1} maxLength={1000} rows={2} value={archiveReason} onChange={(event) => setArchiveReason(event.target.value)} disabled={pending} />
          <Button type="submit" disabled={pending || !archiveReason.trim()}>{pending ? "Arquivando…" : "Confirmar arquivamento"}</Button>
        </form>}
        {expandedId === portfolio.id && <div className="tenant-projects">
          {!projects[portfolio.id] ? <p role="status">Carregando projetos…</p> : <>
            {projects[portfolio.id].projects.length === 0 ? <p>Nenhum Projeto neste Portfólio.</p> :
              <ul className="tenant-project-list">{projects[portfolio.id].projects.map((project) => <li key={project.id}>
                <div><strong>{project.name}</strong><span>{project.code ? `${project.code} · ` : ""}{project.status} · {project.priority}</span></div>
                {project.canEdit && <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => {
                  setEditingProjectId(editingProjectId === project.id ? null : project.id);
                  setProjectEdit({ name: project.name, code: project.code ?? "", priority: project.priority, scopeSummary: project.scopeSummary ?? "", reason: "Atualização do projeto" });
                }}>{editingProjectId === project.id ? "Cancelar edição" : "Editar"}</button>}
                {project.canArchive && <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => { setArchiveProjectId(archiveProjectId === project.id ? null : project.id); setArchiveReason(""); }}>Arquivar</button>}
                {project.canAssignManager && <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => {
                  if (managerProjectId === project.id) { setManagerProjectId(null); return; }
                  void loadManagerCandidates(project).catch((error: unknown) => { setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível carregar os membros."); });
                }}>{managerProjectId === project.id ? "Fechar atribuição" : "Alterar gerente"}</button>}
                {project.canRemoveAssociation && <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => { setRemoveAssociationId(removeAssociationId === project.associationId ? null : project.associationId); setAssociationReason("Remoção do vínculo"); }}>Remover do portfólio</button>}
                {managerProjectId === project.id && managerCandidates[project.id] && <form className="tenant-provision-form tenant-project-form" onSubmit={(event) => { event.preventDefault(); void assignProjectManager(project, portfolio.id); }}>
                  <h3>Alterar gerente do projeto</h3><p>Gerente atual: {managerCandidates[project.id].manager?.displayName ?? "Não atribuído"}. A troca também atualiza o papel de acesso ao Projeto.</p>
                  {managerCandidates[project.id].candidates.length === 0 ? <p role="status">Não há outro membro ativo disponível nesta organização.</p> : <>
                    <SelectField id={`project-manager-${project.id}`} label="Novo gerente" required value={managerSubjectId} onChange={(event) => setManagerSubjectId(event.target.value)} disabled={pending}><option value="">Selecione um membro</option>{managerCandidates[project.id].candidates.map((candidate) => <option key={candidate.userId} value={candidate.userId}>{candidate.displayName}</option>)}</SelectField>
                    <TextAreaField id={`project-manager-reason-${project.id}`} label="Motivo" required maxLength={1000} rows={2} value={managerReason} onChange={(event) => setManagerReason(event.target.value)} disabled={pending} />
                    <Button type="submit" disabled={pending || !managerSubjectId || !managerReason.trim()}>{pending ? "Atribuindo…" : "Confirmar gerente"}</Button>
                  </>}
                </form>}
                {removeAssociationId === project.associationId && <form className="tenant-provision-form tenant-project-form" onSubmit={(event) => { event.preventDefault(); void mutateAssociation(portfolio.id, project, "remove"); }}>
                  <h3>Remover vínculo do portfólio</h3><p>O Projeto continuará ativo e acessível conforme suas permissões. O histórico do vínculo será preservado.</p>
                  <TextAreaField id={`association-remove-reason-${project.associationId}`} label="Motivo" required maxLength={1000} rows={2} value={associationReason} onChange={(event) => setAssociationReason(event.target.value)} disabled={pending} />
                  <Button type="submit" disabled={pending || !associationReason.trim()}>{pending ? "Removendo…" : "Confirmar remoção do vínculo"}</Button>
                </form>}
                {editingProjectId === project.id && <form className="tenant-provision-form tenant-project-form" onSubmit={(event) => void mutateResource(event, "project", project, "update", portfolio.id)}>
                  <h3>Editar projeto</h3>
                  <TextField id={`project-edit-name-${project.id}`} label="Nome" required maxLength={160} value={projectEdit.name} onChange={(event) => setProjectEdit({ ...projectEdit, name: event.target.value })} disabled={pending} />
                  <TextField id={`project-edit-code-${project.id}`} label="Código" maxLength={40} value={projectEdit.code} onChange={(event) => setProjectEdit({ ...projectEdit, code: event.target.value })} disabled={pending} />
                  <SelectField id={`project-edit-priority-${project.id}`} label="Prioridade" value={projectEdit.priority} onChange={(event) => setProjectEdit({ ...projectEdit, priority: event.target.value })} disabled={pending}><option value="low">Baixa</option><option value="medium">Média</option><option value="high">Alta</option><option value="critical">Crítica</option></SelectField>
                  <TextAreaField id={`project-edit-summary-${project.id}`} label="Escopo" maxLength={2000} rows={2} value={projectEdit.scopeSummary} onChange={(event) => setProjectEdit({ ...projectEdit, scopeSummary: event.target.value })} disabled={pending} />
                  <TextAreaField id={`project-edit-reason-${project.id}`} label="Motivo" required maxLength={1000} rows={2} value={projectEdit.reason} onChange={(event) => setProjectEdit({ ...projectEdit, reason: event.target.value })} disabled={pending} />
                  <Button type="submit" disabled={pending}>{pending ? "Salvando…" : "Salvar alterações"}</Button>
                </form>}
                {archiveProjectId === project.id && <form className="tenant-provision-form tenant-project-form" onSubmit={(event) => void mutateResource(event, "project", project, "archive", portfolio.id)}>
                  <h3>Arquivar projeto</h3><TextAreaField id={`project-archive-reason-${project.id}`} label="Motivo" required maxLength={1000} rows={2} value={archiveReason} onChange={(event) => setArchiveReason(event.target.value)} disabled={pending} />
                  <Button type="submit" disabled={pending || !archiveReason.trim()}>{pending ? "Arquivando…" : "Confirmar arquivamento"}</Button>
                </form>}
              </li>)}</ul>}
            {projects[portfolio.id].canCreate && <form className="tenant-provision-form tenant-project-form" onSubmit={(event) => void createProject(event, portfolio.id)}>
              <h3>Novo projeto</h3>
              <TextField id={`project-name-${portfolio.id}`} label="Nome do projeto" required maxLength={160} value={projectName} disabled={pending} onChange={(event) => setProjectName(event.target.value)} />
              <TextField id={`project-code-${portfolio.id}`} label="Código (opcional)" maxLength={40} value={projectCode} disabled={pending} onChange={(event) => setProjectCode(event.target.value)} />
              <SelectField id={`project-priority-${portfolio.id}`} label="Prioridade" value={projectPriority} disabled={pending} onChange={(event) => setProjectPriority(event.target.value)}>
                <option value="low">Baixa</option><option value="medium">Média</option><option value="high">Alta</option><option value="critical">Crítica</option>
              </SelectField>
              <TextAreaField id={`project-summary-${portfolio.id}`} label="Escopo (opcional)" rows={2} maxLength={2000} value={projectSummary} disabled={pending} onChange={(event) => setProjectSummary(event.target.value)} />
              <TextAreaField id={`project-reason-${portfolio.id}`} label="Motivo de criação" required rows={2} maxLength={1000} value={projectReason} disabled={pending} onChange={(event) => setProjectReason(event.target.value)} />
              <Button type="submit" disabled={pending || projectName.trim().length === 0 || projectReason.trim().length === 0}>{pending ? "Criando…" : "Criar projeto"}</Button>
            </form>}
            {portfolio.canAssociate && <section className="tenant-provision-form tenant-project-form" aria-label="Associar projeto existente">
              <h3>Associar projeto existente</h3><p>Associa o Projeto a este Portfólio sem criar outra cópia.</p>
              {!projects[portfolio.id]?.associableProjects ? <button className="tenant-member-manage" type="button" disabled={pending} onClick={() => void loadAssociableProjects(portfolio.id).catch((error: unknown) => { setIsError(true); setMessage(error instanceof Error ? error.message : "Não foi possível carregar os Projetos."); })}>Carregar Projetos disponíveis</button> : projects[portfolio.id]?.associableProjects?.length === 0 ? <p>Não há Projetos disponíveis para associação.</p> : <form onSubmit={(event) => { event.preventDefault(); void mutateAssociation(portfolio.id, null, "associate"); }}>
                <SelectField id={`associate-project-${portfolio.id}`} label="Projeto" required value={associationProjectId} onChange={(event) => setAssociationProjectId(event.target.value)} disabled={pending}><option value="">Selecione um Projeto</option>{(projects[portfolio.id]?.associableProjects ?? []).map((target) => <option key={target.id} value={target.id}>{target.name}{target.code ? ` · ${target.code}` : ""}</option>)}</SelectField>
                <TextAreaField id={`associate-reason-${portfolio.id}`} label="Motivo" required maxLength={1000} rows={2} value={associationReason} onChange={(event) => setAssociationReason(event.target.value)} disabled={pending} />
                <Button type="submit" disabled={pending || !associationProjectId || !associationReason.trim()}>{pending ? "Associando…" : "Associar Projeto"}</Button>
              </form>}
            </section>}
          </>}
        </div>}
      </li>)}
    </ul>}
    {canCreatePortfolio && <form className="tenant-provision-form tenant-resource-create-form" onSubmit={(event) => void createPortfolio(event)}>
      <h3>Novo portfólio</h3>
      <p>O criador será proprietário e receberá acesso de administrador somente neste Portfólio.</p>
      <TextField id="portfolio-name" label="Nome" required maxLength={160} value={portfolioName} disabled={pending} onChange={(event) => setPortfolioName(event.target.value)} />
      <TextField id="portfolio-code" label="Código (opcional)" maxLength={40} value={portfolioCode} disabled={pending} onChange={(event) => setPortfolioCode(event.target.value)} />
      <TextField id="portfolio-category" label="Categoria" required maxLength={80} value={portfolioCategory} disabled={pending} onChange={(event) => setPortfolioCategory(event.target.value)} />
      <TextAreaField id="portfolio-reason" label="Motivo de criação" required maxLength={1000} rows={2} value={portfolioReason} disabled={pending} onChange={(event) => setPortfolioReason(event.target.value)} />
      <Button type="submit" disabled={pending || portfolioName.trim().length === 0 || portfolioCategory.trim().length === 0 || portfolioReason.trim().length === 0}>{pending ? "Criando…" : "Criar portfólio"}</Button>
    </form>}
  </section>;
}
