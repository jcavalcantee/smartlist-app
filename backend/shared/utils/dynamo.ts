import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});

export const db = DynamoDBDocumentClient.from(client, {
  marshallOptions: { removeUndefinedValues: true },
});

export const TABLE = process.env.TABLE_NAME!;

export const keys = {
  list: (userId: string, yearMonth: string) => ({
    PK: `USER#${userId}`,
    SK: `LIST#${yearMonth}`,
  }),
  history: (userId: string, snapshotId: string) => ({
    PK: `USER#${userId}`,
    SK: `HISTORY#${snapshotId}`,
  }),
  catalog: (canonical: string) => ({
    PK: `CATALOG#${canonical}`,
    SK: 'META',
  }),
};

export function currentYearMonth(): string {
  return new Date().toISOString().slice(0, 7); // YYYY-MM
}
