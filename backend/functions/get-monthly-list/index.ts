import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { GetCommand } from '@aws-sdk/lib-dynamodb';
import { db, TABLE, keys, currentYearMonth } from '../../shared/utils/dynamo';
import { ok, unauthorized, notFound, serverError } from '../../shared/utils/response';
import { getUserId } from '../../shared/utils/auth';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const userId = getUserId(event);
    if (!userId) return unauthorized();

    const yearMonth = event.pathParameters?.yearMonth ?? currentYearMonth();

    const result = await db.send(new GetCommand({
      TableName: TABLE,
      Key: keys.list(userId, yearMonth),
    }));

    if (!result.Item) return notFound(`No list found for ${yearMonth}`);

    return ok(result.Item);
  } catch (err) {
    return serverError(err);
  }
};
