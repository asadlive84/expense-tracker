# Frontend Build Prompt — Expense Tracker

> This is a self-contained brief for an AI coding agent to build a web frontend
> for the Expense Tracker API. Read every section before writing a single line of code.
>
> **Performance contract:** The app must feel like Gmail — zero visible page loads,
> instant feedback on every action. Section 12 is not optional polish. It is a
> core requirement with the same weight as correctness.

---

## 1. What You Are Building

A single-page web application for a **personal expense tracker**. The app serves
one user (the person who owns the server). It connects to a Go REST API that
manages money movement across multiple "buckets" (wallet, bKash, bank, DPS, etc.),
tracks loans to/from contacts, tags spending by category, and shows live balance
reports.

The full machine-readable API contract is in `openapi.yaml` in this repository.
Read it before building any screen — it defines every request/response shape,
validation constraint, nullable field, and error code. This prompt adds the
**intent and UX** on top of that contract.

---

## 2. Tech Stack

Use this stack. Do not substitute without flagging it first.

| Concern | Choice |
|---|---|
| Framework | React 18 + TypeScript |
| Build tool | Vite |
| Styling | Tailwind CSS v3 |
| Server state / API calls | TanStack Query v5 (`@tanstack/react-query`) |
| HTTP client | `axios` (wrap in a thin client that injects the JWT header) |
| Routing | React Router v6 |
| Forms | React Hook Form + Zod (schema validation mirrors the API's constraints) |
| Date handling | `date-fns` |
| Icons | `lucide-react` |
| Notifications / toasts | `react-hot-toast` |

Generate code in TypeScript throughout. No `any` types. Derive types from the
OpenAPI spec (either hand-written interfaces or run `openapi-typescript` to
generate them automatically — your choice, but the types must be accurate).

---

## 3. Critical Domain Rules

These are non-obvious. Get them wrong and the UI will be broken or misleading.

### 3.1 Money is in paisa, never BDT
The API stores and returns all amounts as **`int64` paisa** (BDT).
1 BDT = 100 paisa.

- **Never** do arithmetic on amounts displayed as BDT strings.
- Always store, send, and receive amounts as integer paisa.
- Format for display: divide by 100, show 2 decimal places:
  ```ts
  // 25000 paisa → "৳250.00"
  function formatBDT(paisa: number): string {
    return '৳' + (paisa / 100).toFixed(2);
  }
  ```
- Input fields for amounts should accept BDT with decimals and convert to paisa
  on submit:
  ```ts
  // User types "250.50" → send 25050
  const paisa = Math.round(parseFloat(input) * 100);
  ```
- Validate that the paisa value is a positive integer before sending.

### 3.2 The ledger is append-only
Transactions are **never mutated or deleted in the database**. Instead:
- **Edit** (`PATCH /v1/transactions/:id`) inserts a reversal + a new corrected row,
  then returns the new row. From the UI's perspective: call PATCH, invalidate the
  transaction list, show the updated row.
- **Delete** (`DELETE /v1/transactions/:id`) inserts a reversal row only, returns
  204. The deleted transaction disappears from the list.
- The list endpoint already excludes reversed transactions — you don't need to
  filter client-side.

### 3.3 Transaction type field rules
Each transaction type has strict rules about which bucket/person fields are
required vs. forbidden. Enforce these in the form **before** submitting:

| type | from_bucket | to_bucket | person |
|---|---|---|---|
| expense | required | hide/null | optional |
| income | hide/null | required | optional |
| transfer | required | required (≠ from) | hide/null |
| loan_given | required | hide/null | required |
| loan_taken | hide/null | required | required |
| repayment_received | hide/null | required | required |
| repayment_paid | required | hide/null | required |

Show only the relevant fields for the selected type. Don't send null fields
explicitly — omit them from the request body (the API accepts omission).

### 3.4 Cursor-based pagination
`GET /v1/transactions` uses cursor pagination, not page numbers.

- The response includes `next_cursor` (a base64 string).
- Empty string or absent `next_cursor` means no more pages.
- Pass `?cursor=<next_cursor>` to fetch the next page.
- Implement **infinite scroll** or a **"Load more"** button — no page numbers.

### 3.5 Reports are cached server-side
`/v1/reports/*` responses are served from Redis and may be up to 1 hour stale.
After any transaction write (create/edit/delete), **refetch all report queries**
by calling `queryClient.invalidateQueries({ queryKey: ['reports'] })`.

### 3.6 Person balance sign convention
- **Positive** `net_paisa`: they owe you money.
- **Negative** `net_paisa`: you owe them money.
- Zero: settled.
Display this clearly. Example: "Karim owes you ৳500.00" vs "You owe Karim ৳200.00".

### 3.7 Auth token storage
Store the JWT in `localStorage` under the key `et_token`.
On every request, read it and set `Authorization: Bearer <token>`.
On 401 response, clear the token and redirect to `/login`.
The token expires in 30 days — show a session-expired message on expiry.

---

## 4. Screens

Build exactly these screens. Use a persistent left sidebar for navigation on
desktop; a bottom tab bar on mobile (responsive layout).

### 4.1 Login (`/login`)
- Email + password form.
- On success: store token, redirect to `/`.
- Show inline error on 401.
- Link to `/register` below the form.

### 4.2 Register (`/register`)
- Email + password (min 8 chars) form.
- On success: store token, redirect to `/`.
- Show inline error message on 409 (email taken).
- Link to `/login`.

### 4.3 Dashboard (`/`) — default route after login
Four summary cards at the top:
1. **Total across all buckets** — sum of all bucket balances from `/v1/reports/bucket-balances`
2. **This month's income** — from `/v1/reports/summary?month=YYYY-MM`
3. **This month's expenses** — from same summary
4. **Net this month** — income minus expenses (can be negative, show in red)

Below the cards:
- **Recent transactions** — last 10 from `GET /v1/transactions?limit=10`, showing
  type icon, note, bucket name, amount, and date. Click opens the transaction edit drawer.
- **Upcoming reminders** — from `GET /v1/reminders?due_before=<7 days from now>`,
  showing title, amount, due date, and Pay / Skip buttons inline.

### 4.4 Transactions (`/transactions`)
Full-page transaction list with:

**Filter bar** (collapsible on mobile):
- Date range picker (`from` / `to`)
- Type dropdown (all types + "All")
- Bucket selector (dropdown from bucket list)
- Person selector (dropdown from people list)
- Tag selector (dropdown from tag list)

**List** — infinite scroll, 50 per page. Each row shows:
- Type icon (color-coded: expense=red, income=green, transfer=blue,
  loan_given/taken=orange, repayments=purple)
- Note (truncated to 1 line)
- Tags as small chips
- Amount — expenses and loan_given and repayment_paid in red; income,
  loan_taken, repayment_received in green; transfers in blue
- Bucket name(s)
- Date (`dd MMM yyyy`)
- Edit (pencil) and Delete (trash) icon buttons

**Add transaction button** — FAB or prominent top-right button. Opens the
transaction form drawer.

**Transaction form drawer** (right-side slide-in):
- Type selector — styled button group, not a plain `<select>`
- Amount input (BDT with decimal, converts to paisa on submit)
- Dynamic bucket/person fields based on type (rule 3.3 above)
- Note textarea
- Date + time picker (defaults to now)
- Tag multi-select with autocomplete (fetch from `/v1/tags`, filter locally)
- Submit / Cancel

### 4.5 Buckets (`/buckets`)
List of non-archived buckets as cards showing:
- Name
- Live balance from `/v1/reports/bucket-balances` (match by bucket_id)
- Starting balance
- Created date

Actions per card:
- **Rename** (inline edit or modal)
- **Archive** (with confirmation)

**Add bucket** button — opens a small form (name + optional starting balance in BDT).

Show archived buckets in a collapsible "Archived" section at the bottom with an
**Unarchive** button.

### 4.6 People (`/people`)
List of non-archived people as cards showing:
- Name
- Net balance from `/v1/reports/person-balances` (match by person_id)
- Relationship label: "owes you", "you owe", or "settled" (see rule 3.6)

Click a person → show their transaction history filtered by `person_id`.

Actions: **Rename**, **Archive** (with confirmation), **Unarchive** for archived.

### 4.7 Tags (`/tags`)
Simple list. Each tag shows:
- Name
- Total spent this month (from `/v1/reports/tag-totals?from=<month start>&to=<month end>`)
- **Rename**, **Archive**, **Unarchive**

**Add tag** button.

### 4.8 Reports (`/reports`)
Four sections, each with a refresh button that calls the corresponding endpoint
(bypassing client cache):

**Bucket balances** — horizontal bar chart (or table). Show each bucket's balance,
colour bar green if positive, red if negative.

**Person balances** — table. "Owes you" rows highlighted green; "You owe"
rows highlighted red.

**Tag totals** — date range picker (`from`/`to`, defaults to current month).
Doughnut/pie chart + table sorted by total descending.

**Monthly summary** — month picker (defaults to current). Shows income,
expense, net as three stat cards, plus the by-tag breakdown as a bar chart.

### 4.9 Reminders (`/reminders`)

List of active reminders sorted by `next_due_at` ascending. Each row:
- Title
- Amount (or "Amount not set" if null)
- Due date — highlight red if overdue, amber if due within 3 days
- Recurrence badge (`monthly`, `weekly`, etc.)
- **Pay** button → opens pay modal (amount field pre-filled from reminder, can override)
- **Skip** button → confirm, then call skip endpoint
- **Edit** (pencil icon) → opens edit form

**Add reminder** button → full form with all reminder fields.

**Pay modal:**
- Amount input (pre-filled, editable)
- Occurred-at date (defaults to now)
- Note input
- Submit calls `POST /v1/reminders/:id/pay`
- On success: show the created transaction ID in a toast, refresh reminders

---

## 5. API Integration Layer

Create `src/api/client.ts`:
```ts
import axios from 'axios';

const client = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/v1',
});

client.interceptors.request.use((config) => {
  const token = localStorage.getItem('et_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

client.interceptors.response.use(
  (r) => r,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('et_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default client;
```

Create one file per domain in `src/api/`:
- `auth.ts` — login, register
- `buckets.ts` — list, create, update
- `people.ts` — list, create, update
- `tags.ts` — list, create, update
- `transactions.ts` — list (with all filter params), create, update, delete
- `reports.ts` — bucketBalances, personBalances, tagTotals, summary
- `reminders.ts` — list, create, update, pay, skip

Each function returns the typed response data, not the raw axios response.

---

## 6. Error Handling

The API always returns errors in this envelope:
```json
{
  "error": {
    "code": "validation_error",
    "message": "human readable",
    "fields": { "amount_paisa": "must be > 0" }
  }
}
```

Rules:
- On `validation_error`: map `fields` to inline form errors using React Hook
  Form's `setError`. Show the `message` as a form-level error if no `fields`.
- On `conflict`: show a toast with the message.
- On `not_found`: show a toast and navigate back.
- On `invalid_credentials`: show inline error on the login form.
- On `internal_error`: show "Something went wrong. Please try again." toast.
- Never show raw error messages from the API directly to the user for
  non-validation errors — translate them.

---

## 7. Environment

```
VITE_API_BASE_URL=http://localhost:8080/v1
```

The `.env` file is gitignored. Provide a `.env.example`.

---

## 8. Project Structure

```
src/
  api/              # axios functions, one file per domain
  components/
    ui/             # Button, Input, Modal, Drawer, Badge, Select, etc.
    layout/         # Sidebar, BottomNav, PageHeader
  pages/            # One file per route (Login, Register, Dashboard, etc.)
  hooks/            # useAuth, useBuckets, useTransactions, etc. (TanStack Query)
  utils/
    money.ts        # formatBDT, parseBDT (BDT string → paisa integer)
    date.ts         # formatDate, formatRelative helpers
  types/            # TypeScript interfaces matching the OpenAPI schemas
  router.tsx        # React Router config, protected route wrapper
  main.tsx
```

---

## 12. Performance & UX — The "Gmail Feel"

The app must feel like a native desktop application that has been open all day.
The user should never see a blank screen, a full-page spinner, or a layout shift
caused by data loading. Every interaction must produce **immediate visual
feedback** before the server responds.

This section defines exactly how to achieve that. Every pattern here is
mandatory, not a suggestion.

---

### 12.1 TanStack Query global defaults

Set these in `main.tsx` before rendering the app. These defaults make the query
layer behave like a warm cache, not a loading spinner factory.

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000,        // data is fresh for 60 s — no refetch on re-focus
      gcTime: 10 * 60 * 1000,      // keep unused data in memory for 10 min
      refetchOnWindowFocus: false, // don't flash-reload when user switches tabs
      retry: 1,                    // one retry on network error, then show error state
    },
  },
});
```

For **static-ish data** (buckets, people, tags — the user rarely changes these),
set per-query overrides:
```ts
useQuery({ queryKey: ['buckets'], staleTime: 5 * 60 * 1000 }) // 5 min
useQuery({ queryKey: ['tags'],    staleTime: 5 * 60 * 1000 })
useQuery({ queryKey: ['people'],  staleTime: 5 * 60 * 1000 })
```

---

### 12.2 Optimistic updates — the most important pattern

**Rule: every mutation must update the UI before the server responds.**

When the user creates, edits, or deletes something, do not wait for the API call
to finish before changing what they see. Use TanStack Query's `onMutate` callback
to apply the change immediately, then roll back on error.

#### Creating a transaction (canonical example)

```ts
const mutation = useMutation({
  mutationFn: (input: CreateTransactionInput) => api.transactions.create(input),

  onMutate: async (input) => {
    // 1. Cancel any in-flight refetches so they don't overwrite the optimistic value
    await queryClient.cancelQueries({ queryKey: ['transactions'] });

    // 2. Snapshot the current list
    const previous = queryClient.getQueryData(['transactions']);

    // 3. Inject a fake row at the top of the list immediately
    queryClient.setQueryData(['transactions'], (old: TransactionList) => ({
      ...old,
      items: [
        {
          id: 'optimistic-' + Date.now(), // temporary id
          ...input,
          amount_paisa: input.amount_paisa,
          tags: [],
          reversed: false,
          created_at: new Date().toISOString(),
        },
        ...old.items,
      ],
    }));

    return { previous }; // context for rollback
  },

  onError: (_err, _input, context) => {
    // Roll back to the snapshot
    queryClient.setQueryData(['transactions'], context?.previous);
    toast.error('Failed to save. Please try again.');
  },

  onSettled: () => {
    // Reconcile with the real server state
    queryClient.invalidateQueries({ queryKey: ['transactions'] });
    queryClient.invalidateQueries({ queryKey: ['reports'] });
  },
});
```

Apply this same pattern to:
- Creating / editing / archiving a bucket
- Creating / editing / archiving a person or tag
- Paying or skipping a reminder
- Deleting a transaction (remove it from the list immediately)

For **edits**, replace the matching item by id in `setQueryData` with the new values.
For **deletes**, filter the item out by id immediately.

---

### 12.3 Skeleton screens, not spinners

**Never** block a full screen with a centered spinner. Use skeleton placeholders
that match the layout of the real content.

Rules:
- On **first load** of any screen: show a skeleton that has the same structure
  (rows, cards, charts) as the real content. Use `animate-pulse` from Tailwind.
- On **background refetch** (stale-while-revalidate): show the old data, not a
  spinner. The user is already reading it.
- On **mutation in progress**: disable the submit button and show a small
  spinner *inside* the button only. Everything else stays interactive.

```tsx
// Skeleton row — use for transaction list, reminder list, etc.
function SkeletonRow() {
  return (
    <div className="flex items-center gap-3 p-4 animate-pulse">
      <div className="w-8 h-8 rounded-full bg-gray-200" />
      <div className="flex-1 space-y-2">
        <div className="h-4 bg-gray-200 rounded w-3/4" />
        <div className="h-3 bg-gray-200 rounded w-1/2" />
      </div>
      <div className="h-4 bg-gray-200 rounded w-16" />
    </div>
  );
}

