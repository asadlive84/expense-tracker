import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Modal } from './ui/Modal';
import { Input } from './ui/Input';
import { Textarea } from './ui/Textarea';
import { Button } from './ui/Button';
import { usePayReminder } from '../hooks/useReminders';
import { toDateTimeLocal } from '../utils/date';
import type { Reminder } from '../types';

interface PayModalProps {
  open: boolean;
  onClose: () => void;
  reminder: Reminder | null;
}

export function PayModal({ open, onClose, reminder }: PayModalProps) {
  const payMutation = usePayReminder();
  const [shakeButton, setShakeButton] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    defaultValues: {
      amount: reminder?.amount_paisa ? (reminder.amount_paisa / 100).toFixed(2) : '',
      occurred_at: toDateTimeLocal(),
      note: '',
    },
  });

  // Reset form when reminder changes
  if (open && reminder) {
    reset({
      amount: reminder.amount_paisa ? (reminder.amount_paisa / 100).toFixed(2) : '',
      occurred_at: toDateTimeLocal(),
      note: '',
    });
  }

  const onSubmit = async (data: { amount: string; occurred_at: string; note: string }) => {
    if (!reminder) return;
    const paisa = data.amount ? Math.round(parseFloat(data.amount) * 100) : undefined;

    try {
      await payMutation.mutateAsync({
        id: reminder.id,
        data: {
          ...(paisa ? { amount_paisa: paisa } : {}),
          occurred_at: new Date(data.occurred_at).toISOString(),
          note: data.note || '',
        },
      });
      onClose();
    } catch {
      setShakeButton(true);
      setTimeout(() => setShakeButton(false), 300);
    }
  };

  return (
    <Modal open={open} onClose={onClose} title={`Pay: ${reminder?.title ?? ''}`}>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <Input
          label="Amount (BDT)"
          type="number"
          step="0.01"
          min="0.01"
          placeholder="0.00"
          error={errors.amount?.message}
          {...register('amount')}
        />
        <Input
          label="Date & Time"
          type="datetime-local"
          {...register('occurred_at')}
        />
        <Textarea
          label="Note"
          placeholder="Optional note"
          {...register('note')}
        />
        <div className="flex gap-3">
          <Button
            type="submit"
            loading={payMutation.isPending}
            className={shakeButton ? 'animate-shake' : ''}
          >
            Record Payment
          </Button>
          <Button type="button" variant="secondary" onClick={onClose}>
            Cancel
          </Button>
        </div>
      </form>
    </Modal>
  );
}
