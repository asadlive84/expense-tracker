import { isAxiosError } from 'axios';
import type { ErrorEnvelope } from '../types';
import type { UseFormSetError, FieldValues, Path } from 'react-hook-form';
import toast from 'react-hot-toast';

export function handleApiError<T extends FieldValues>(
  error: unknown,
  setError?: UseFormSetError<T>
): string | undefined {
  if (!isAxiosError(error) || !error.response) {
    toast.error('Something went wrong. Please try again.');
    return 'Something went wrong. Please try again.';
  }

  const envelope = error.response.data as ErrorEnvelope;
  const detail = envelope?.error;

  if (!detail) {
    toast.error('Something went wrong. Please try again.');
    return 'Something went wrong. Please try again.';
  }

  switch (detail.code) {
    case 'validation_error':
      if (detail.fields && setError) {
        Object.entries(detail.fields).forEach(([field, message]) => {
          setError(field as Path<T>, { type: 'server', message });
        });
        return undefined;
      }
      return detail.message;

    case 'invalid_credentials':
      return detail.message || 'Invalid email or password';

    case 'conflict':
      toast.error(detail.message);
      return detail.message;

    case 'not_found':
      toast.error(detail.message || 'Resource not found');
      return undefined;

    case 'internal_error':
    default:
      toast.error('Something went wrong. Please try again.');
      return 'Something went wrong. Please try again.';
  }
}
