# Mobile App Plan — Expense Tracker (Flutter)

> **Yes, you can publish on the Play Store.** The foundation is solid.
> This document is the complete plan: what exists, what's broken, what to build,
> and the exact steps to go from current state → Play Store listing.

---

## Current State Audit

### What's already built and working
| File | Status |
|---|---|
| Architecture (Riverpod + Freezed + GoRouter + Dio) | ✅ Correct and complete |
| All Freezed models (Bucket, Transaction, Reminder, Reports…) | ✅ Match API exactly |
| Auth: login + register screens + interceptors + secure token | ✅ Working |
| Routing with auth guards (splash → login/register → home) | ✅ Working |
| Material 3 theme, light + dark mode | ✅ Working |
| API client with auth + error interceptors | ✅ Working |
| Transaction list with cursor pagination | ✅ Working |
| All 4 report providers (balances, people, tag totals, summary) | ✅ Wired to API |
| Home screen (net worth + monthly stats + recent transactions) | ✅ Data correct, UI basic |
| Reminders list with "Due Now / Upcoming" split + pay dialog | ✅ Working |
| QuickAddSheet (expense/income/transfer partial) | ⚠️ Incomplete |

### What's broken or missing
| Gap | Severity |
|---|---|
| QuickAddSheet: only 3 of 7 types; no `person_id`; no note; no `to_bucket` for income | 🔴 Critical |
| Transaction edit (PATCH) — no UI anywhere | 🔴 Critical |
| ManageBucketsScreen — file exists but is a stub | 🔴 Critical |
| People screen — provider exists, zero UI | 🔴 Critical |
| Tags screen — provider exists, zero UI | 🔴 Critical |
| Settings screen — `Text('Settings Screen')` placeholder | 🔴 Critical |
| Reminder creation form — no way to add a new reminder | 🔴 Critical |
| Error handling — all catch blocks are empty, errors silently swallowed | 🔴 Critical |
| Transaction filters on ledger (type, bucket, date range) | 🟡 Important |
| UI: plain `ListTile` everywhere, no type icons, no color coding | 🟡 Important |
| Skeleton loading states | 🟡 Important |
| App icon + splash screen | 🟡 Required for Play Store |
| No optimistic updates | 🟠 Nice to have |

---

## Architecture Decision: Keep Everything

**Do not rewrite.** The stack is correct:
- **Riverpod** for state — keep `AsyncNotifierProvider` pattern
- **Freezed + json_serializable** for models — already generated and correct
- **GoRouter** with `StatefulShellRoute` — correct for bottom nav
- **Dio** with interceptors — already handles auth and errors

The only changes needed are **additive**: new screens, fix the incomplete
QuickAddSheet, add missing providers, improve UI.

---

## Phase 1 — Fix the Broken Core (1–2 days)

These must be done before anything else or the app is unusable.

### 1.1 Complete QuickAddSheet → Full Transaction Form

The current sheet only handles expense/income/transfer and is missing:
- `loan_given`, `loan_taken`, `repayment_received`, `repayment_paid` types
- `person_id` selector (required for loan/repayment types)
- `to_bucket` field (required for income/loan_taken/repayment_received)
- Note input field
- Date/time picker (currently hardcodes `DateTime.now()`)

**What to build:** Replace the `SegmentedButton` (which only fits 3 items) with a
scrollable row of 7 type chips. Show/hide `fromBucket`, `toBucket`, and `person`
fields dynamically based on the selected type using the exact rules from the API.

### 1.2 Add Transaction Edit

When the user long-presses or swipes a transaction row:
- Open the same form sheet pre-filled with the transaction's values
- On submit call `PATCH /v1/transactions/:id`
- Add `updateTransaction(String id, CreateTransactionRequest req)` to
  `TransactionApi` and a corresponding `update()` method to
  `TransactionsController`

### 1.3 Error Handling

Every empty `catch` block must show a `SnackBar` with the API's error message.
The `ErrorInterceptor` already parses the `{"error":{"code":"...","message":"..."}}` 
envelope — use that message in the UI.

---

## Phase 2 — Missing Screens (2–3 days)

### 2.1 Buckets Screen (replace ManageBucketsScreen stub)

**List view:**
- Each bucket shown as a card: name + live balance from `bucketBalancesProvider`
  (join by `bucket.id == balance.bucketId`)
