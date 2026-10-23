export type DateRange = {
  // NOTE: Cost Explorer の TimePeriod と同じく start は含み end は含まない（YYYY-MM-DD）
  start: string;
  end: string;
};

export type ComparisonPeriod = {
  current: DateRange;
  previous: DateRange;
};

const DAYS_PER_WEEK = 7;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

function toDateString(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function addDays(date: Date, days: number): Date {
  return new Date(date.getTime() + days * MS_PER_DAY);
}

export function resolveComparisonPeriod(now: Date): ComparisonPeriod {
  const today = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const currentStart = addDays(today, -DAYS_PER_WEEK);
  const previousStart = addDays(today, -DAYS_PER_WEEK * 2);
  return {
    current: { start: toDateString(currentStart), end: toDateString(today) },
    previous: { start: toDateString(previousStart), end: toDateString(currentStart) },
  };
}

export function isInRange(day: string, range: DateRange): boolean {
  return range.start <= day && day < range.end;
}
