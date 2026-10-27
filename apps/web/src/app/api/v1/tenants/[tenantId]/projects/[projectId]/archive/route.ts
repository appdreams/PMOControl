import { mutateTenantResource } from "@/server/infrastructure/resource-mutation-route";

type Context = RouteContext<"/api/v1/tenants/[tenantId]/projects/[projectId]/archive">;
export async function POST(request: Request, context: Context) {
  const { tenantId, projectId } = await context.params;
  return mutateTenantResource(request, tenantId, projectId, "project", "archive");
}
