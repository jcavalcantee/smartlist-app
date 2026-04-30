import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { GetCommand, PutCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto';
import { db, TABLE, keys, currentYearMonth } from '../../shared/utils/dynamo';
import { ok, created, badRequest, unauthorized, serverError } from '../../shared/utils/response';
import { getUserId } from '../../shared/utils/auth';
import { ListItem, MonthlyList, UnitType, ItemSource } from '../../shared/models';

interface Body {
  displayName: string;
  quantity?: number;
  unit?: UnitType;
  price?: number;
  source?: ItemSource;
  yearMonth?: string;
}

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const userId = getUserId(event);
    if (!userId) return unauthorized();

    const body = JSON.parse(event.body ?? '{}') as Body;
    if (!body.displayName?.trim()) return badRequest('displayName is required');

    const yearMonth = body.yearMonth ?? currentYearMonth();
    const key = keys.list(userId, yearMonth);
    const now = new Date().toISOString();

    const canonicalName = body.displayName.toLowerCase().trim();

    const newItem: ListItem = {
      itemId: randomUUID(),
      canonicalName,
      displayName: body.displayName.trim(),
      quantity: body.quantity ?? 1,
      unit: body.unit ?? 'unit',
      ...(body.price != null && { price: body.price }),
      addedAt: now,
      updatedAt: now,
      source: body.source ?? 'app',
    };

    const existing = await db.send(new GetCommand({ TableName: TABLE, Key: key }));

    if (!existing.Item) {
      const newList: MonthlyList = {
        ...key,
        yearMonth,
        userId,
        status: 'OPEN',
        items: [newItem],
        createdAt: now,
        updatedAt: now,
      };
      await db.send(new PutCommand({ TableName: TABLE, Item: newList }));
    } else {
      const list = existing.Item as MonthlyList;
      if (list.status !== 'OPEN') return badRequest('Lista já fechada');

      const idx = list.items.findIndex(i => i.canonicalName === canonicalName);
      if (idx >= 0) {
        list.items[idx].quantity += newItem.quantity;
        list.items[idx].updatedAt = now;
      } else {
        list.items.push(newItem);
      }

      await db.send(new UpdateCommand({
        TableName: TABLE,
        Key: key,
        UpdateExpression: 'SET #items = :items, updatedAt = :now',
        ExpressionAttributeNames: { '#items': 'items' },
        ExpressionAttributeValues: { ':items': list.items, ':now': now },
      }));
    }

    return created({ item: newItem, yearMonth });
  } catch (err) {
    return serverError(err);
  }
};
