import { useState, useEffect } from 'react';
import { Input } from './ui/Input';
import { Select } from './ui/Select';
import { Textarea } from './ui/Textarea';
import { Button } from './ui/Button';
import { Drawer } from './ui/Drawer';
import { useBuckets } from '../hooks/useBuckets';
import { usePeople } from '../hooks/usePeople';
import { useTags } from '../hooks/useTags';
import { useCreateTransaction, useUpdateTransaction } from '../hooks/useTransactions';
import { handleApiError } from '../utils/errors';
import { toDateTimeLocal } from '../utils/date';
import type { Transaction, TransactionType } from '../types';

const TRANSACTION_TYPES: { value: TransactionType; label: string; color: string }[] = [
  { value: 'expense', label: 'Expense', color: 'bg-red-500' },
  { value: 'income', label: 'Income', color: 'bg-emerald-500' },
  { value: 'transfer', label: 'Transfer', color: 'bg-blue-500' },
  { value: 'loan_given', label: 'Loan Given', color: 'bg-orange-500' },
  { value: 'loan_taken', label: 'Loan Taken', color: 'bg-orange-500' },
  { value: 'repayment_received', label: 'Repayment In', color: 'bg-purple-500' },
  { value: 'repayment_paid', label: 'Repayment Out', color: 'bg-purple-500' },
];

const TYPE_FIELDS: Record<
  TransactionType,
  { fromBucket: boolean; toBucket: boolean; person: 'required' | 'optional' | 'hidden' }
> = {
  expense: { fromBucket: true, toBucket: false, person: 'optional' },
  income: { fromBucket: false, toBucket: true, person: 'optional' },
  transfer: { fromBucket: true, toBucket: true, person: 'hidden' },
  loan_given: { fromBucket: true, toBucket: false, person: 'required' },
  loan_taken: { fromBucket: false, toBucket: true, person: 'required' },
  repayment_received: { fromBucket: false, toBucket: true, person: 'required' },
  repayment_paid: { fromBucket: true, toBucket: false, person: 'required' },
};

interface TransactionFormProps {
  open: boolean;
  onClose: () => void;
  transaction?: Transaction | null;
}

