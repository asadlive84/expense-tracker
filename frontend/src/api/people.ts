import client from './client';
import type { Person, CreatePersonRequest, UpdatePersonRequest, ListResponse } from '../types';

export async function listPeople(): Promise<ListResponse<Person>> {
  const res = await client.get<ListResponse<Person>>('people');
  return res.data;
}

export async function createPerson(data: CreatePersonRequest): Promise<Person> {
  const res = await client.post<Person>('people', data);
  return res.data;
}

export async function updatePerson(id: string, data: UpdatePersonRequest): Promise<Person> {
  const res = await client.patch<Person>(`people/${id}`, data);
  return res.data;
}
