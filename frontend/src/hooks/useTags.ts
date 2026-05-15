import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { listTags, createTag, updateTag } from '../api/tags';
import type { CreateTagRequest, UpdateTagRequest, Tag, ListResponse } from '../types';
import toast from 'react-hot-toast';

export function useTags() {
  return useQuery({
    queryKey: ['tags'],
    queryFn: listTags,
    staleTime: 5 * 60 * 1000,
  });
}

export function useCreateTag() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateTagRequest) => createTag(data),
    onMutate: async (data) => {
      await queryClient.cancelQueries({ queryKey: ['tags'] });
      const previous = queryClient.getQueryData<ListResponse<Tag>>(['tags']);
      queryClient.setQueryData<ListResponse<Tag>>(['tags'], (old) => ({
        items: [
          ...(old?.items ?? []),
          {
            id: 'optimistic-' + Date.now(),
            user_id: '',
            name: data.name,
            created_at: new Date().toISOString(),
          },
        ],
      }));
      return { previous };
    },
    onError: (_err, _data, context) => {
      queryClient.setQueryData(['tags'], context?.previous);
      toast.error('Failed to create tag');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['tags'] });
    },
    onSuccess: () => toast.success('Saved'),
  });
}

export function useUpdateTag() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateTagRequest }) =>
      updateTag(id, data),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: ['tags'] });
      const previous = queryClient.getQueryData<ListResponse<Tag>>(['tags']);
      queryClient.setQueryData<ListResponse<Tag>>(['tags'], (old) => ({
        items: (old?.items ?? []).map((t) =>
          t.id === id
            ? {
                ...t,
                ...(data.name !== undefined && { name: data.name }),
                ...(data.archived === true && { archived_at: new Date().toISOString() }),
                ...(data.archived === false && { archived_at: null }),
              }
            : t
        ),
      }));
      return { previous };
    },
    onError: (_err, _data, context) => {
      queryClient.setQueryData(['tags'], context?.previous);
      toast.error('Failed to update tag');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['tags'] });
    },
    onSuccess: () => toast.success('Updated'),
  });
}
