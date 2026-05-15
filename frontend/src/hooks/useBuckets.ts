import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { listBuckets, createBucket, updateBucket } from '../api/buckets';
import type { CreateBucketRequest, UpdateBucketRequest, Bucket, ListResponse } from '../types';
import toast from 'react-hot-toast';

export function useBuckets() {
  return useQuery({
    queryKey: ['buckets'],
    queryFn: listBuckets,
    staleTime: 5 * 60 * 1000,
  });
}

export function useCreateBucket() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateBucketRequest) => createBucket(data),
    onMutate: async (data) => {
      await queryClient.cancelQueries({ queryKey: ['buckets'] });
      const previous = queryClient.getQueryData<ListResponse<Bucket>>(['buckets']);
      queryClient.setQueryData<ListResponse<Bucket>>(['buckets'], (old) => ({
        items: [
          ...(old?.items ?? []),
          {
            id: 'optimistic-' + Date.now(),
            user_id: '',
            name: data.name,
            starting_balance_paisa: data.starting_balance_paisa ?? 0,
            created_at: new Date().toISOString(),
          },
        ],
      }));
      return { previous };
    },
    onError: (_err, _data, context) => {
      queryClient.setQueryData(['buckets'], context?.previous);
      toast.error('Failed to create bucket');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['buckets'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: () => toast.success('Saved'),
  });
}

export function useUpdateBucket() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateBucketRequest }) =>
      updateBucket(id, data),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: ['buckets'] });
      const previous = queryClient.getQueryData<ListResponse<Bucket>>(['buckets']);
      queryClient.setQueryData<ListResponse<Bucket>>(['buckets'], (old) => ({
        items: (old?.items ?? []).map((b) =>
          b.id === id
            ? {
                ...b,
                ...(data.name !== undefined && { name: data.name }),
                ...(data.archived === true && { archived_at: new Date().toISOString() }),
                ...(data.archived === false && { archived_at: null }),
              }
            : b
        ),
      }));
      return { previous };
    },
    onError: (_err, _data, context) => {
      queryClient.setQueryData(['buckets'], context?.previous);
      toast.error('Failed to update bucket');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['buckets'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: () => toast.success('Updated'),
  });
}
