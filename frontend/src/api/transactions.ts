import client from './client';
import type {
  Transaction,
  CreateTransactionRequest,
  TransactionList,
  TransactionFilters,
} from '../types';

export async function listTransactions(filters: TransactionFilters): Promise<TransactionList> {
  const params: Record<string, string | number> = {};
  if (filters.type) params.type = filters.type;
  if (filters.bucket_id) params.bucket_id = filters.bucket_id;
  if (filters.person_id) params.person_id = filters.person_id;
  if (filters.tag_id) params.tag_id = filters.tag_id;
  if (filters.from) params.from = filters.from;
  if (filters.to) params.to = filters.to;
  if (filters.limit) params.limit = filters.limit;
  if (filters.cursor) params.cursor = filters.cursor;

  const res = await client.get<TransactionList>('transactions', { params });
  return res.data;
}

export async function createTransaction(data: CreateTransactionRequest): Promise<Transaction> {
  const res = await client.post<Transaction>('transactions', data);
  return res.data;
}

export async function updateTransaction(
  id: string,
  data: CreateTransactionRequest
): Promise<Transaction> {
  const res = await client.patch<Transaction>(`transactions/${id}`, data);
  return res.data;
}

export async function deleteTransaction(id: string): Promise<void> {
  await client.delete(`transactions/${id}`);
}
