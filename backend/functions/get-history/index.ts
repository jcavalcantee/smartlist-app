import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { QueryCommand } from '@aws-sdk/lib-dynamodb';
import { db, TABLE } from '../../shared/utils/dynamo';
import { ok, unauthorized, serverError } from '../../shared/utils/response';
import { getUserId } from '../../shared/utils/auth';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const userId = getUserId(event);
    if (!userId) return unauthorized();

    const result = await db.send(new QueryCommand({
      TableName: TABLE,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :prefix)',
      ExpressionAttributeValues: {
        ':pk': `USER#${userId}`,
        ':prefix': 'HISTORY#',
      },
      ScanIndexForward: false,
    }));

    return ok(result.Items ?? []);
  } catch (err) {
    return serverError(err);
  }
};
