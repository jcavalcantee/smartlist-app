export type ListStatus = 'OPEN' | 'CLOSED';
export type UnitType = 'unit' | 'kg' | 'g' | 'l' | 'ml' | 'pack';
export type ItemSource = 'app';

export interface ListItem {
  itemId: string;
  canonicalName: string;
  displayName: string;
  quantity: number;
  unit: UnitType;
  price?: number;
  addedAt: string;
  updatedAt: string;
  source: ItemSource;
}

export interface MonthlyList {
  PK: string;         // USER#<userId>
  SK: string;         // LIST#<YYYY-MM>
  yearMonth: string;
  userId: string;
  status: ListStatus;
  items: ListItem[];
  adjustedTotal?: number;
  createdAt: string;
  updatedAt: string;
}

export interface PurchaseSnapshot {
  PK: string;         // USER#<userId>
  SK: string;         // HISTORY#<uuid>
  snapshotId: string;
  userId: string;
  yearMonth: string;
  items: ListItem[];
  totalItems: number;
  adjustedTotal?: number;
  closedAt: string;
}

export interface CatalogItem {
  PK: string;         // CATALOG#<canonical>
  SK: string;         // META
  canonical: string;
  aliases: string[];
  unit: UnitType;
  createdAt: string;
  updatedAt: string;
}