// In the list component:
if (isLoading) return <>{Array.from({ length: 8 }).map((_, i) => <SkeletonRow key={i} />)}</>;
```

Skeleton components to build (one per major data shape):
- `SkeletonRow` — for transaction list, reminder list
- `SkeletonCard` — for bucket cards, people cards
- `SkeletonStatCard` — for the 4 dashboard stat cards
- `SkeletonChart` — a grey rectangle with pulse for report charts

---

### 12.4 Never navigate away for a form

All create and edit operations open in a **right-side drawer** or **modal**
that slides in over the current screen. The URL does not change. The list
behind the drawer stays visible and interactive.

- Use a `<Drawer>` component with a dark backdrop and smooth `translate-x`
  CSS transition (200 ms ease-out).
- The drawer traps focus and closes on Escape or backdrop click.
- On submit success: close the drawer immediately (don't wait for the list
  to refetch — the optimistic update already shows the result).

Screens that use drawers: transaction form, bucket form, person form, tag form,
reminder form, reminder pay modal.

---

### 12.5 Prefetch on hover

For any list item that the user might click to expand or edit, prefetch the
detail data on `mouseenter`:

```ts
function TransactionRow({ transaction }: { transaction: Transaction }) {
  const queryClient = useQueryClient();

  return (
    <div
      onMouseEnter={() => {
        // Pre-warm the query cache so the drawer opens instantly
        queryClient.prefetchQuery({
          queryKey: ['transaction', transaction.id],
          queryFn: () => api.transactions.get(transaction.id),
          staleTime: 30_000,
        });
      }}
    >
      {/* row content */}
    </div>
  );
}
```

Also prefetch on hover for: person detail (their transaction history),
bucket detail, reminder edit.

---

### 12.6 Instant navigation between pages

React Router renders client-side — there is no page load. But data fetching
can still cause a blank content flash. Prevent it with route-level prefetching:

In the sidebar nav links, prefetch the page's primary data on hover:

```ts
<NavLink
  to="/transactions"
  onMouseEnter={() => queryClient.prefetchQuery({
    queryKey: ['transactions'],
    queryFn: () => api.transactions.list({}),
  })}