- Balance coloured green (positive) or red (negative)
- Swipe-to-archive with confirmation snackbar + Undo

**Create/Edit:**
- Bottom sheet with name field + optional starting balance (BDT input → paisa)
- On create: `POST /v1/buckets`; on edit: `PATCH /v1/buckets/:id`

**Archived section:**
- Collapsed at bottom of list, expandable
- Each archived bucket has an "Unarchive" button → `PATCH` with `archived: false`

### 2.2 People Screen (new)

Same pattern as buckets:
- List with person name + net balance from `personBalancesProvider`
- Net balance label: "Owes you ৳X" (green) / "You owe ৳X" (red) / "Settled" (grey)
- Tap person → open their transactions filtered by `person_id`
- Swipe to archive, add/edit via bottom sheet

### 2.3 Tags Screen (new)

- List of tags sorted by recent use
- Show total spent this month (from `tagTotalsProvider` for current month)
- Add/rename via inline edit (tap the tag name)
- Swipe to archive

### 2.4 Reminder Creation Form (new)

Add a FAB to `RemindersScreen` that opens a bottom sheet with:
- Title field
- Amount (optional BDT input)
- Default type selector (all 7 types)
- Recurrence type selector (none / weekly / monthly / yearly)
- Recurrence day (shown only for monthly — number picker 1–31)
- Next due date picker
- Linked bucket selector (optional)
- Linked person selector (optional, shown for loan/repayment types)
- Tag multi-select

Also add edit capability: long-press a reminder to open the same form pre-filled.

### 2.5 Settings Screen (replace placeholder)

Three sections:
1. **Account** — show logged-in email + Logout button
   (on logout: clear secure storage, `ref.invalidate` all providers, redirect to `/login`)
2. **API** — show current API base URL (read-only, set via build env)
3. **Appearance** — Light / Dark / System theme toggle (already wired to `themeControllerProvider`)

---

## Phase 3 — UI Redesign (2–3 days)

The data is correct. The UI needs visual hierarchy. No new packages needed —
everything below uses Material 3 components and the existing theme.

### 3.1 Transaction Row

Replace plain `ListTile` with a designed row:

```
[TYPE ICON]  [NOTE or TYPE LABEL]          [+৳2,500]
             [BUCKET NAME] · [DATE]
             [food] [family]  ← tag chips
```

- **Type icon + background colour:**
  - expense → red circle, `arrow_upward`
  - income → green circle, `arrow_downward`
  - transfer → blue circle, `swap_horiz`
  - loan_given → orange circle, `person_add`
  - loan_taken → purple circle, `person_remove`
  - repayment_received → teal circle, `check_circle`
  - repayment_paid → amber circle, `payments`
- Amount: red for outflows (expense, loan_given, repayment_paid), green for inflows
- Tags as small coloured chips below the subtitle

### 3.2 Home Screen

Current layout is correct — just needs spacing and visual polish:
- Net Worth card: gradient background, larger amount text, subtitle showing
  total across N buckets
- Income/Expense cards: add small trend indicator (up/down arrow vs last month)
- Recent transactions: use the new styled row (§3.1)
- Add "Upcoming reminders" section at the bottom (1–3 reminders due this week)

### 3.3 Insights Screen

- **Buckets tab:** Replace `ListTile` with cards showing a horizontal bar
  representing the balance proportion. Sort by balance descending.
- **People tab:** Colour-coded rows. Add a summary at top: "Total owed to you: ৳X"
- **Tags tab:** The `LinearProgressIndicator` per tag is good — keep it, just
  add the tag colour, percentage, and a month picker so users can view any month

### 3.4 Skeleton Loading

Replace every `loading: () => Center(child: CircularProgressIndicator())` with
a shimmer-style skeleton that matches the layout. Use `shimmer` package
(add to pubspec.yaml — this is the only new package needed):

```
shimmer: ^3.0.0
```

Three skeleton widgets to build:
- `SkeletonTransactionRow` — matches the styled row layout
- `SkeletonStatCard` — matches the home screen stat cards
- `SkeletonListTile` — generic fallback

### 3.5 Transaction Filters (Ledger Screen)

Add a filter icon button in the AppBar. Tap opens a bottom sheet with:
- Date range picker (from / to)
- Type chip selector (All + 7 types)
- Bucket dropdown
- Person dropdown

