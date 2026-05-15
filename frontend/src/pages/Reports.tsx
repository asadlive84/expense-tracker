import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { getBucketBalances, getPersonBalances, getTagTotals, getMonthlySummary } from '../api/reports';
import { PageHeader } from '../components/layout/PageHeader';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Badge } from '../components/ui/Badge';
import { SkeletonChart, SkeletonStatCard } from '../components/ui/Skeletons';
import { formatBDT } from '../utils/money';
import { getCurrentMonth, getMonthStart, getMonthEnd } from '../utils/date';
import { RefreshCw, TrendingUp, TrendingDown, Activity } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import { useQueryClient } from '@tanstack/react-query';

const COLORS = ['#6366f1', '#8b5cf6', '#a78bfa', '#c4b5fd', '#818cf8', '#4f46e5', '#7c3aed', '#6d28d9'];

export default function ReportsPage() {
  const queryClient = useQueryClient();
  const [tagFrom, setTagFrom] = useState(getMonthStart());
  const [tagTo, setTagTo] = useState(getMonthEnd());
  const [summaryMonth, setSummaryMonth] = useState(getCurrentMonth());

  const { data: bucketBal, isLoading: bL } = useQuery({ queryKey: ['reports', 'bucket-balances'], queryFn: getBucketBalances });
  const { data: personBal, isLoading: pL } = useQuery({ queryKey: ['reports', 'person-balances'], queryFn: getPersonBalances });
  const { data: tagTotals, isLoading: tL } = useQuery({ queryKey: ['reports', 'tag-totals', tagFrom, tagTo], queryFn: () => getTagTotals(tagFrom, tagTo) });
  const { data: summary, isLoading: sL } = useQuery({ queryKey: ['reports', 'summary', summaryMonth], queryFn: () => getMonthlySummary(summaryMonth) });

  const refreshAll = () => queryClient.invalidateQueries({ queryKey: ['reports'] });

  const bucketChartData = (bucketBal?.items ?? []).map((b) => ({ name: b.name, balance: b.balance_paisa / 100 }));
  const tagChartData = (tagTotals?.items ?? []).map((t) => ({ name: t.name, total: t.total_paisa / 100 }));
  const summaryBarData = summary?.by_tag?.map((t) => ({ name: t.name, total: t.total_paisa / 100 })) ?? [];

  return (
    <div className="space-y-8">
      <PageHeader title="Reports" subtitle="Financial insights" action={<Button variant="secondary" onClick={refreshAll}><RefreshCw size={14} /> Refresh All</Button>} />

      {/* Bucket Balances */}
      <section className="bg-surface-900/50 border border-surface-800 rounded-2xl p-5">
        <h2 className="text-base font-semibold text-surface-100 mb-4">Bucket Balances</h2>
        {bL ? <SkeletonChart /> : bucketChartData.length === 0 ? <p className="text-surface-500 text-sm">No data</p> : (
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={bucketChartData} layout="vertical" margin={{ left: 60 }}>
              <XAxis type="number" tick={{ fill: '#94a3b8', fontSize: 12 }} tickFormatter={(v: number) => `৳${v}`} />
              <YAxis dataKey="name" type="category" tick={{ fill: '#cbd5e1', fontSize: 12 }} width={80} />
              <Tooltip formatter={(v) => `৳${Number(v).toFixed(2)}`} contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: 8, color: '#e2e8f0' }} />
              <Bar dataKey="balance" radius={[0, 6, 6, 0]}>
                {bucketChartData.map((entry, i) => (
                  <Cell key={i} fill={entry.balance >= 0 ? '#10b981' : '#ef4444'} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        )}
      </section>

      {/* Person Balances */}
      <section className="bg-surface-900/50 border border-surface-800 rounded-2xl p-5">
        <h2 className="text-base font-semibold text-surface-100 mb-4">Person Balances</h2>
        {pL ? <SkeletonChart /> : (personBal?.items ?? []).length === 0 ? <p className="text-surface-500 text-sm">No data</p> : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="border-b border-surface-800"><th className="text-left py-2 px-3 text-surface-400 font-medium">Name</th><th className="text-right py-2 px-3 text-surface-400 font-medium">Balance</th><th className="text-right py-2 px-3 text-surface-400 font-medium">Status</th></tr></thead>
              <tbody>
                {(personBal?.items ?? []).map((p) => (
                  <tr key={p.person_id} className={`border-b border-surface-800/50 ${p.net_paisa > 0 ? 'bg-emerald-500/5' : p.net_paisa < 0 ? 'bg-red-500/5' : ''}`}>
                    <td className="py-3 px-3 text-surface-200">{p.name}</td>
                    <td className={`py-3 px-3 text-right font-semibold ${p.net_paisa > 0 ? 'text-emerald-400' : p.net_paisa < 0 ? 'text-red-400' : 'text-surface-400'}`}>{formatBDT(Math.abs(p.net_paisa))}</td>
                    <td className="py-3 px-3 text-right"><Badge color={p.net_paisa > 0 ? 'green' : p.net_paisa < 0 ? 'red' : 'neutral'}>{p.net_paisa > 0 ? 'Owes you' : p.net_paisa < 0 ? 'You owe' : 'Settled'}</Badge></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* Tag Totals */}
      <section className="bg-surface-900/50 border border-surface-800 rounded-2xl p-5">
        <div className="flex items-center justify-between mb-4 flex-wrap gap-3">
          <h2 className="text-base font-semibold text-surface-100">Tag Totals</h2>
          <div className="flex gap-2">
            <Input type="date" value={tagFrom} onChange={(e) => setTagFrom(e.target.value)} className="w-36 text-xs" />
            <Input type="date" value={tagTo} onChange={(e) => setTagTo(e.target.value)} className="w-36 text-xs" />
          </div>
        </div>
        {tL ? <SkeletonChart /> : tagChartData.length === 0 ? <p className="text-surface-500 text-sm">No data</p> : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie data={tagChartData} dataKey="total" nameKey="name" cx="50%" cy="50%" outerRadius={90} innerRadius={50} paddingAngle={3}>
                  {tagChartData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Tooltip formatter={(v) => `৳${Number(v).toFixed(2)}`} contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: 8, color: '#e2e8f0' }} />
              </PieChart>
            </ResponsiveContainer>
            <div className="space-y-2">
              {(tagTotals?.items ?? []).sort((a, b) => b.total_paisa - a.total_paisa).map((t, i) => (
                <div key={t.tag_id} className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: COLORS[i % COLORS.length] }} />
                  <span className="flex-1 text-sm text-surface-300">{t.name}</span>
                  <span className="text-sm font-medium text-surface-200">{formatBDT(t.total_paisa)}</span>
                </div>
              ))}
            </div>
          </div>
        )}
      </section>

      {/* Monthly Summary */}
      <section className="bg-surface-900/50 border border-surface-800 rounded-2xl p-5">
        <div className="flex items-center justify-between mb-4 flex-wrap gap-3">
          <h2 className="text-base font-semibold text-surface-100">Monthly Summary</h2>
          <Input type="month" value={summaryMonth} onChange={(e) => setSummaryMonth(e.target.value)} className="w-40 text-xs" />
        </div>
        {sL ? (
          <div className="grid grid-cols-3 gap-4">{Array.from({ length: 3 }).map((_, i) => <SkeletonStatCard key={i} />)}</div>
        ) : (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
              <div className="p-4 rounded-xl bg-emerald-500/5 border border-emerald-500/10"><div className="flex items-center gap-2 text-xs text-emerald-400 mb-1"><TrendingUp size={14} />Income</div><p className="text-lg font-bold text-emerald-400">{formatBDT(summary?.income_paisa ?? 0)}</p></div>
              <div className="p-4 rounded-xl bg-red-500/5 border border-red-500/10"><div className="flex items-center gap-2 text-xs text-red-400 mb-1"><TrendingDown size={14} />Expense</div><p className="text-lg font-bold text-red-400">{formatBDT(summary?.expense_paisa ?? 0)}</p></div>
              <div className="p-4 rounded-xl bg-primary-500/5 border border-primary-500/10"><div className="flex items-center gap-2 text-xs text-primary-400 mb-1"><Activity size={14} />Net</div><p className={`text-lg font-bold ${(summary?.net_paisa ?? 0) >= 0 ? 'text-emerald-400' : 'text-red-400'}`}>{formatBDT(summary?.net_paisa ?? 0)}</p></div>
            </div>
            {summaryBarData.length > 0 && (
              <ResponsiveContainer width="100%" height={200}>
                <BarChart data={summaryBarData}>
                  <XAxis dataKey="name" tick={{ fill: '#94a3b8', fontSize: 11 }} />
                  <YAxis tick={{ fill: '#94a3b8', fontSize: 11 }} tickFormatter={(v: number) => `৳${v}`} />
                  <Tooltip formatter={(v) => `৳${Number(v).toFixed(2)}`} contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: 8, color: '#e2e8f0' }} />
                  <Bar dataKey="total" fill="#6366f1" radius={[6, 6, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </>
        )}
      </section>
    </div>
  );
}