>
  Transactions
</NavLink>
```

Do this for every nav item. By the time the user clicks, the data is already
in cache.

---

### 12.7 Stale-while-revalidate display pattern

When navigating to a screen whose data is stale (older than `staleTime`),
TanStack Query shows the **cached data immediately** while refetching in the
background. The user never sees a loading state for a page they've visited before.

Do not fight this. Do not add `isLoading` guards that hide content when
`isFetching` is true. The right logic is:

```ts
// ✓ Correct — show content immediately, skeleton only on true first load
if (isLoading) return <SkeletonList />;       // isLoading = no data at all
return <TransactionList data={data} />;        // show even if isFetching=true in bg

// ✗ Wrong — hides the list every time the cache refreshes
if (isLoading || isFetching) return <Spinner />;
```

Show a thin **progress bar at the top of the screen** (like GitHub / YouTube)
while any query is fetching in the background. Use the `isFetching` value from
`useIsFetching()`:

```ts
function GlobalProgressBar() {
  const isFetching = useIsFetching();
  return isFetching ? (
    <div className="fixed top-0 left-0 right-0 h-0.5 bg-indigo-500 animate-pulse z-50" />
  ) : null;
}
```

---

### 12.8 Smooth list mutations

When a transaction is deleted or a reminder is paid, do not let the list
**jump** — items below the removed one should slide up smoothly.

Use the `layoutId` prop from `framer-motion` (add it to the stack — it is the
only additional library permitted for animation):

```bash
npm install framer-motion
```

Wrap list items in `<motion.div layout>` so that reordering and removal animate
automatically:

```tsx
import { AnimatePresence, motion } from 'framer-motion';

