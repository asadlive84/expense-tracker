// ── Transaction Types ─────────────────────────────────────────────────────
export type TransactionType =
  | 'expense'
  | 'income'
  | 'transfer'
  | 'loan_given'
  | 'loan_taken'
  | 'repayment_received'
  | 'repayment_paid';

export type RecurrenceType = 'none' | 'weekly' | 'monthly' | 'yearly';
export type ReminderStatus = 'active' | 'paused' | 'completed';

// ── Tag Reference ─────────────────────────────────────────────────────────
export interface TagRef {
  id: string;
  name: string;
}

// ── Auth ──────────────────────────────────────────────────────────────────
export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  expires_at: string;
}

// ── Bucket ────────────────────────────────────────────────────────────────
export interface Bucket {
  id: string;
  user_id: string;
  name: string;
  starting_balance_paisa: number;
  archived_at?: string | null;
  created_at: string;
}

export interface CreateBucketRequest {
  name: string;
  starting_balance_paisa?: number;
}

export interface UpdateBucketRequest {
  name?: string;
  archived?: boolean;
}

// ── Person ────────────────────────────────────────────────────────────────
export interface Person {
  id: string;
  user_id: string;
  name: string;
  archived_at?: string | null;
  created_at: string;
}

export interface CreatePersonRequest {
  name: string;
}

export interface UpdatePersonRequest {
  name?: string;
  archived?: boolean;
}

// ── Tag ───────────────────────────────────────────────────────────────────
export interface Tag {
  id: string;
  user_id: string;
  name: string;
  archived_at?: string | null;
  created_at: string;
}

export interface CreateTagRequest {
  name: string;
}

export interface UpdateTagRequest {
  name?: string;
  archived?: boolean;
}

// ── Transaction ───────────────────────────────────────────────────────────
export interface Transaction {
  id: string;
  user_id: string;
  type: TransactionType;
  amount_paisa: number;
  from_bucket_id?: string | null;
  to_bucket_id?: string | null;
  person_id?: string | null;
  note: string;
  occurred_at: string;
  created_at: string;
  reverses_id?: string | null;
  tags: TagRef[];
  reversed: boolean;
}

export interface CreateTransactionRequest {
  type: TransactionType;
  amount_paisa: number;
  from_bucket_id?: string;
  to_bucket_id?: string;
  person_id?: string;
  note?: string;
  occurred_at: string;
  tag_ids?: string[];
}

export interface TransactionList {
  items: Transaction[];
  next_cursor: string;
}

export interface TransactionFilters {
  type?: TransactionType;
  bucket_id?: string;
  person_id?: string;
  tag_id?: string;
  from?: string;
  to?: string;
  limit?: number;
  cursor?: string;
}

// ── Reports ───────────────────────────────────────────────────────────────
export interface BucketBalance {
  bucket_id: string;
  name: string;
  balance_paisa: number;
}

export interface PersonBalance {
  person_id: string;
  name: string;
  net_paisa: number;
}

export interface TagTotal {
  tag_id: string;
  name: string;
  total_paisa: number;
}

export interface MonthlySummary {
  income_paisa: number;
  expense_paisa: number;
  net_paisa: number;
  by_tag: TagTotal[];
}

// ── Reminder ──────────────────────────────────────────────────────────────
export interface Reminder {
  id: string;
  user_id: string;
  title: string;
  amount_paisa?: number | null;
  default_type: TransactionType;
  recurrence_type: RecurrenceType;
  recurrence_day?: number | null;
  next_due_at: string;
  linked_bucket_id?: string | null;
  linked_person_id?: string | null;
  status: ReminderStatus;
  created_at: string;
}

export interface CreateReminderRequest {
  title: string;
  amount_paisa?: number | null;
  default_type: TransactionType;
  recurrence_type: RecurrenceType;
  recurrence_day?: number | null;
  next_due_at: string;
  linked_bucket_id?: string | null;
  linked_person_id?: string | null;
  tag_ids?: string[];
}

export interface UpdateReminderRequest {
  title?: string;
  amount_paisa?: number | null;
  default_type?: TransactionType;
  recurrence_type?: RecurrenceType;
  recurrence_day?: number | null;
  next_due_at?: string;
  linked_bucket_id?: string | null;
  linked_person_id?: string | null;
  status?: ReminderStatus;
  tag_ids?: string[];
}

export interface PayReminderRequest {
  amount_paisa?: number | null;
  occurred_at?: string;
  note?: string;
}

export interface PayReminderResponse {
  reminder: Reminder;
  transaction: Transaction;
}

// ── Error ─────────────────────────────────────────────────────────────────
export interface ErrorDetail {
  code: string;
  message: string;
  fields?: Record<string, string>;
}

export interface ErrorEnvelope {
  error: ErrorDetail;
}

// ── Generic list wrapper ──────────────────────────────────────────────────
export interface ListResponse<T> {
  items: T[];
}
