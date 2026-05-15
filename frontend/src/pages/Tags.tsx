import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { motion, AnimatePresence } from 'framer-motion';
import { useTags, useCreateTag, useUpdateTag } from '../hooks/useTags';
import { getTagTotals } from '../api/reports';
import { PageHeader } from '../components/layout/PageHeader';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Drawer } from '../components/ui/Drawer';
import { SkeletonRow } from '../components/ui/Skeletons';
import { formatBDT } from '../utils/money';
import { getMonthStart, getMonthEnd } from '../utils/date';
import { Plus, Pencil, Archive, ArchiveRestore, ChevronDown, Tags as TagsIcon } from 'lucide-react';

export default function TagsPage() {
  const { data: tagsData, isLoading } = useTags();
  const from = getMonthStart();
  const to = getMonthEnd();
  const { data: totalsData } = useQuery({
    queryKey: ['reports', 'tag-totals', from, to],
    queryFn: () => getTagTotals(from, to),
  });
  const createMutation = useCreateTag();
  const updateMutation = useUpdateTag();

  const [formOpen, setFormOpen] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [editName, setEditName] = useState('');
  const [newName, setNewName] = useState('');
  const [showArchived, setShowArchived] = useState(false);

  const tags = tagsData?.items ?? [];
  const active = tags.filter((t) => !t.archived_at);
  const archived = tags.filter((t) => t.archived_at);

  const getTotal = (id: string) => totalsData?.items.find((t) => t.tag_id === id)?.total_paisa ?? 0;

  const handleCreate = () => {
    if (!newName.trim()) return;
    createMutation.mutate({ name: newName.trim() }, { onSuccess: () => { setNewName(''); setFormOpen(false); } });
  };

  const handleRename = (id: string) => {
    if (!editName.trim()) return;
    updateMutation.mutate({ id, data: { name: editName.trim() } }, { onSuccess: () => setEditId(null) });
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Tags" subtitle="Categorize your spending" action={<Button onClick={() => setFormOpen(true)}><Plus size={16} /> Add Tag</Button>} />

      <div className="bg-surface-900/50 border border-surface-800 rounded-2xl overflow-hidden">
        {isLoading ? (
          <div>{Array.from({ length: 5 }).map((_, i) => <SkeletonRow key={i} />)}</div>
        ) : active.length === 0 ? (
          <div className="p-12 text-center text-surface-500"><TagsIcon size={48} className="mx-auto mb-4 opacity-30" /><p>No tags yet.</p></div>
        ) : (
          <AnimatePresence initial={false}>
            {active.map((tag) => (
              <motion.div key={tag.id} layout initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, x: 40, height: 0 }} transition={{ duration: 0.15 }}
                className="flex items-center gap-3 px-5 py-4 border-b border-surface-800/50 last:border-0 hover:bg-surface-800/30 transition-colors group"
              >
                {editId === tag.id ? (
                  <div className="flex-1 flex gap-2 items-center">
                    <Input value={editName} onChange={(e) => setEditName(e.target.value)} className="flex-1" autoFocus onKeyDown={(e) => { if (e.key === 'Enter') handleRename(tag.id); if (e.key === 'Escape') setEditId(null); }} />
                    <Button size="sm" onClick={() => handleRename(tag.id)} loading={updateMutation.isPending}>Save</Button>
                    <Button size="sm" variant="ghost" onClick={() => setEditId(null)}>Cancel</Button>
                  </div>
                ) : (
                  <>
                    <div className="w-8 h-8 rounded-lg bg-primary-500/10 flex items-center justify-center text-primary-400 text-sm font-bold">#</div>
                    <div className="flex-1"><p className="text-sm font-medium text-surface-200">{tag.name}</p><p className="text-xs text-surface-500">This month: {formatBDT(getTotal(tag.id))}</p></div>
                    <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button onClick={() => { setEditId(tag.id); setEditName(tag.name); }} className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-primary-400 transition-colors cursor-pointer"><Pencil size={14} /></button>
                      <button onClick={() => { if (confirm(`Archive "${tag.name}"?`)) updateMutation.mutate({ id: tag.id, data: { archived: true } }); }} className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-amber-400 transition-colors cursor-pointer"><Archive size={14} /></button>
                    </div>
                  </>
                )}
              </motion.div>
            ))}
          </AnimatePresence>
        )}
      </div>

      {archived.length > 0 && (
        <div>
          <button onClick={() => setShowArchived(!showArchived)} className="flex items-center gap-2 text-sm text-surface-400 hover:text-surface-300 transition-colors cursor-pointer">
            <ChevronDown size={16} className={`transition-transform ${showArchived ? 'rotate-180' : ''}`} /> Archived ({archived.length})
          </button>
          {showArchived && (
            <div className="bg-surface-900/30 border border-surface-800/50 rounded-xl mt-3 overflow-hidden">
              {archived.map((t) => (
                <div key={t.id} className="flex items-center justify-between px-5 py-3 border-b border-surface-800/50 last:border-0 opacity-60">
                  <span className="text-surface-300">{t.name}</span>
                  <Button size="sm" variant="ghost" onClick={() => updateMutation.mutate({ id: t.id, data: { archived: false } })}><ArchiveRestore size={14} /> Unarchive</Button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      <Drawer open={formOpen} onClose={() => setFormOpen(false)} title="New Tag">
        <div className="space-y-4">
          <Input label="Name" placeholder="e.g. food, transport" value={newName} onChange={(e) => setNewName(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter') handleCreate(); }} />
          <div className="flex gap-3"><Button onClick={handleCreate} loading={createMutation.isPending}>Create</Button><Button variant="secondary" onClick={() => setFormOpen(false)}>Cancel</Button></div>
        </div>
      </Drawer>
    </div>
  );
}