<AnimatePresence initial={false}>
  {transactions.map((tx) => (
    <motion.div
      key={tx.id}
      layout
      initial={{ opacity: 0, y: -8 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, x: 40, height: 0 }}
      transition={{ duration: 0.15 }}
    >
      <TransactionRow transaction={tx} />
    </motion.div>
  ))}
</AnimatePresence>
```

Apply `<AnimatePresence>` + `<motion.div layout>` to:
- Transaction list
- Reminder list
- Bucket cards
- People cards

---

### 12.9 Infinite scroll without jank

For the transaction list, implement infinite scroll using
`IntersectionObserver`. Attach a sentinel element at the bottom of the list:

```ts
const { data, fetchNextPage, hasNextPage, isFetchingNextPage } =
  useInfiniteQuery({
    queryKey: ['transactions', filters],
    queryFn: ({ pageParam }) => api.transactions.list({ ...filters, cursor: pageParam }),
    getNextPageParam: (lastPage) => lastPage.next_cursor || undefined,
    initialPageParam: '',
  });

// Sentinel ref
const sentinelRef = useRef<HTMLDivElement>(null);
useEffect(() => {
  const observer = new IntersectionObserver(
    (entries) => { if (entries[0].isIntersecting && hasNextPage) fetchNextPage(); },
    { rootMargin: '200px' }   // start loading 200px before the bottom
  );
  if (sentinelRef.current) observer.observe(sentinelRef.current);
  return () => observer.disconnect();
}, [hasNextPage, fetchNextPage]);
```

Show a skeleton row while `isFetchingNextPage` is true. Never show a "Load more"
button — scroll should feel endless.

---

### 12.10 Form UX — no jarring error states

- Use `react-hook-form` with `mode: 'onBlur'` so errors appear after the user
  leaves a field, not while they're typing.
- Show field errors as small text below the input, not as an alert banner.
- On submit with errors: shake the submit button (CSS keyframe, 300 ms) and
  focus the first invalid field automatically.
- Disable the submit button while the mutation is in flight. Show a small
  inline spinner in the button (`<Loader2 className="animate-spin" size={14} />`).
- After successful submit: close the drawer and show a toast (`react-hot-toast`)
  in the bottom-right corner. The toast auto-dismisses in 3 seconds.

---

### 12.11 Toast strategy

| Event | Toast style | Duration |
|---|---|---|
| Create success | Green, "Saved" | 2 s |
| Edit success | Green, "Updated" | 2 s |
| Delete success | Neutral, "Deleted" | 2 s with Undo button (see below) |
| Pay reminder success | Green, "Payment recorded" | 3 s |
| Error (conflict, server error) | Red, message from API | 5 s |
| Validation error | No toast — show inline | — |

**Undo delete:** When a transaction is deleted, show a toast with an **Undo**
button for 4 seconds. If the user clicks Undo within that window, call
`PATCH /v1/transactions/:id` with the original values (re-create it with the
same fields — this is valid because the API's delete is a reversal, and
re-creating restores the data). If the toast dismisses, the delete is permanent.

---

### 12.12 Dashboard data loading strategy

The dashboard (`/`) makes 3 API calls:
1. `GET /v1/reports/bucket-balances`
2. `GET /v1/reports/summary?month=<current>`
3. `GET /v1/transactions?limit=10`
4. `GET /v1/reminders?due_before=<7 days>`

Fire all four in parallel with `Promise.all` or by rendering all four
`useQuery` hooks at the same level. Do not waterfall them. Use skeleton cards
for the stat summary while they load; show the last cached values immediately
on revisit.

---

## 9. Definition of Done

**Correctness**
- [ ] All 9 screens implemented and navigable
- [ ] Auth flow (login + register + token persistence + auto-logout on 401)
- [ ] Transactions: create all 7 types with correct field visibility, infinite scroll, edit, delete
- [ ] Reports: all 4 report types render with correct data
- [ ] Reminders: pay and skip work end-to-end
- [ ] Amount inputs always convert correctly (BDT ↔ paisa)
- [ ] Responsive layout (sidebar on ≥768px, bottom tabs on mobile)
- [ ] Form validation errors map to fields
- [ ] After any transaction write, report queries are invalidated
- [ ] `npm run build` produces no TypeScript errors
- [ ] `.env.example` provided

**Performance / UX (§12 — all mandatory)**
- [ ] Every mutation has an optimistic update — UI changes before server responds
- [ ] Skeleton screens on first load; stale data shown immediately on revisit
- [ ] No full-page spinners anywhere
- [ ] All forms open in a drawer; URL never changes for create/edit
- [ ] Hover prefetch on nav links and list items
- [ ] List mutations (delete, add) animate smoothly with framer-motion
- [ ] Infinite scroll on transactions with 200px lookahead sentinel
- [ ] Global thin progress bar while any query is fetching in background
- [ ] Toast on success/error; undo toast on delete (4 s window)
- [ ] Dashboard fires 4 API calls in parallel, not waterfall
- [ ] `framer-motion` is the only animation library added beyond the stack in §2

---

## 10. What You Must NOT Do

- Do not add features not described above (no multi-currency, no charts beyond
  what's listed, no dark mode toggle, no export, no push notifications).
- Do not use an ORM or server-side framework — this is a pure client-side SPA.
- Do not store the JWT in a cookie or sessionStorage — use `localStorage` key `et_token`.
- Do not add a mock API layer — call the real API (configure `VITE_API_BASE_URL`).
- Do not install libraries not listed in §2. If you think you need one, say so
  before adding it.

---

## 11. Reference: All API Endpoints

```
POST   /v1/auth/register          → { token, expires_at }
POST   /v1/auth/login             → { token, expires_at }
GET    /v1/me                     → { user_id }

