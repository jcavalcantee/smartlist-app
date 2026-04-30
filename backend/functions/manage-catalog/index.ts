import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { PutCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';
import { db, TABLE, keys } from '../../shared/utils/dynamo';
import { ok, created, badRequest, unauthorized, serverError } from '../../shared/utils/response';
import { getUserId } from '../../shared/utils/auth';
import { CatalogItem, UnitType } from '../../shared/models';

interface CreateBody {
  canonical: string;
  aliases?: string[];
  unit?: UnitType;
}

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const userId = getUserId(event);
    if (!userId) return unauthorized();

    if (event.httpMethod === 'GET') {
      // TODO Fase 5: substituir Scan por GSI quando o catálogo crescer
      const result = await db.send(new ScanCommand({
        TableName: TABLE,
        FilterExpression: 'begins_with(PK, :prefix)',
        ExpressionAttributeValues: { ':prefix': 'CATALOG#' },
      }));
      return ok({ items: result.Items ?? [] });
    }

    const body = JSON.parse(event.body ?? '{}') as CreateBody;
    if (!body.canonical?.trim()) return badRequest('canonical is required');

    const canonical = body.canonical.toLowerCase().trim();
    const now = new Date().toISOString();

    const item: CatalogItem = {
      ...keys.catalog(canonical),
      canonical,
      aliases: body.aliases ?? [],
      unit: body.unit ?? 'unit',
      createdAt: now,
      updatedAt: now,
    };

    await db.send(new PutCommand({ TableName: TABLE, Item: item }));
    return created(item);
  } catch (err) {
    return serverError(err);
  }
};
