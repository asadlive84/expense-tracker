import { useQuery } from '@tanstack/react-query';
import { getBucketBalances, getMonthlySummary } from '../api/reports';
import { listTransactions } from '../api/transactions';
import { listReminders } from '../api/reminders';
import { formatBDT } from '../utils/money';
import { formatDate, formatRelative, getCurrentMonth } from '../utils/date';
import { SkeletonStatCard, SkeletonRow } from '../components/ui/Skeletons';
import { PageHeader } from '../components/layout/PageHeader';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { TransactionForm } from '../components/TransactionForm';
import { useSkipReminder } from '../hooks/useReminders';
import { PayModal } from '../components/PayModal';
import {
  TrendingUp,
  TrendingDown,
  Wallet,
  Activity,
  ArrowUpRight,
  ArrowDownLeft,
  ArrowLeftRight,
  Handshake,
  Clock,
  Plus,
} from 'lucide-react';
import { addDays, format } from 'date-fns';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import type { Transaction, TransactionType, Reminder } from '../types';

const typeIcons: Record<TransactionType, React.ReactNode> = {
  expense: <ArrowUpRight size={16} className="text-red-400" />,
  income: <ArrowDownLeft size={16} className="text-emerald-400" />,
  transfer: <ArrowLeftRight size={16} className="text-blue-400" />,
  loan_given: <Handshake size={16} className="text-orange-400" />,
  loan_taken: <Handshake size={16} className="text-orange-400" />,
  repayment_received: <ArrowDownLeft size={16} className="text-purple-400" />,
  repayment_paid: <ArrowUpRight size={16} className="text-purple-400" />,
};

const amountColor = (type: TransactionType) => {
  if (['expense', 'loan_given', 'repayment_paid'].includes(type)) return 'text-red-400';
  if (['income', 'loan_taken', 'repayment_received'].includes(type)) return 'text-emerald-400';
  return 'text-blue-400';
};

