import client from './client';
import type { Tag, CreateTagRequest, UpdateTagRequest, ListResponse } from '../types';

export async function listTags(): Promise<ListResponse<Tag>> {
  const res = await client.get<ListResponse<Tag>>('tags');
  return res.data;
}

export async function createTag(data: CreateTagRequest): Promise<Tag> {
  const res = await client.post<Tag>('tags', data);
  return res.data;
}

export async function updateTag(id: string, data: UpdateTagRequest): Promise<Tag> {
  const res = await client.patch<Tag>(`tags/${id}`, data);
  return res.data;
}