export function TransactionForm({ open, onClose, transaction }: TransactionFormProps) {
  const { data: bucketsData } = useBuckets();
  const { data: peopleData } = usePeople();
  const { data: tagsData } = useTags();
  const createMutation = useCreateTransaction();
  const updateMutation = useUpdateTransaction();

  const isEdit = !!transaction;

  // Form state
  const [type, setType] = useState<TransactionType>('expense');
  const [amount, setAmount] = useState('');
  const [fromBucketId, setFromBucketId] = useState('');
  const [toBucketId, setToBucketId] = useState('');
  const [personId, setPersonId] = useState('');
  const [note, setNote] = useState('');
  const [occurredAt, setOccurredAt] = useState(toDateTimeLocal());
  const [tagIds, setTagIds] = useState<string[]>([]);
  const [error, setError] = useState('');

  // Reset form when drawer opens/closes
  useEffect(() => {
    if (open) {
      if (transaction) {
        setType(transaction.type);
        setAmount((transaction.amount_paisa / 100).toFixed(2));
        setFromBucketId(transaction.from_bucket_id ?? '');
        setToBucketId(transaction.to_bucket_id ?? '');
        setPersonId(transaction.person_id ?? '');
        setNote(transaction.note);
        setOccurredAt(toDateTimeLocal(transaction.occurred_at));
        setTagIds(transaction.tags.map((t) => t.id));
      } else {
        setType('expense');
        setAmount('');
        setFromBucketId('');
        setToBucketId('');
        setPersonId('');
        setNote('');
        setOccurredAt(toDateTimeLocal());
        setTagIds([]);
      }
      setError('');
    }
  }, [open, transaction]);

  const fields = TYPE_FIELDS[type];

  const bucketOptions = (bucketsData?.items ?? []).map((b) => ({
    value: b.id,
    label: b.name,
  }));

  const personOptions = (peopleData?.items ?? []).map((p) => ({
    value: p.id,
    label: p.name,
  }));

  const handleTypeChange = (newType: TransactionType) => {
    setType(newType);
    const newFields = TYPE_FIELDS[newType];
    if (!newFields.fromBucket) setFromBucketId('');
    if (!newFields.toBucket) setToBucketId('');
    if (newFields.person === 'hidden') setPersonId('');
  };

  const handleSave = async () => {
    console.log('handleSave triggered');
    // Validate
    const paisa = Math.round(parseFloat(amount) * 100);
    console.log('Amount paisa:', paisa);
    if (!amount || isNaN(paisa) || paisa <= 0) {
      console.error('Validation failed: invalid amount');
      setError('Enter a valid positive amount');
      return;
    }

    if (!occurredAt) {
      console.error('Validation failed: missing date');
      setError('Date is required');
      return;
    }

    setError('');

    const body = {
      type,
      amount_paisa: paisa,
      ...(fields.fromBucket && fromBucketId ? { from_bucket_id: fromBucketId } : {}),
      ...(fields.toBucket && toBucketId ? { to_bucket_id: toBucketId } : {}),
      ...(fields.person !== 'hidden' && personId ? { person_id: personId } : {}),
      note: note || '',
      occurred_at: new Date(occurredAt).toISOString(),
      tag_ids: tagIds,
    };

    console.log('Sending transaction POST body:', body);

    try {
      if (isEdit && transaction) {
        await updateMutation.mutateAsync({ id: transaction.id, data: body });
      } else {
        await createMutation.mutateAsync(body);
      }
      console.log('Mutation successful');
      onClose();
    } catch (err) {
      console.error('Mutation failed:', err);
      const msg = handleApiError(err);
      if (msg) setError(msg);
    }
  };

  const isPending = createMutation.isPending || updateMutation.isPending;

  return (
    <Drawer
      open={open}
      onClose={onClose}
      title={isEdit ? 'Edit Transaction' : 'New Transaction'}
    >
      <div className="space-y-5">
        {/* Error banner */}
        {error && (
          <div className="px-4 py-3 rounded-lg bg-red-500/10 border border-red-500/20 text-sm text-red-400">
            {error}
          </div>
        )}

        {/* Type selector */}
        <div className="space-y-1.5">
          <label className="block text-sm font-medium text-surface-300">Type</label>
          <div className="grid grid-cols-2 gap-1.5">
            {TRANSACTION_TYPES.map(({ value, label, color }) => (
              <button
                key={value}
                type="button"
                onClick={() => handleTypeChange(value)}
                className={`
                  px-3 py-2 rounded-lg text-xs font-medium transition-all duration-150 cursor-pointer
                  ${
                    type === value
                      ? `${color} text-white shadow-md`
                      : 'bg-surface-800 text-surface-400 hover:bg-surface-700'
                  }
                `}
              >
                {label}
              </button>
            ))}
          </div>
        </div>

        {/* Amount */}
        <Input
          label="Amount (BDT)"
          type="text"
          inputMode="decimal"
          placeholder="0.00"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
        />

        {/* From Bucket */}
        {fields.fromBucket && (
          <Select
            label="From Bucket"
            options={bucketOptions}
            placeholder="Select bucket"
            value={fromBucketId}
            onChange={(e) => setFromBucketId(e.target.value)}
          />
        )}

        {/* To Bucket */}
        {fields.toBucket && (
          <Select
            label="To Bucket"
            options={bucketOptions}
            placeholder="Select bucket"
            value={toBucketId}
            onChange={(e) => setToBucketId(e.target.value)}
          />
        )}

        {/* Person */}
        {fields.person !== 'hidden' && (
          <Select
            label={`Person${fields.person === 'required' ? ' *' : ' (optional)'}`}
            options={personOptions}
            placeholder="Select person"
            value={personId}
            onChange={(e) => setPersonId(e.target.value)}
          />
        )}

        {/* Note */}
        <Textarea
          label="Note"
          placeholder="What's this for?"
          value={note}
          onChange={(e) => setNote(e.target.value)}
        />

        {/* Date & Time */}
        <Input
          label="Date & Time"
          type="datetime-local"
          value={occurredAt}
          onChange={(e) => setOccurredAt(e.target.value)}
        />

        {/* Tags multi-select */}
        <div className="space-y-1.5">
          <label className="block text-sm font-medium text-surface-300">Tags</label>
          <div className="flex flex-wrap gap-2">
            {(tagsData?.items ?? []).map((tag) => {
              const selected = tagIds.includes(tag.id);
              return (
                <button
                  key={tag.id}
                  type="button"
                  onClick={() => {
                    setTagIds((prev) =>
                      selected
                        ? prev.filter((id) => id !== tag.id)
                        : [...prev, tag.id]
                    );
                  }}
                  className={`
                    px-2.5 py-1 rounded-md text-xs font-medium transition-all cursor-pointer
                    ${
                      selected
                        ? 'bg-primary-600/20 text-primary-400 border border-primary-500/30'
                        : 'bg-surface-800 text-surface-400 border border-surface-700 hover:border-surface-600'
                    }
                  `}
                >
                  {tag.name}
                </button>
              );
            })}
            {(tagsData?.items ?? []).length === 0 && (
              <span className="text-xs text-surface-500">No tags created yet</span>
            )}
          </div>
        </div>

        {/* Actions */}
        <div className="flex gap-3 pt-3">
          <Button
            type="button"
            loading={isPending}
            disabled={isPending}
            onClick={handleSave}
          >
            {isEdit ? 'Update' : 'Save'}
          </Button>
          <Button type="button" variant="secondary" onClick={onClose}>
            Cancel
          </Button>
        </div>
      </div>
    </Drawer>
  );
}
