import client from './client';
import type { Bucket, CreateBucketRequest, UpdateBucketRequest, ListResponse } from '../types';

export async function listBuckets(): Promise<ListResponse<Bucket>> {
  const res = await client.get<ListResponse<Bucket>>('buckets');
  return res.data;
}

export async function createBucket(data: CreateBucketRequest): Promise<Bucket> {
  const res = await client.post<Bucket>('buckets', data);
  return res.data;
}

export async function updateBucket(id: string, data: UpdateBucketRequest): Promise<Bucket> {
  const res = await client.patch<Bucket>(`buckets/${id}`, data);
  return res.data;
}