Pass the selected filters to `TransactionsController` which already accepts
a `filters` map in `getTransactions()`.

---

## Phase 4 — Play Store Prep (1 day)

### 4.1 App Identity

1. **App icon** — design a ৳ symbol or wallet icon at 1024×1024px.
   Use `flutter_launcher_icons` package to generate all sizes:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/app_icon.png"
   ```
2. **Splash screen** — use `flutter_native_splash`:
   ```yaml
   flutter_native_splash:
     color: "#6750A4"          # your seed colour
     image: assets/icon/logo.png
   ```
3. **App name** — update `android/app/src/main/AndroidManifest.xml`:
   `android:label="Expense Tracker"` (or your preferred name in Bengali/English)

### 4.2 pubspec.yaml Changes

```yaml
# Change this:
publish_to: 'none'   # ← remove this line (or keep it, it doesn't block Play Store)

# Bump version before each release:
version: 1.0.0+1     # format: semver+build-number
```

### 4.3 Android Signing

The Play Store requires a signed APK/AAB. Steps:

1. Generate a keystore (one-time):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```
2. Create `android/key.properties` (never commit this file — it's in `.gitignore`):
   ```
   storePassword=<your password>
   keyPassword=<your password>
   keyAlias=upload
   storeFile=/Users/asad/upload-keystore.jks
   ```
3. Update `android/app/build.gradle.kts` to read `key.properties` and apply
   the signing config for the release build type.

### 4.4 Build the Release AAB

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-server.com/v1
```

The output is `build/app/outputs/bundle/release/app-release.aab`.

### 4.5 Play Console Setup

1. Go to [play.google.com/console](https://play.google.com/console)
2. Pay the one-time $25 developer fee
3. Create a new app → choose "App" → Android → Free
4. Fill in:
   - **App name** (30 chars max)
   - **Short description** (80 chars)
   - **Full description**
   - **Screenshots** — minimum 2, maximum 8 (phone screenshots, 16:9 or 9:16)
   - **Feature graphic** — 1024×500px banner image
   - **App icon** — 512×512px PNG (same as launcher icon)
   - **Privacy policy URL** — required even for personal apps. Host a simple page
     saying the app stores data on your personal server.
5. Upload the AAB to the **Internal testing** track first
6. Once tested on your own device, promote to **Production**

### 4.6 Play Store Requirements Checklist

- [ ] Target API level ≥ 34 (already set in `build.gradle.kts`)
- [ ] App signed with upload key
- [ ] Privacy policy URL provided
- [ ] At least 2 phone screenshots
- [ ] Content rating questionnaire completed (Finance category → straightforward)
- [ ] Declare that the app does not collect user data (it talks to your own server)

---

## Phase 5 — Nice to Have (after launch)

These are not required for Play Store but improve the experience:

| Feature | Effort | Value |
|---|---|---|
| Optimistic updates (delete/create feel instant) | Medium | High |
| Local notifications for due reminders (package already installed: `flutter_local_notifications`) | Medium | High |
| Offline read cache (save last API response to shared_preferences) | Medium | Medium |
| Biometric lock (touch/face ID before opening app) | Low | Medium |
| CSV export of transactions | Low | Low |
| Bengali language localisation | Medium | High for local users |

---

## Execution Order Summary

```
Week 1
  Day 1–2   Phase 1: Fix QuickAddSheet, add transaction edit, wire error handling
  Day 3–5   Phase 2: Buckets screen, People screen, Tags screen,
                     Reminder creation, Settings screen

Week 2
  Day 1–3   Phase 3: Styled transaction row, home screen polish,
                     insights redesign, skeleton loading, filters
  Day 4     Phase 4: App icon, splash, signing, build AAB
  Day 5     Phase 4: Play Console setup, screenshots, submit to internal testing
```

---

## Prompt for a Coding Agent

If you want an AI agent to implement this plan, hand it this document plus
`openapi.yaml` and tell it:

> "This Flutter app is in `mobile_app/`. The architecture (Riverpod, Freezed,
> GoRouter, Dio) is already in place and must not change. The models in
> `lib/shared/models/models.dart` are correct — do not regenerate them.
> Implement the gaps listed in MOBILE_PLAN.md Phase 1 through Phase 3 in order.
> Write no code outside `lib/`. Do not add packages except `shimmer: ^3.0.0`.
> After each phase confirm it compiles with `flutter analyze` before moving on."