GET    /v1/buckets                → { items: Bucket[] }
POST   /v1/buckets                → Bucket
PATCH  /v1/buckets/:id            → Bucket

GET    /v1/people                 → { items: Person[] }
POST   /v1/people                 → Person
PATCH  /v1/people/:id             → Person

GET    /v1/tags                   → { items: Tag[] }
POST   /v1/tags                   → Tag
PATCH  /v1/tags/:id               → Tag

GET    /v1/transactions           → { items: Transaction[], next_cursor: string }
POST   /v1/transactions           → Transaction
PATCH  /v1/transactions/:id       → Transaction
DELETE /v1/transactions/:id       → 204

GET    /v1/reports/bucket-balances           → { items: BucketBalance[] }
GET    /v1/reports/person-balances           → { items: PersonBalance[] }
GET    /v1/reports/tag-totals?from=&to=      → { items: TagTotal[] }
GET    /v1/reports/summary?month=YYYY-MM     → MonthlySummary

GET    /v1/reminders              → { items: Reminder[] }
POST   /v1/reminders              → Reminder
PATCH  /v1/reminders/:id          → Reminder
POST   /v1/reminders/:id/pay      → { reminder: Reminder, transaction: Transaction }
POST   /v1/reminders/:id/skip     → Reminder
```

Full schema for every type is in `openapi.yaml` at the root of the repository.
The OpenAPI spec is the authoritative source of truth for field names, types,
nullable vs required, and enum values. This prompt is the authoritative source
of truth for UX decisions.
