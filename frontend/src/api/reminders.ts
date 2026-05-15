import client from './client';
import type {
  Reminder,
  CreateReminderRequest,
  UpdateReminderRequest,
  PayReminderRequest,
  PayReminderResponse,
  ListResponse,
} from '../types';

export async function listReminders(dueBefore?: string): Promise<ListResponse<Reminder>> {
  const params: Record<string, string> = {};
  if (dueBefore) params.due_before = dueBefore;
  const res = await client.get<ListResponse<Reminder>>('reminders', { params });
  return res.data;
}

export async function createReminder(data: CreateReminderRequest): Promise<Reminder> {
  const res = await client.post<Reminder>('reminders', data);
  return res.data;
}

export async function updateReminder(
  id: string,
  data: UpdateReminderRequest
): Promise<Reminder> {
  const res = await client.patch<Reminder>(`reminders/${id}`, data);
  return res.data;
}

export async function payReminder(
  id: string,
  data: PayReminderRequest
): Promise<PayReminderResponse> {
  const res = await client.post<PayReminderResponse>(`reminders/${id}/pay`, data);
  return res.data;
}

export async function skipReminder(id: string): Promise<Reminder> {
  const res = await client.post<Reminder>(`reminders/${id}/skip`, {});
  return res.data;
}
