import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useReminders, useCreateReminder, useUpdateReminder, useSkipReminder } from '../hooks/useReminders';
import { useBuckets } from '../hooks/useBuckets';
import { usePeople } from '../hooks/usePeople';

import { PageHeader } from '../components/layout/PageHeader';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Drawer } from '../components/ui/Drawer';
import { PayModal } from '../components/PayModal';
import { SkeletonRow } from '../components/ui/Skeletons';
import { formatBDT } from '../utils/money';
import { formatDate, formatRelative, toDateTimeLocal } from '../utils/date';
import { Plus, Pencil, Bell, AlertTriangle } from 'lucide-react';
import { parseISO, differenceInDays, isPast } from 'date-fns';
import type { Reminder, TransactionType, RecurrenceType } from '../types';

const TYPES: { value: TransactionType; label: string }[] = [
  { value: 'expense', label: 'Expense' },
  { value: 'income', label: 'Income' },
  { value: 'transfer', label: 'Transfer' },
  { value: 'loan_given', label: 'Loan Given' },
  { value: 'loan_taken', label: 'Loan Taken' },
  { value: 'repayment_received', label: 'Repayment In' },
  { value: 'repayment_paid', label: 'Repayment Out' },
];

const RECURRENCE: { value: RecurrenceType; label: string }[] = [
  { value: 'none', label: 'One-time' },
  { value: 'weekly', label: 'Weekly' },
  { value: 'monthly', label: 'Monthly' },
  { value: 'yearly', label: 'Yearly' },
];

function getDueColor(dueAt: string): 'red' | 'amber' | 'neutral' {
  const due = parseISO(dueAt);
  if (isPast(due)) return 'red';
  if (differenceInDays(due, new Date()) <= 3) return 'amber';
  return 'neutral';
}

