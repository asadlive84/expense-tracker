import { useInfiniteQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  listTransactions,
  createTransaction,
  updateTransaction,
  deleteTransaction,
} from '../api/transactions';
import type { CreateTransactionRequest, TransactionFilters, TransactionList } from '../types';
import toast from 'react-hot-toast';

export function useTransactions(filters: TransactionFilters) {
  return useInfiniteQuery({
    queryKey: ['transactions', filters],
    queryFn: ({ pageParam }) =>
      listTransactions({ ...filters, cursor: pageParam as string }),
    getNextPageParam: (lastPage: TransactionList) =>
      lastPage.next_cursor || undefined,
    initialPageParam: '',
  });
}

export function useCreateTransaction() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateTransactionRequest) => createTransaction(data),
    onMutate: async (input) => {
      await queryClient.cancelQueries({ queryKey: ['transactions'] });
      const previous = queryClient.getQueriesData({ queryKey: ['transactions'] });

      queryClient.setQueriesData<{
        pages: TransactionList[];
        pageParams: string[];
      }>({ queryKey: ['transactions'] }, (old) => {
        if (!old || !old.pages) return old;
        const newPages = [...old.pages];
        if (newPages.length > 0) {
          newPages[0] = {
            ...newPages[0],
            items: [
              {
                id: 'optimistic-' + Date.now(),
                user_id: '',
                type: input.type,
                amount_paisa: input.amount_paisa,
                from_bucket_id: input.from_bucket_id ?? null,
                to_bucket_id: input.to_bucket_id ?? null,
                person_id: input.person_id ?? null,
                note: input.note ?? '',
                occurred_at: input.occurred_at,
                created_at: new Date().toISOString(),
                tags: [],
                reversed: false,
              },
              ...newPages[0].items,
            ],
          };
        }
        return { ...old, pages: newPages };
      });

      return { previous };
    },
    onError: (_err, _input, context) => {
      context?.previous.forEach(([key, data]) => {
        queryClient.setQueryData(key, data);
      });
      toast.error('Failed to save. Please try again.');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['transactions'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: () => toast.success('Saved'),
  });
}

export function useUpdateTransaction() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: CreateTransactionRequest }) =>
      updateTransaction(id, data),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: ['transactions'] });
      const previous = queryClient.getQueriesData({ queryKey: ['transactions'] });

      queryClient.setQueriesData<{
        pages: TransactionList[];
        pageParams: string[];
      }>({ queryKey: ['transactions'] }, (old) => {
        if (!old || !old.pages) return old;
        const newPages = old.pages.map((page) => ({
          ...page,
          items: page.items.map((tx) =>
            tx.id === id
              ? {
                  ...tx,
                  ...data,
                  from_bucket_id: data.from_bucket_id ?? null,
                  to_bucket_id: data.to_bucket_id ?? null,
                  person_id: data.person_id ?? null,
                  note: data.note ?? tx.note,
                }
              : tx
          ),
        }));
        return { ...old, pages: newPages };
      });

      return { previous };
    },
    onError: (_err, _data, context) => {
      context?.previous.forEach(([key, data]) => {
        queryClient.setQueryData(key, data);
      });
      toast.error('Failed to update. Please try again.');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['transactions'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: () => toast.success('Updated'),
  });
}

export function useDeleteTransaction() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => deleteTransaction(id),
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: ['transactions'] });
      const previous = queryClient.getQueriesData({ queryKey: ['transactions'] });

      queryClient.setQueriesData<{
        pages: TransactionList[];
        pageParams: string[];
      }>({ queryKey: ['transactions'] }, (old) => {
        if (!old || !old.pages) return old;
        const newPages = old.pages.map((page) => ({
          ...page,
          items: page.items.filter((tx) => tx.id !== id),
        }));
        return { ...old, pages: newPages };
      });

      return { previous };
    },
    onError: (_err, _data, context) => {
      context?.previous.forEach(([key, data]) => {
        queryClient.setQueryData(key, data);
      });
      toast.error('Failed to delete');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['transactions'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: () => toast('Deleted', { icon: '🗑️', duration: 2000 }),
  });
}
