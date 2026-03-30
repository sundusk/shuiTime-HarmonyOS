
interface DayRange {
  start: number;
  end: number;
}

export function toIsoString(timestamp: number): string {
  return new Date(timestamp).toISOString();
}

export function parseIsoToTimestamp(value: string): number {
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? 0 : parsed;
}
export function getDayRange(timestamp: number): DayRange {
  const date = new Date(timestamp);
  date.setHours(0, 0, 0, 0);
  const start = date.getTime();
  const end = start + 24 * 60 * 60 * 1000 - 1;
  return { start, end } as DayRange;
}

export function formatDisplayDate(timestamp: number): string {
  const date = new Date(timestamp);
  const year = date.getFullYear();
  const month = `${date.getMonth() + 1}`.padStart(2, '0');
  const day = `${date.getDate()}`.padStart(2, '0');
  return `${year}-${month}-${day}`;
}
