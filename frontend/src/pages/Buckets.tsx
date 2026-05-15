import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { motion, AnimatePresence } from 'framer-motion';
import { useBuckets, useCreateBucket, useUpdateBucket } from '../hooks/useBuckets';
import { getBucketBalances } from '../api/reports';
import { PageHeader } from '../components/layout/PageHeader';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Drawer } from '../components/ui/Drawer';
import { SkeletonCard } from '../components/ui/Skeletons';
import { formatBDT } from '../utils/money';
import { formatDate } from '../utils/date';
import { Plus, Pencil, Archive, ArchiveRestore, ChevronDown, Wallet } from 'lucide-react';

export default function BucketsPage() {
  const { data: bucketsData, isLoading } = useBuckets();
  const { data: balancesData } = useQuery({
    queryKey: ['reports', 'bucket-balances'],
    queryFn: getBucketBalances,
  });
  const createMutation = useCreateBucket();
  const updateMutation = useUpdateBucket();

  const [formOpen, setFormOpen] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [editName, setEditName] = useState('');
  const [newName, setNewName] = useState('');
  const [newBalance, setNewBalance] = useState('');
  const [showArchived, setShowArchived] = useState(false);

  const buckets = bucketsData?.items ?? [];
  const activeBuckets = buckets.filter((b) => !b.archived_at);
  const archivedBuckets = buckets.filter((b) => b.archived_at);

  const getBalance = (bucketId: string) =>
    balancesData?.items.find((b) => b.bucket_id === bucketId)?.balance_paisa ?? 0;

  const handleCreate = () => {
    if (!newName.trim()) return;
    const paisa = newBalance ? Math.round(parseFloat(newBalance) * 100) : 0;
    createMutation.mutate(
      { name: newName.trim(), starting_balance_paisa: paisa },
      { onSuccess: () => { setNewName(''); setNewBalance(''); setFormOpen(false); } }
    );
  };

  const handleRename = (id: string) => {
    if (!editName.trim()) return;
    updateMutation.mutate(
      { id, data: { name: editName.trim() } },
      { onSuccess: () => setEditId(null) }
    );
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Buckets" subtitle="Your money containers"
        action={<Button onClick={() => setFormOpen(true)}><Plus size={16} /> Add Bucket</Button>}
      />

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 4 }).map((_, i) => <SkeletonCard key={i} />)}
        </div>
      ) : activeBuckets.length === 0 ? (
        <div className="text-center py-12 text-surface-500">
          <Wallet size={48} className="mx-auto mb-4 opacity-30" />
          <p>No buckets yet. Create your first one!</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <AnimatePresence initial={false}>
            {activeBuckets.map((bucket) => (
              <motion.div key={bucket.id} layout
                initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }} transition={{ duration: 0.15 }}
                className="p-5 rounded-2xl bg-surface-900/50 border border-surface-800 hover:border-surface-700 transition-colors group"
              >
                {editId === bucket.id ? (
                  <div className="space-y-3">
                    <Input value={editName} onChange={(e) => setEditName(e.target.value)} autoFocus
                      onKeyDown={(e) => { if (e.key === 'Enter') handleRename(bucket.id); if (e.key === 'Escape') setEditId(null); }}
                    />
                    <div className="flex gap-2">
                      <Button size="sm" onClick={() => handleRename(bucket.id)} loading={updateMutation.isPending}>Save</Button>
                      <Button size="sm" variant="ghost" onClick={() => setEditId(null)}>Cancel</Button>
                    </div>
                  </div>
                ) : (
                  <>
                    <div className="flex items-start justify-between mb-3">
                      <div>
                        <h3 className="text-base font-semibold text-surface-100">{bucket.name}</h3>
                        <p className="text-xs text-surface-500 mt-0.5">Created {formatDate(bucket.created_at)}</p>
                      </div>
                      <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button onClick={() => { setEditId(bucket.id); setEditName(bucket.name); }}
                          className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-primary-400 transition-colors cursor-pointer"><Pencil size={14} /></button>
                        <button onClick={() => { if (confirm(`Archive "${bucket.name}"?`)) updateMutation.mutate({ id: bucket.id, data: { archived: true } }); }}
                          className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-amber-400 transition-colors cursor-pointer"><Archive size={14} /></button>
                      </div>
                    </div>
                    <p className="text-2xl font-bold text-surface-50">{formatBDT(getBalance(bucket.id))}</p>
                    <p className="text-xs text-surface-500 mt-1">Starting: {formatBDT(bucket.starting_balance_paisa)}</p>
                  </>
                )}
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      )}

      {archivedBuckets.length > 0 && (
        <div>
          <button onClick={() => setShowArchived(!showArchived)}
            className="flex items-center gap-2 text-sm text-surface-400 hover:text-surface-300 transition-colors cursor-pointer">
            <ChevronDown size={16} className={`transition-transform ${showArchived ? 'rotate-180' : ''}`} />
            Archived ({archivedBuckets.length})
          </button>
          {showArchived && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mt-3">
              {archivedBuckets.map((bucket) => (
                <div key={bucket.id} className="p-5 rounded-2xl bg-surface-900/30 border border-surface-800/50 opacity-60 flex items-center justify-between">
                  <span className="text-surface-300">{bucket.name}</span>
                  <Button size="sm" variant="ghost" onClick={() => updateMutation.mutate({ id: bucket.id, data: { archived: false } })}>
                    <ArchiveRestore size={14} /> Unarchive
                  </Button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      <Drawer open={formOpen} onClose={() => setFormOpen(false)} title="New Bucket">
        <div className="space-y-4">
          <Input label="Name" placeholder="e.g. bKash, Cash, Bank" value={newName}
            onChange={(e) => setNewName(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter') handleCreate(); }} />
          <Input label="Starting Balance (BDT, optional)" type="number" step="0.01" min="0" placeholder="0.00"
            value={newBalance} onChange={(e) => setNewBalance(e.target.value)} />
          <div className="flex gap-3">
            <Button onClick={handleCreate} loading={createMutation.isPending}>Create Bucket</Button>
            <Button variant="secondary" onClick={() => setFormOpen(false)}>Cancel</Button>
          </div>
        </div>
      </Drawer>
    </div>
  );
}
