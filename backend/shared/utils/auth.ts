import { APIGatewayProxyEvent } from 'aws-lambda';

export function getUserId(event: APIGatewayProxyEvent): string | null {
  const ctx = event.requestContext?.authorizer as Record<string, unknown> | undefined;
  // HTTP API v2 JWT authorizer
  const jwtSub = (ctx?.jwt as Record<string, unknown> | undefined)?.claims as Record<string, unknown> | undefined;
  if (jwtSub?.sub) return jwtSub.sub as string;
  // REST API v1 Cognito authorizer (fallback)
  return (ctx?.claims as Record<string, unknown> | undefined)?.sub as string ?? null;
}
