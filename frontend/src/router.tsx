import { createBrowserRouter, Navigate, Outlet } from 'react-router-dom';
import { Sidebar } from './components/layout/Sidebar';
import { BottomNav } from './components/layout/BottomNav';
import { GlobalProgressBar } from './components/ui/GlobalProgressBar';
import LoginPage from './pages/Login';
import RegisterPage from './pages/Register';
import DashboardPage from './pages/Dashboard';
import TransactionsPage from './pages/Transactions';
import BucketsPage from './pages/Buckets';
import PeoplePage from './pages/People';
import TagsPage from './pages/Tags';
import ReportsPage from './pages/Reports';
import RemindersPage from './pages/Reminders';

function ProtectedLayout() {
  const token = localStorage.getItem('et_token');
  if (!token) return <Navigate to="/login" replace />;

  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <main className="flex-1 overflow-y-auto pb-20 md:pb-0">
        <GlobalProgressBar />
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <Outlet />
        </div>
      </main>
      <BottomNav />
    </div>
  );
}

function PublicRoute() {
  const token = localStorage.getItem('et_token');
  if (token) return <Navigate to="/" replace />;
  return <Outlet />;
}

export const router = createBrowserRouter([
  {
    element: <PublicRoute />,
    children: [
      { path: '/login', element: <LoginPage /> },
      { path: '/register', element: <RegisterPage /> },
    ],
  },
  {
    element: <ProtectedLayout />,
    children: [
      { path: '/', element: <DashboardPage /> },
      { path: '/transactions', element: <TransactionsPage /> },
      { path: '/buckets', element: <BucketsPage /> },
      { path: '/people', element: <PeoplePage /> },
      { path: '/tags', element: <TagsPage /> },
      { path: '/reports', element: <ReportsPage /> },
      { path: '/reminders', element: <RemindersPage /> },
    ],
  },
  { path: '*', element: <Navigate to="/" replace /> },
]);
