import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  listReminders,
  createReminder,
  updateReminder,
  payReminder,
  skipReminder,
} from '../api/reminders';
import type {
  CreateReminderRequest,
  UpdateReminderRequest,
  PayReminderRequest,
  Reminder,
  ListResponse,
} from '../types';
import toast from 'react-hot-toast';

export function useReminders(dueBefore?: string) {
  return useQuery({
    queryKey: ['reminders', dueBefore],
    queryFn: () => listReminders(dueBefore),
  });
}

export function useCreateReminder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateReminderRequest) => createReminder(data),
    onMutate: async (data) => {
      await queryClient.cancelQueries({ queryKey: ['reminders'] });
      const previous = queryClient.getQueriesData({ queryKey: ['reminders'] });

      queryClient.setQueriesData<ListResponse<Reminder>>(
        { queryKey: ['reminders'] },
        (old) => ({
          items: [
            ...(old?.items ?? []),
            {
              id: 'optimistic-' + Date.now(),
              user_id: '',
              title: data.title,
              amount_paisa: data.amount_paisa ?? null,
              default_type: data.default_type,
              recurrence_type: data.recurrence_type,
              recurrence_day: data.recurrence_day ?? null,
              next_due_at: data.next_due_at,
              linked_bucket_id: data.linked_bucket_id ?? null,
              linked_person_id: data.linked_person_id ?? null,
              status: 'active' as const,
              created_at: new Date().toISOString(),
            },
          ],
        })
      );

      return { previous };
    },
    onError: (_err, _data, context) => {
      context?.previous.forEach(([key, data]) => {
        queryClient.setQueryData(key, data);
      });
      toast.error('Failed to create reminder');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['reminders'] });
    },
    onSuccess: () => toast.success('Saved'),
  });
}

export function useUpdateReminder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateReminderRequest }) =>
      updateReminder(id, data),
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['reminders'] });
    },
    onSuccess: () => toast.success('Updated'),
    onError: () => toast.error('Failed to update reminder'),
  });
}

export function usePayReminder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: PayReminderRequest }) =>
      payReminder(id, data),
    onMutate: async ({ id }) => {
      await queryClient.cancelQueries({ queryKey: ['reminders'] });
      const previous = queryClient.getQueriesData({ queryKey: ['reminders'] });

      queryClient.setQueriesData<ListResponse<Reminder>>(
        { queryKey: ['reminders'] },
        (old) => ({
          items: (old?.items ?? []).filter((r) => r.id !== id),
        })
      );

      return { previous };
    },
    onError: (_err, _data, context) => {
      context?.previous.forEach(([key, data]) => {
        queryClient.setQueryData(key, data);
      });
      toast.error('Payment failed');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['reminders'] });
      queryClient.invalidateQueries({ queryKey: ['transactions'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: (res) =>
      toast.success(`Payment recorded (TX: ${res.transaction.id.slice(0, 8)}…)`),
  });
}

export function useSkipReminder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => skipReminder(id),
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: ['reminders'] });
      const previous = queryClient.getQueriesData({ queryKey: ['reminders'] });

      queryClient.setQueriesData<ListResponse<Reminder>>(
        { queryKey: ['reminders'] },
        (old) => ({
          items: (old?.items ?? []).filter((r) => r.id !== id),
        })
      );

      return { previous };
    },
    onError: (_err, _data, context) => {
      context?.previous.forEach(([key, data]) => {
        queryClient.setQueryData(key, data);
      });
      toast.error('Failed to skip');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['reminders'] });
    },
    onSuccess: () => toast('Skipped', { icon: '⏭️' }),
  });
}
