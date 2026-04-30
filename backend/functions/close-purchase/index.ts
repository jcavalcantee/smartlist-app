import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { GetCommand, PutCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto';
import { db, TABLE, keys } from '../../shared/utils/dynamo';
import { ok, badRequest, unauthorized, notFound, serverError } from '../../shared/utils/response';
import { getUserId } from '../../shared/utils/auth';
import { MonthlyList, PurchaseSnapshot } from '../../shared/models';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const userId = getUserId(event);
    if (!userId) return unauthorized();

    const yearMonth = event.pathParameters?.yearMonth;
    if (!yearMonth) return badRequest('yearMonth is required');

    const listKey = keys.list(userId, yearMonth);
    const existing = await db.send(new GetCommand({ TableName: TABLE, Key: listKey }));

    if (!existing.Item) return notFound(`List for ${yearMonth} not found`);

    const list = existing.Item as MonthlyList;
    if (list.status === 'CLOSED') return badRequest(`List for ${yearMonth} is already closed`);

    const body = event.body ? JSON.parse(event.body) : {};
    const adjustedTotal: number | undefined =
      typeof body.adjustedTotal === 'number' ? body.adjustedTotal : undefined;

    const snapshotId = randomUUID();
    const closedAt = new Date().toISOString();

    const snapshot: PurchaseSnapshot = {
      ...keys.history(userId, snapshotId),
      snapshotId,
      userId,
      yearMonth,
      items: list.items,
      totalItems: list.items.reduce((sum, i) => sum + i.quantity, 0),
      ...(adjustedTotal !== undefined && { adjustedTotal }),
      closedAt,
    };

    await Promise.all([
      db.send(new PutCommand({ TableName: TABLE, Item: snapshot })),
      db.send(new UpdateCommand({
        TableName: TABLE,
        Key: listKey,
        UpdateExpression: adjustedTotal !== undefined
          ? 'SET #status = :closed, updatedAt = :closedAt, adjustedTotal = :adj'
          : 'SET #status = :closed, updatedAt = :closedAt',
        ExpressionAttributeNames: { '#status': 'status' },
        ExpressionAttributeValues: {
          ':closed': 'CLOSED',
          ':closedAt': closedAt,
          ...(adjustedTotal !== undefined && { ':adj': adjustedTotal }),
        },
      })),
    ]);

    return ok({ snapshotId, closedAt, totalItems: snapshot.totalItems });
  } catch (err) {
    return serverError(err);
  }
};
