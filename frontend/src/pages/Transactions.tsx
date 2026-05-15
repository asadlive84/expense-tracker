import { useState, useRef, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useQueryClient } from '@tanstack/react-query';
import { useTransactions, useDeleteTransaction } from '../hooks/useTransactions';
import { useBuckets } from '../hooks/useBuckets';
import { usePeople } from '../hooks/usePeople';
import { useTags } from '../hooks/useTags';
import { TransactionForm } from '../components/TransactionForm';
import { PageHeader } from '../components/layout/PageHeader';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { SkeletonRow } from '../components/ui/Skeletons';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { formatBDT } from '../utils/money';
import { formatDate } from '../utils/date';
import * as txApi from '../api/transactions';
import {
  Plus,
  Pencil,
  Trash2,
  ArrowUpRight,
  ArrowDownLeft,
  ArrowLeftRight,
  Handshake,
  Filter,
  X,
} from 'lucide-react';
import type { Transaction, TransactionType, TransactionFilters } from '../types';

const TRANSACTION_TYPES: { value: TransactionType | ''; label: string }[] = [
  { value: '', label: 'All Types' },
  { value: 'expense', label: 'Expense' },
  { value: 'income', label: 'Income' },
  { value: 'transfer', label: 'Transfer' },
  { value: 'loan_given', label: 'Loan Given' },
  { value: 'loan_taken', label: 'Loan Taken' },
  { value: 'repayment_received', label: 'Repayment In' },
  { value: 'repayment_paid', label: 'Repayment Out' },
];

const typeIcons: Record<TransactionType, React.ReactNode> = {
  expense: <ArrowUpRight size={16} className="text-red-400" />,
  income: <ArrowDownLeft size={16} className="text-emerald-400" />,
  transfer: <ArrowLeftRight size={16} className="text-blue-400" />,
  loan_given: <Handshake size={16} className="text-orange-400" />,
  loan_taken: <Handshake size={16} className="text-orange-400" />,
  repayment_received: <ArrowDownLeft size={16} className="text-purple-400" />,
  repayment_paid: <ArrowUpRight size={16} className="text-purple-400" />,
};

const typeBgColors: Record<TransactionType, string> = {
  expense: 'bg-red-500/10',
  income: 'bg-emerald-500/10',
  transfer: 'bg-blue-500/10',
  loan_given: 'bg-orange-500/10',
  loan_taken: 'bg-orange-500/10',
  repayment_received: 'bg-purple-500/10',
  repayment_paid: 'bg-purple-500/10',
};

const amountColor = (type: TransactionType) => {
  if (['expense', 'loan_given', 'repayment_paid'].includes(type)) return 'text-red-400';
  if (['income', 'loan_taken', 'repayment_received'].includes(type)) return 'text-emerald-400';
  return 'text-blue-400';
};

const tagBadgeColor = (type: TransactionType) => {
  if (['expense', 'loan_given', 'repayment_paid'].includes(type)) return 'red' as const;
  if (['income', 'loan_taken', 'repayment_received'].includes(type)) return 'green' as const;
  return 'blue' as const;
};