export default function RemindersPage() {
  const { data, isLoading } = useReminders();
  const { data: bucketsData } = useBuckets();
  const { data: peopleData } = usePeople();

  const createMutation = useCreateReminder();
  const updateMutation = useUpdateReminder();
  const skipMutation = useSkipReminder();

  const [formOpen, setFormOpen] = useState(false);
  const [editReminder, setEditReminder] = useState<Reminder | null>(null);
  const [payReminder, setPayReminder] = useState<Reminder | null>(null);

  // Form state
  const [title, setTitle] = useState('');
  const [amount, setAmount] = useState('');
  const [defaultType, setDefaultType] = useState<TransactionType>('expense');
  const [recurrence, setRecurrence] = useState<RecurrenceType>('monthly');
  const [recurrenceDay, setRecurrenceDay] = useState('');
  const [nextDueAt, setNextDueAt] = useState(toDateTimeLocal());
  const [linkedBucket, setLinkedBucket] = useState('');
  const [linkedPerson, setLinkedPerson] = useState('');

  const reminders = (data?.items ?? []).sort(
    (a, b) => new Date(a.next_due_at).getTime() - new Date(b.next_due_at).getTime()
  );

  const resetForm = () => {
    setTitle(''); setAmount(''); setDefaultType('expense'); setRecurrence('monthly');
    setRecurrenceDay(''); setNextDueAt(toDateTimeLocal()); setLinkedBucket(''); setLinkedPerson('');
  };

  const openEdit = (r: Reminder) => {
    setEditReminder(r);
    setTitle(r.title);
    setAmount(r.amount_paisa ? (r.amount_paisa / 100).toFixed(2) : '');
    setDefaultType(r.default_type);
    setRecurrence(r.recurrence_type);
    setRecurrenceDay(r.recurrence_day?.toString() ?? '');
    setNextDueAt(toDateTimeLocal(r.next_due_at));
    setLinkedBucket(r.linked_bucket_id ?? '');
    setLinkedPerson(r.linked_person_id ?? '');
    setFormOpen(true);
  };

  const handleSubmit = () => {
    if (!title.trim()) return;
    const paisa = amount ? Math.round(parseFloat(amount) * 100) : undefined;
    const body = {
      title: title.trim(),
      ...(paisa ? { amount_paisa: paisa } : {}),
      default_type: defaultType,
      recurrence_type: recurrence,
      ...(recurrence === 'monthly' && recurrenceDay ? { recurrence_day: parseInt(recurrenceDay) } : {}),
      next_due_at: new Date(nextDueAt).toISOString(),
      ...(linkedBucket ? { linked_bucket_id: linkedBucket } : {}),
      ...(linkedPerson ? { linked_person_id: linkedPerson } : {}),
    };

    if (editReminder) {
      updateMutation.mutate({ id: editReminder.id, data: body }, { onSuccess: () => { setFormOpen(false); setEditReminder(null); resetForm(); } });
    } else {
      createMutation.mutate(body, { onSuccess: () => { setFormOpen(false); resetForm(); } });
    }
  };

  const bucketOptions = (bucketsData?.items ?? []).map((b) => ({ value: b.id, label: b.name }));
  const personOptions = (peopleData?.items ?? []).map((p) => ({ value: p.id, label: p.name }));

  return (
    <div className="space-y-6">
      <PageHeader title="Reminders" subtitle="Recurring & one-time payments" action={<Button onClick={() => { setEditReminder(null); resetForm(); setFormOpen(true); }}><Plus size={16} /> Add Reminder</Button>} />

      <div className="bg-surface-900/50 border border-surface-800 rounded-2xl overflow-hidden">
        {isLoading ? (
          <div>{Array.from({ length: 5 }).map((_, i) => <SkeletonRow key={i} />)}</div>
        ) : reminders.length === 0 ? (
          <div className="p-12 text-center text-surface-500"><Bell size={48} className="mx-auto mb-4 opacity-30" /><p>No reminders yet.</p></div>
        ) : (
          <AnimatePresence initial={false}>
            {reminders.map((r) => {
              const dueColor = getDueColor(r.next_due_at);
              return (
                <motion.div key={r.id} layout initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, x: 40, height: 0 }} transition={{ duration: 0.15 }}
                  className="px-5 py-4 border-b border-surface-800/50 last:border-0 hover:bg-surface-800/20 transition-colors"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        {dueColor === 'red' && <AlertTriangle size={14} className="text-red-400" />}
                        <p className="text-sm font-medium text-surface-200">{r.title}</p>
                        <Badge color={dueColor === 'red' ? 'red' : dueColor === 'amber' ? 'amber' : 'blue'}>{r.recurrence_type}</Badge>
                        {r.status !== 'active' && <Badge color="neutral">{r.status}</Badge>}
                      </div>
                      <p className="text-xs text-surface-500 mt-1">
                        {r.amount_paisa ? formatBDT(r.amount_paisa) : 'Amount not set'} · Due {formatRelative(r.next_due_at)} ({formatDate(r.next_due_at)})
                      </p>
                    </div>
                    <div className="flex gap-1.5 shrink-0 ml-4">
                      <Button size="sm" onClick={() => setPayReminder(r)}>Pay</Button>
                      <Button size="sm" variant="ghost" loading={skipMutation.isPending} onClick={() => { if (confirm('Skip this reminder?')) skipMutation.mutate(r.id); }}>Skip</Button>
                      <button onClick={() => openEdit(r)} className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-primary-400 transition-colors cursor-pointer"><Pencil size={14} /></button>
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </AnimatePresence>
        )}
      </div>

      {/* Add/Edit Drawer */}
      <Drawer open={formOpen} onClose={() => { setFormOpen(false); setEditReminder(null); }} title={editReminder ? 'Edit Reminder' : 'New Reminder'}>
        <div className="space-y-4">
          <Input label="Title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. DPS, Rent" />
          <Input label="Amount (BDT, optional)" type="number" step="0.01" min="0.01" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="0.00" />
          <Select label="Transaction Type" options={TYPES} value={defaultType} onChange={(e) => setDefaultType(e.target.value as TransactionType)} />
          <Select label="Recurrence" options={RECURRENCE} value={recurrence} onChange={(e) => setRecurrence(e.target.value as RecurrenceType)} />
          {recurrence === 'monthly' && <Input label="Day of Month (1-31)" type="number" min="1" max="31" value={recurrenceDay} onChange={(e) => setRecurrenceDay(e.target.value)} />}
          <Input label="Next Due Date" type="datetime-local" value={nextDueAt} onChange={(e) => setNextDueAt(e.target.value)} />
          <Select label="Linked Bucket (optional)" options={bucketOptions} placeholder="Select bucket" value={linkedBucket} onChange={(e) => setLinkedBucket(e.target.value)} />
          <Select label="Linked Person (optional)" options={personOptions} placeholder="Select person" value={linkedPerson} onChange={(e) => setLinkedPerson(e.target.value)} />
          <div className="flex gap-3 pt-2">
            <Button onClick={handleSubmit} loading={createMutation.isPending || updateMutation.isPending}>{editReminder ? 'Update' : 'Create'}</Button>
            <Button variant="secondary" onClick={() => { setFormOpen(false); setEditReminder(null); }}>Cancel</Button>
          </div>
        </div>
      </Drawer>

      <PayModal open={!!payReminder} onClose={() => setPayReminder(null)} reminder={payReminder} />
    </div>
  );
}
