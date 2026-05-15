import client from './client';
import type { LoginRequest, RegisterRequest, LoginResponse } from '../types';

export async function login(data: LoginRequest): Promise<LoginResponse> {
  const res = await client.post<LoginResponse>('auth/login', data);
  return res.data;
}

export async function register(data: RegisterRequest): Promise<LoginResponse> {
  const res = await client.post<LoginResponse>('auth/register', data);
  return res.data;
}

export async function getMe(): Promise<{ user_id: string }> {
  const res = await client.get<{ user_id: string }>('me');
  return res.data;
}
