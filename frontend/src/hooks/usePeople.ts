import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { listPeople, createPerson, updatePerson } from '../api/people';
import type { CreatePersonRequest, UpdatePersonRequest, Person, ListResponse } from '../types';
import toast from 'react-hot-toast';

export function usePeople() {
  return useQuery({
    queryKey: ['people'],
    queryFn: listPeople,
    staleTime: 5 * 60 * 1000,
  });
}

export function useCreatePerson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreatePersonRequest) => createPerson(data),
    onMutate: async (data) => {
      await queryClient.cancelQueries({ queryKey: ['people'] });
      const previous = queryClient.getQueryData<ListResponse<Person>>(['people']);
      queryClient.setQueryData<ListResponse<Person>>(['people'], (old) => ({
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
      queryClient.setQueryData(['people'], context?.previous);
      toast.error('Failed to create person');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['people'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: () => toast.success('Saved'),
  });
}

export function useUpdatePerson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdatePersonRequest }) =>
      updatePerson(id, data),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: ['people'] });
      const previous = queryClient.getQueryData<ListResponse<Person>>(['people']);
      queryClient.setQueryData<ListResponse<Person>>(['people'], (old) => ({
        items: (old?.items ?? []).map((p) =>
          p.id === id
            ? {
                ...p,
                ...(data.name !== undefined && { name: data.name }),
                ...(data.archived === true && { archived_at: new Date().toISOString() }),
                ...(data.archived === false && { archived_at: null }),
              }
            : p
        ),
      }));
      return { previous };
    },
    onError: (_err, _data, context) => {
      queryClient.setQueryData(['people'], context?.previous);
      toast.error('Failed to update person');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['people'] });
      queryClient.invalidateQueries({ queryKey: ['reports'] });
    },
    onSuccess: () => toast.success('Updated'),
  });
}
