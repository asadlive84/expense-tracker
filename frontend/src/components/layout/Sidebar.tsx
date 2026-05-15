import { NavLink, useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import {
  LayoutDashboard,
  ArrowLeftRight,
  Wallet,
  Users,
  Tags,
  BarChart3,
  Bell,
  LogOut,
} from 'lucide-react';
import * as api from '../../api/transactions';
import * as bucketsApi from '../../api/buckets';
import * as peopleApi from '../../api/people';
import * as tagsApi from '../../api/tags';
import * as reportsApi from '../../api/reports';
import * as remindersApi from '../../api/reminders';
import { getCurrentMonth, getMonthStart, getMonthEnd } from '../../utils/date';

const navItems = [
  { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/transactions', icon: ArrowLeftRight, label: 'Transactions' },
  { to: '/buckets', icon: Wallet, label: 'Buckets' },
  { to: '/people', icon: Users, label: 'People' },
  { to: '/tags', icon: Tags, label: 'Tags' },
  { to: '/reports', icon: BarChart3, label: 'Reports' },
  { to: '/reminders', icon: Bell, label: 'Reminders' },
];

export function Sidebar() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const handleLogout = () => {
    localStorage.removeItem('et_token');
    navigate('/login');
  };

  const prefetchMap: Record<string, () => void> = {
    '/': () => {
      queryClient.prefetchQuery({ queryKey: ['reports', 'bucket-balances'], queryFn: reportsApi.getBucketBalances });
      queryClient.prefetchQuery({ queryKey: ['reports', 'summary', getCurrentMonth()], queryFn: () => reportsApi.getMonthlySummary(getCurrentMonth()) });
      queryClient.prefetchQuery({ queryKey: ['transactions', { limit: 10 }], queryFn: () => api.listTransactions({ limit: 10 }) });
    },
    '/transactions': () => {
      queryClient.prefetchQuery({ queryKey: ['transactions', {}], queryFn: () => api.listTransactions({}) });
    },
    '/buckets': () => {
      queryClient.prefetchQuery({ queryKey: ['buckets'], queryFn: bucketsApi.listBuckets });
      queryClient.prefetchQuery({ queryKey: ['reports', 'bucket-balances'], queryFn: reportsApi.getBucketBalances });
    },
    '/people': () => {
      queryClient.prefetchQuery({ queryKey: ['people'], queryFn: peopleApi.listPeople });
      queryClient.prefetchQuery({ queryKey: ['reports', 'person-balances'], queryFn: reportsApi.getPersonBalances });
    },
    '/tags': () => {
      queryClient.prefetchQuery({ queryKey: ['tags'], queryFn: tagsApi.listTags });
      queryClient.prefetchQuery({
        queryKey: ['reports', 'tag-totals', getMonthStart(), getMonthEnd()],
        queryFn: () => reportsApi.getTagTotals(getMonthStart(), getMonthEnd()),
      });
    },
    '/reports': () => {
      queryClient.prefetchQuery({ queryKey: ['reports', 'bucket-balances'], queryFn: reportsApi.getBucketBalances });
      queryClient.prefetchQuery({ queryKey: ['reports', 'person-balances'], queryFn: reportsApi.getPersonBalances });
    },
    '/reminders': () => {
      queryClient.prefetchQuery({ queryKey: ['reminders', undefined], queryFn: () => remindersApi.listReminders() });
    },
  };

  return (
    <aside className="hidden md:flex flex-col w-64 bg-surface-900/50 border-r border-surface-800/50 backdrop-blur-xl">
      {/* Logo */}
      <div className="px-6 py-5 border-b border-surface-800/50">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-primary-500 to-primary-700 flex items-center justify-center shadow-lg shadow-primary-600/20">
            <Wallet size={18} className="text-white" />
          </div>
          <div>
            <h1 className="text-base font-bold text-surface-100">ExpenseTracker</h1>
            <p className="text-xs text-surface-500">Personal Finance</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-1">
        {navItems.map(({ to, icon: Icon, label }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            onMouseEnter={() => prefetchMap[to]?.()}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-150
              ${
                isActive
                  ? 'bg-primary-600/15 text-primary-400 shadow-sm'
                  : 'text-surface-400 hover:text-surface-200 hover:bg-surface-800/50'
              }`
            }
          >
            <Icon size={18} />
            <span>{label}</span>
          </NavLink>
        ))}
      </nav>

      {/* Logout */}
      <div className="px-3 py-4 border-t border-surface-800/50">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-surface-400 hover:text-red-400 hover:bg-red-500/10 transition-all duration-150 w-full cursor-pointer"
        >
          <LogOut size={18} />
          <span>Log out</span>
        </button>
      </div>
    </aside>
  );
}