export default function TransactionsPage() {
  const queryClient = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editTx, setEditTx] = useState<Transaction | null>(null);
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<TransactionFilters>({ limit: 50 });

  const { data: bucketsData } = useBuckets();
  const { data: peopleData } = usePeople();
  const { data: tagsData } = useTags();
  const deleteMutation = useDeleteTransaction();

  const {
    data,
    isLoading,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useTransactions(filters);

  const allTransactions = data?.pages.flatMap((p) => p.items) ?? [];

  // Infinite scroll sentinel
  const sentinelRef = useRef<HTMLDivElement>(null);
  const observerCallback = useCallback(
    (entries: IntersectionObserverEntry[]) => {
      if (entries[0].isIntersecting && hasNextPage) {
        fetchNextPage();
      }
    },
    [hasNextPage, fetchNextPage]
  );

  useEffect(() => {
    const observer = new IntersectionObserver(observerCallback, {
      rootMargin: '200px',
    });
    if (sentinelRef.current) observer.observe(sentinelRef.current);
    return () => observer.disconnect();
  }, [observerCallback]);

  const bucketOptions = [
    { value: '', label: 'All Buckets' },
    ...(bucketsData?.items ?? []).map((b) => ({ value: b.id, label: b.name })),
  ];
  const personOptions = [
    { value: '', label: 'All People' },
    ...(peopleData?.items ?? []).map((p) => ({ value: p.id, label: p.name })),
  ];
  const tagOptions = [
    { value: '', label: 'All Tags' },
    ...(tagsData?.items ?? []).map((t) => ({ value: t.id, label: t.name })),
  ];

  const handleDelete = (tx: Transaction) => {
    if (confirm('Delete this transaction? This inserts a reversal.')) {
      deleteMutation.mutate(tx.id);
    }
  };

  // Look up bucket name
  const bucketName = (id: string | null | undefined) => {
    if (!id) return '';
    return bucketsData?.items.find((b) => b.id === id)?.name ?? '';
  };

  return (
    <div className="space-y-4">
      <PageHeader
        title="Transactions"
        subtitle="All your money movements"
        action={
          <Button onClick={() => { setEditTx(null); setFormOpen(true); }}>
            <Plus size={16} /> Add
          </Button>
        }
      />

      {/* Filter bar */}
      <div className="flex items-center gap-2 flex-wrap">
        <Button
          variant={showFilters ? 'primary' : 'secondary'}
          size="sm"
          onClick={() => setShowFilters(!showFilters)}
        >
          <Filter size={14} />
          Filters
          {Object.values(filters).filter(Boolean).length > 1 && (
            <span className="ml-1 px-1.5 py-0.5 text-[10px] bg-primary-500/20 rounded-full">
              {Object.values(filters).filter(Boolean).length - 1}
            </span>
          )}
        </Button>
        {showFilters && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setFilters({ limit: 50 })}
          >
            <X size={14} /> Clear
          </Button>
        )}
      </div>

      {showFilters && (
        <motion.div
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: 'auto' }}
          exit={{ opacity: 0, height: 0 }}
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3 p-4 bg-surface-900/50 border border-surface-800 rounded-xl"
        >
          <Input
            label="From"
            type="date"
            value={filters.from ?? ''}
            onChange={(e) => setFilters((f) => ({ ...f, from: e.target.value || undefined }))}
          />
          <Input
            label="To"
            type="date"
            value={filters.to ?? ''}
            onChange={(e) => setFilters((f) => ({ ...f, to: e.target.value || undefined }))}
          />
          <Select
            label="Type"
            options={TRANSACTION_TYPES}
            value={filters.type ?? ''}
            onChange={(e) =>
              setFilters((f) => ({
                ...f,
                type: (e.target.value as TransactionType) || undefined,
              }))
            }
          />
          <Select
            label="Bucket"
            options={bucketOptions}
            value={filters.bucket_id ?? ''}
            onChange={(e) =>
              setFilters((f) => ({ ...f, bucket_id: e.target.value || undefined }))
            }
          />
          <Select
            label="Person"
            options={personOptions}
            value={filters.person_id ?? ''}
            onChange={(e) =>
              setFilters((f) => ({ ...f, person_id: e.target.value || undefined }))
            }
          />
          <Select
            label="Tag"
            options={tagOptions}
            value={filters.tag_id ?? ''}
            onChange={(e) =>
              setFilters((f) => ({ ...f, tag_id: e.target.value || undefined }))
            }
          />
        </motion.div>
      )}

      {/* Transaction List */}
      <div className="bg-surface-900/50 border border-surface-800 rounded-2xl overflow-hidden">
        {isLoading ? (
          <div>
            {Array.from({ length: 8 }).map((_, i) => (
              <SkeletonRow key={i} />
            ))}
          </div>
        ) : allTransactions.length === 0 ? (
          <div className="p-12 text-center text-surface-500">
            <p className="text-lg mb-2">No transactions found</p>
            <p className="text-sm">Try adjusting your filters or create a new transaction.</p>
          </div>
        ) : (
          <>
            <AnimatePresence initial={false}>
              {allTransactions.map((tx) => (
                <motion.div
                  key={tx.id}
                  layout
                  initial={{ opacity: 0, y: -8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, x: 40, height: 0 }}
                  transition={{ duration: 0.15 }}
                >
                  <div
                    className="flex items-center gap-3 px-5 py-3.5 hover:bg-surface-800/30 transition-colors border-b border-surface-800/50 last:border-0 group"
                    onMouseEnter={() => {
                      queryClient.prefetchQuery({
                        queryKey: ['transaction', tx.id],
                        queryFn: () => txApi.listTransactions({ limit: 1 }),
                        staleTime: 30_000,
                      });
                    }}
                  >
                    {/* Type icon */}
                    <div className={`w-9 h-9 rounded-full ${typeBgColors[tx.type]} flex items-center justify-center shrink-0`}>
                      {typeIcons[tx.type]}
                    </div>

                    {/* Content */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-surface-200 truncate">
                          {tx.note || tx.type.replace(/_/g, ' ')}
                        </p>
                        {tx.tags.map((tag) => (
                          <Badge key={tag.id} color={tagBadgeColor(tx.type)}>
                            {tag.name}
                          </Badge>
                        ))}
                      </div>
                      <p className="text-xs text-surface-500">
                        {formatDate(tx.occurred_at)}
                        {tx.from_bucket_id && ` · ${bucketName(tx.from_bucket_id)}`}
                        {tx.to_bucket_id && ` → ${bucketName(tx.to_bucket_id)}`}
                      </p>
                    </div>

                    {/* Amount */}
                    <span className={`text-sm font-semibold ${amountColor(tx.type)} whitespace-nowrap`}>
                      {['expense', 'loan_given', 'repayment_paid'].includes(tx.type) ? '-' : '+'}
                      {formatBDT(tx.amount_paisa)}
                    </span>

                    {/* Actions */}
                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => { setEditTx(tx); setFormOpen(true); }}
                        className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-primary-400 transition-colors cursor-pointer"
                      >
                        <Pencil size={14} />
                      </button>
                      <button
                        onClick={() => handleDelete(tx)}
                        className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-red-400 transition-colors cursor-pointer"
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>

            {/* Sentinel for infinite scroll */}
            <div ref={sentinelRef} className="h-1" />

            {isFetchingNextPage && (
              <div>
                {Array.from({ length: 3 }).map((_, i) => (
                  <SkeletonRow key={i} />
                ))}
              </div>
            )}
          </>
        )}
      </div>

      <TransactionForm
        open={formOpen}
        onClose={() => { setFormOpen(false); setEditTx(null); }}
        transaction={editTx}
      />
    </div>
  );
}