export default function DashboardPage() {
  const [txFormOpen, setTxFormOpen] = useState(false);
  const [editTx, setEditTx] = useState<Transaction | null>(null);
  const [payModalReminder, setPayModalReminder] = useState<Reminder | null>(null);
  const skipMutation = useSkipReminder();

  const currentMonth = getCurrentMonth();
  const sevenDaysLater = format(addDays(new Date(), 7), 'yyyy-MM-dd');

  // Fire all 4 queries in parallel
  const { data: balances, isLoading: balancesLoading } = useQuery({
    queryKey: ['reports', 'bucket-balances'],
    queryFn: getBucketBalances,
  });

  const { data: summary, isLoading: summaryLoading } = useQuery({
    queryKey: ['reports', 'summary', currentMonth],
    queryFn: () => getMonthlySummary(currentMonth),
  });

  const { data: recentTx, isLoading: txLoading } = useQuery({
    queryKey: ['transactions', { limit: 10 }],
    queryFn: () => listTransactions({ limit: 10 }),
  });

  const { data: reminders, isLoading: remindersLoading } = useQuery({
    queryKey: ['reminders', sevenDaysLater],
    queryFn: () => listReminders(sevenDaysLater),
  });

  const totalBalance = (balances?.items ?? []).reduce(
    (sum, b) => sum + b.balance_paisa,
    0
  );
  const netMonth = (summary?.income_paisa ?? 0) - (summary?.expense_paisa ?? 0);

  const statsLoading = balancesLoading || summaryLoading;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        subtitle="Your financial overview"
        action={
          <Button onClick={() => { setEditTx(null); setTxFormOpen(true); }} size="md">
            <Plus size={16} /> New Transaction
          </Button>
        }
      />

      {/* Stats cards */}
      {statsLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <SkeletonStatCard key={i} />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard
            icon={<Wallet size={20} />}
            label="Total Balance"
            value={formatBDT(totalBalance)}
            iconBg="bg-primary-500/15 text-primary-400"
          />
          <StatCard
            icon={<TrendingUp size={20} />}
            label="Income (this month)"
            value={formatBDT(summary?.income_paisa ?? 0)}
            iconBg="bg-emerald-500/15 text-emerald-400"
          />
          <StatCard
            icon={<TrendingDown size={20} />}
            label="Expenses (this month)"
            value={formatBDT(summary?.expense_paisa ?? 0)}
            iconBg="bg-red-500/15 text-red-400"
          />
          <StatCard
            icon={<Activity size={20} />}
            label="Net (this month)"
            value={formatBDT(netMonth)}
            iconBg={netMonth >= 0 ? 'bg-emerald-500/15 text-emerald-400' : 'bg-red-500/15 text-red-400'}
            valueClass={netMonth >= 0 ? 'text-emerald-400' : 'text-red-400'}
          />
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Transactions */}
        <div className="lg:col-span-2 bg-surface-900/50 border border-surface-800 rounded-2xl overflow-hidden">
          <div className="px-5 py-4 border-b border-surface-800">
            <h2 className="text-base font-semibold text-surface-100">Recent Transactions</h2>
          </div>
          {txLoading ? (
            <div>{Array.from({ length: 6 }).map((_, i) => <SkeletonRow key={i} />)}</div>
          ) : (recentTx?.items ?? []).length === 0 ? (
            <div className="p-8 text-center text-surface-500 text-sm">
              No transactions yet. Create your first one!
            </div>
          ) : (
            <AnimatePresence initial={false}>
              {(recentTx?.items ?? []).map((tx) => (
                <motion.div
                  key={tx.id}
                  layout
                  initial={{ opacity: 0, y: -8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, x: 40, height: 0 }}
                  transition={{ duration: 0.15 }}
                >
                  <button
                    onClick={() => { setEditTx(tx); setTxFormOpen(true); }}
                    className="w-full flex items-center gap-3 px-5 py-3.5 hover:bg-surface-800/50 transition-colors text-left cursor-pointer"
                  >
                    <div className="w-9 h-9 rounded-full bg-surface-800 flex items-center justify-center shrink-0">
                      {typeIcons[tx.type]}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-surface-200 truncate">
                        {tx.note || tx.type.replace('_', ' ')}
                      </p>
                      <p className="text-xs text-surface-500">{formatDate(tx.occurred_at)}</p>
                    </div>
                    <span className={`text-sm font-semibold ${amountColor(tx.type)}`}>
                      {['expense', 'loan_given', 'repayment_paid'].includes(tx.type) ? '-' : '+'}
                      {formatBDT(tx.amount_paisa)}
                    </span>
                  </button>
                </motion.div>
              ))}
            </AnimatePresence>
          )}
        </div>

        {/* Upcoming Reminders */}
        <div className="bg-surface-900/50 border border-surface-800 rounded-2xl overflow-hidden">
          <div className="px-5 py-4 border-b border-surface-800 flex items-center gap-2">
            <Clock size={16} className="text-surface-400" />
            <h2 className="text-base font-semibold text-surface-100">Upcoming</h2>
          </div>
          {remindersLoading ? (
            <div>{Array.from({ length: 3 }).map((_, i) => <SkeletonRow key={i} />)}</div>
          ) : (reminders?.items ?? []).length === 0 ? (
            <div className="p-8 text-center text-surface-500 text-sm">
              No upcoming reminders
            </div>
          ) : (
            <AnimatePresence initial={false}>
              {(reminders?.items ?? []).map((r) => (
                <motion.div
                  key={r.id}
                  layout
                  initial={{ opacity: 0, y: -8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, x: 40, height: 0 }}
                  transition={{ duration: 0.15 }}
                  className="px-5 py-3.5 border-b border-surface-800/50 last:border-0"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <p className="text-sm font-medium text-surface-200">{r.title}</p>
                      <p className="text-xs text-surface-500">
                        {r.amount_paisa ? formatBDT(r.amount_paisa) : 'Amount not set'} ·{' '}
                        {formatRelative(r.next_due_at)}
                      </p>
                    </div>
                    <Badge
                      color={r.recurrence_type === 'none' ? 'neutral' : 'blue'}
                    >
                      {r.recurrence_type}
                    </Badge>
                  </div>
                  <div className="flex gap-2">
                    <Button
                      size="sm"
                      onClick={() => setPayModalReminder(r)}
                    >
                      Pay
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      loading={skipMutation.isPending}
                      onClick={() => {
                        if (confirm('Skip this reminder?')) {
                          skipMutation.mutate(r.id);
                        }
                      }}
                    >
                      Skip
                    </Button>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>
          )}
        </div>
      </div>

      <TransactionForm
        open={txFormOpen}
        onClose={() => { setTxFormOpen(false); setEditTx(null); }}
        transaction={editTx}
      />

      <PayModal
        open={!!payModalReminder}
        onClose={() => setPayModalReminder(null)}
        reminder={payModalReminder}
      />
    </div>
  );
}

function StatCard({
  icon,
  label,
  value,
  iconBg,
  valueClass = 'text-surface-50',
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  iconBg: string;
  valueClass?: string;
}) {
  return (
    <div className="p-5 rounded-2xl bg-surface-900/50 border border-surface-800 hover:border-surface-700 transition-colors">
      <div className="flex items-center gap-3 mb-3">
        <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${iconBg}`}>
          {icon}
        </div>
        <span className="text-xs font-medium text-surface-400 uppercase tracking-wider">
          {label}
        </span>
      </div>
      <p className={`text-xl font-bold ${valueClass}`}>{value}</p>
    </div>
  );
}
