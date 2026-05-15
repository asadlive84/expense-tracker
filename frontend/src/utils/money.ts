/**
 * Format paisa (integer) as BDT string with ৳ symbol.
 * 25000 → "৳250.00"
 */
export function formatBDT(paisa: number): string {
  const bdt = paisa / 100;
  const formatted = Math.abs(bdt).toLocaleString('en-BD', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
  return (bdt < 0 ? '-৳' : '৳') + formatted;
}

/**
 * Parse a BDT string (user input) to paisa integer.
 * "250.50" → 25050
 * Returns NaN if invalid.
 */
export function parseBDT(input: string): number {
  const cleaned = input.replace(/[৳,\s]/g, '');
  const parsed = parseFloat(cleaned);
  if (isNaN(parsed)) return NaN;
  return Math.round(parsed * 100);
}

/**
 * Validate that a paisa value is a positive integer.
 */
export function isValidPaisa(paisa: number): boolean {
  return Number.isInteger(paisa) && paisa > 0;
}
