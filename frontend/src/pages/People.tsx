import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { motion, AnimatePresence } from 'framer-motion';
import { usePeople, useCreatePerson, useUpdatePerson } from '../hooks/usePeople';
import { getPersonBalances } from '../api/reports';
import { PageHeader } from '../components/layout/PageHeader';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Drawer } from '../components/ui/Drawer';
import { Badge } from '../components/ui/Badge';
import { SkeletonCard } from '../components/ui/Skeletons';
import { formatBDT } from '../utils/money';
import { Plus, Pencil, Archive, ArchiveRestore, ChevronDown, Users } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function PeoplePage() {
  const navigate = useNavigate();
  const { data: peopleData, isLoading } = usePeople();
  const { data: balancesData } = useQuery({
    queryKey: ['reports', 'person-balances'],
    queryFn: getPersonBalances,
  });
  const createMutation = useCreatePerson();
  const updateMutation = useUpdatePerson();

  const [formOpen, setFormOpen] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [editName, setEditName] = useState('');
  const [newName, setNewName] = useState('');
  const [showArchived, setShowArchived] = useState(false);

  const people = peopleData?.items ?? [];
  const active = people.filter((p) => !p.archived_at);
  const archived = people.filter((p) => p.archived_at);

  const getBalance = (id: string) => balancesData?.items.find((b) => b.person_id === id)?.net_paisa ?? 0;

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
      <PageHeader title="People" subtitle="Loan & repayment contacts" action={<Button onClick={() => setFormOpen(true)}><Plus size={16} /> Add Person</Button>} />

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">{Array.from({ length: 4 }).map((_, i) => <SkeletonCard key={i} />)}</div>
      ) : active.length === 0 ? (
        <div className="text-center py-12 text-surface-500"><Users size={48} className="mx-auto mb-4 opacity-30" /><p>No people yet.</p></div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <AnimatePresence initial={false}>
            {active.map((person) => {
              const bal = getBalance(person.id);
              return (
                <motion.div key={person.id} layout initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95 }} transition={{ duration: 0.15 }}
                  className="p-5 rounded-2xl bg-surface-900/50 border border-surface-800 hover:border-surface-700 transition-colors group cursor-pointer"
                  onClick={() => navigate(`/transactions?person_id=${person.id}`)}
                >
                  {editId === person.id ? (
                    <div className="space-y-3" onClick={(e) => e.stopPropagation()}>
                      <Input value={editName} onChange={(e) => setEditName(e.target.value)} autoFocus onKeyDown={(e) => { if (e.key === 'Enter') handleRename(person.id); if (e.key === 'Escape') setEditId(null); }} />
                      <div className="flex gap-2"><Button size="sm" onClick={() => handleRename(person.id)} loading={updateMutation.isPending}>Save</Button><Button size="sm" variant="ghost" onClick={() => setEditId(null)}>Cancel</Button></div>
                    </div>
                  ) : (
                    <>
                      <div className="flex items-start justify-between mb-3">
                        <h3 className="text-base font-semibold text-surface-100">{person.name}</h3>
                        <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity" onClick={(e) => e.stopPropagation()}>
                          <button onClick={() => { setEditId(person.id); setEditName(person.name); }} className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-primary-400 transition-colors cursor-pointer"><Pencil size={14} /></button>
                          <button onClick={() => { if (confirm(`Archive "${person.name}"?`)) updateMutation.mutate({ id: person.id, data: { archived: true } }); }} className="p-1.5 rounded-lg hover:bg-surface-700 text-surface-400 hover:text-amber-400 transition-colors cursor-pointer"><Archive size={14} /></button>
                        </div>
                      </div>
                      <p className={`text-xl font-bold ${bal > 0 ? 'text-emerald-400' : bal < 0 ? 'text-red-400' : 'text-surface-400'}`}>{formatBDT(Math.abs(bal))}</p>
                      <Badge color={bal > 0 ? 'green' : bal < 0 ? 'red' : 'neutral'} className="mt-2">
                        {bal > 0 ? 'Owes you' : bal < 0 ? 'You owe' : 'Settled'}
                      </Badge>
                    </>
                  )}
                </motion.div>
              );
            })}
          </AnimatePresence>
        </div>
      )}

      {archived.length > 0 && (
        <div>
          <button onClick={() => setShowArchived(!showArchived)} className="flex items-center gap-2 text-sm text-surface-400 hover:text-surface-300 transition-colors cursor-pointer">
            <ChevronDown size={16} className={`transition-transform ${showArchived ? 'rotate-180' : ''}`} /> Archived ({archived.length})
          </button>
          {showArchived && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mt-3">
              {archived.map((p) => (
                <div key={p.id} className="p-5 rounded-2xl bg-surface-900/30 border border-surface-800/50 opacity-60 flex items-center justify-between">
                  <span className="text-surface-300">{p.name}</span>
                  <Button size="sm" variant="ghost" onClick={() => updateMutation.mutate({ id: p.id, data: { archived: false } })}><ArchiveRestore size={14} /> Unarchive</Button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      <Drawer open={formOpen} onClose={() => setFormOpen(false)} title="New Person">
        <div className="space-y-4">
          <Input label="Name" placeholder="e.g. Karim" value={newName} onChange={(e) => setNewName(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter') handleCreate(); }} />
          <div className="flex gap-3"><Button onClick={handleCreate} loading={createMutation.isPending}>Create</Button><Button variant="secondary" onClick={() => setFormOpen(false)}>Cancel</Button></div>
        </div>
      </Drawer>
    </div>
  );
}
