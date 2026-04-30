import { APIGatewayProxyResult } from 'aws-lambda';

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
};

export const ok = (body: unknown): APIGatewayProxyResult =>
  ({ statusCode: 200, headers, body: JSON.stringify(body) });

export const created = (body: unknown): APIGatewayProxyResult =>
  ({ statusCode: 201, headers, body: JSON.stringify(body) });

export const badRequest = (message: string): APIGatewayProxyResult =>
  ({ statusCode: 400, headers, body: JSON.stringify({ error: message }) });

export const unauthorized = (): APIGatewayProxyResult =>
  ({ statusCode: 401, headers, body: JSON.stringify({ error: 'Unauthorized' }) });

export const notFound = (message = 'Not found'): APIGatewayProxyResult =>
  ({ statusCode: 404, headers, body: JSON.stringify({ error: message }) });

export const serverError = (err: unknown): APIGatewayProxyResult => {
  console.error(err);
  return { statusCode: 500, headers, body: JSON.stringify({ error: 'Internal server error' }) };
};
