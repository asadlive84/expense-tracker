# Expense Tracker — Frontend

A single-page web application for personal expense tracking, built with React 18 + TypeScript.

## Tech Stack

| Concern | Choice |
|---|---|
| Framework | React 18 + TypeScript |
| Build tool | Vite |
| Styling | Tailwind CSS v4 |
| Server state | TanStack Query v5 |
| HTTP client | Axios |
| Routing | React Router v6 |
| Forms | React Hook Form + Zod |
| Date handling | date-fns |
| Icons | lucide-react |
| Notifications | react-hot-toast |
| Animations | framer-motion |
| Charts | recharts |

## Getting Started

### Prerequisites

- Node.js 18+
- The backend API running at `http://localhost:8080`

### Installation

```bash
npm install
```

### Development

```bash
cp .env.example .env   # Adjust VITE_API_BASE_URL if needed
npm run dev             # Starts on http://localhost:3000
```

### Production Build

```bash
npm run build           # Output in dist/
npm run preview         # Preview the build locally
```

### Docker

```bash
docker build -t expense-tracker-frontend .
docker run -p 3000:80 expense-tracker-frontend
```

Or use docker-compose from the project root:

```bash
docker compose up --build
```

This starts the full stack:
- **API** → `http://localhost:8080`
- **Frontend** → `http://localhost:3000`

## Project Structure

```
src/
  api/              # Axios API functions (one file per domain)
    client.ts       # Axios instance with JWT interceptor
    auth.ts         # Login, register
    buckets.ts      # Bucket CRUD
    people.ts       # People CRUD
    tags.ts         # Tag CRUD
    transactions.ts # Transaction CRUD + filters
    reports.ts      # Report endpoints
    reminders.ts    # Reminder CRUD + pay/skip
  components/
    ui/             # Button, Input, Modal, Drawer, Badge, Select, etc.
    layout/         # Sidebar, BottomNav, PageHeader
    TransactionForm.tsx
    PayModal.tsx
  pages/            # One component per route
    Login.tsx
    Register.tsx
    Dashboard.tsx
    Transactions.tsx
    Buckets.tsx
    People.tsx
    Tags.tsx
    Reports.tsx
    Reminders.tsx
  hooks/            # TanStack Query hooks with optimistic updates
  utils/
    money.ts        # formatBDT, parseBDT (BDT ↔ paisa)
    date.ts         # Date formatting helpers
    errors.ts       # API error → form error mapping
  types/            # TypeScript interfaces (from OpenAPI spec)
  router.tsx        # React Router config + protected routes
  main.tsx          # Entry point + QueryClient setup
```

## Key Design Decisions

### Money Handling
All amounts are stored and transmitted as **paisa** (integer). 1 BDT = 100 paisa.
User inputs BDT with decimals → converted to paisa on submit.
Display uses `formatBDT()` → `৳250.00`.

### Performance ("Gmail Feel")
- **Optimistic updates** on every mutation — UI changes before server responds
- **Skeleton screens** instead of spinners on first load
- **Stale-while-revalidate** — cached data shows instantly on revisit
- **Hover prefetch** on nav links and list items
- **Infinite scroll** with IntersectionObserver (200px lookahead)
- **Animated list mutations** with framer-motion
- **Global progress bar** for background fetches

### Auth
JWT stored in `localStorage` as `et_token`. Auto-redirect to `/login` on 401.

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `VITE_API_BASE_URL` | `http://localhost:8080/v1` | Backend API base URL |
