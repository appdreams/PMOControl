import { mutateTenantResource } from "@/server/infrastructure/resource-mutation-route";

type Context = RouteContext<"/api/v1/tenants/[tenantId]/portfolios/[portfolioId]/archive">;
export async function POST(request: Request, context: Context) {
  const { tenantId, portfolioId } = await context.params;
  return mutateTenantResource(request, tenantId, portfolioId, "portfolio", "archive");
}
