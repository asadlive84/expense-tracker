import client from './client';
import type { BucketBalance, PersonBalance, TagTotal, MonthlySummary, ListResponse } from '../types';

export async function getBucketBalances(): Promise<ListResponse<BucketBalance>> {
  const res = await client.get<ListResponse<BucketBalance>>('reports/bucket-balances');
  return res.data;
}

export async function getPersonBalances(): Promise<ListResponse<PersonBalance>> {
  const res = await client.get<ListResponse<PersonBalance>>('reports/person-balances');
  return res.data;
}

export async function getTagTotals(from: string, to: string): Promise<ListResponse<TagTotal>> {
  const res = await client.get<ListResponse<TagTotal>>('reports/tag-totals', {
    params: { from, to },
  });
  return res.data;
}

export async function getMonthlySummary(month: string): Promise<MonthlySummary> {
  const res = await client.get<MonthlySummary>('reports/summary', {
    params: { month },
  });
  return res.data;
}
