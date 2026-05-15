import { format, formatDistanceToNow, parseISO, isValid } from 'date-fns';

/**
 * Format ISO date string to "dd MMM yyyy" (e.g. "14 May 2026")
 */
export function formatDate(dateStr: string): string {
  const date = parseISO(dateStr);
  if (!isValid(date)) return dateStr;
  return format(date, 'dd MMM yyyy');
}

/**
 * Format ISO date string to "dd MMM yyyy, HH:mm"
 */
export function formatDateTime(dateStr: string): string {
  const date = parseISO(dateStr);
  if (!isValid(date)) return dateStr;
  return format(date, 'dd MMM yyyy, HH:mm');
}

/**
 * Format date relative to now (e.g. "2 hours ago", "in 3 days")
 */
export function formatRelative(dateStr: string): string {
  const date = parseISO(dateStr);
  if (!isValid(date)) return dateStr;
  return formatDistanceToNow(date, { addSuffix: true });
}

/**
 * Get current month as YYYY-MM
 */
export function getCurrentMonth(): string {
  return format(new Date(), 'yyyy-MM');
}

/**
 * Get current month start as YYYY-MM-DD
 */
export function getMonthStart(): string {
  return format(new Date(), 'yyyy-MM-01');
}

/**
 * Get current month end as YYYY-MM-DD
 */
export function getMonthEnd(): string {
  const now = new Date();
  const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);
  return format(lastDay, 'yyyy-MM-dd');
}

/**
 * Format to ISO for API (datetime-local input → ISO string)
 */
export function toISOString(dateStr: string): string {
  const date = new Date(dateStr);
  if (!isValid(date)) return new Date().toISOString();
  return date.toISOString();
}

/**
 * Format ISO to datetime-local input value
 */
export function toDateTimeLocal(isoStr?: string): string {
  const date = isoStr ? parseISO(isoStr) : new Date();
  return format(date, "yyyy-MM-dd'T'HH:mm");
}
