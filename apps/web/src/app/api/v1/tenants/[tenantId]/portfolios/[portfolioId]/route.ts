import { mutateTenantResource } from "@/server/infrastructure/resource-mutation-route";

type Context = RouteContext<"/api/v1/tenants/[tenantId]/portfolios/[portfolioId]">;
export async function PATCH(request: Request, context: Context) {
  const { tenantId, portfolioId } = await context.params;
  return mutateTenantResource(request, tenantId, portfolioId, "portfolio", "update");
}
