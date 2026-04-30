import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { GetCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { db, TABLE, keys, currentYearMonth } from '../../shared/utils/dynamo';
import { ok, badRequest, unauthorized, notFound, serverError } from '../../shared/utils/response';
import { getUserId } from '../../shared/utils/auth';
import { MonthlyList } from '../../shared/models';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const userId = getUserId(event);
    if (!userId) return unauthorized();

    const itemId = event.pathParameters?.itemId;
    if (!itemId) return badRequest('itemId is required');

    const yearMonth = event.queryStringParameters?.yearMonth ?? currentYearMonth();
    const key = keys.list(userId, yearMonth);

    const existing = await db.send(new GetCommand({ TableName: TABLE, Key: key }));
    if (!existing.Item) return notFound('Lista não encontrada');

    const list = existing.Item as MonthlyList;
    if (list.status !== 'OPEN') return badRequest('Lista já fechada, não é possível remover itens');

    const updatedItems = list.items.filter(i => i.itemId !== itemId);
    if (updatedItems.length === list.items.length) return notFound('Item não encontrado');

    await db.send(new UpdateCommand({
      TableName: TABLE,
      Key: key,
      UpdateExpression: 'SET #items = :items, updatedAt = :now',
      ExpressionAttributeNames: { '#items': 'items' },
      ExpressionAttributeValues: {
        ':items': updatedItems,
        ':now': new Date().toISOString(),
      },
    }));

    return ok({ removed: itemId });
  } catch (err) {
    return serverError(err);
  }
};
