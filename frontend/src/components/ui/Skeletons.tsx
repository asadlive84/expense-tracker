export function SkeletonRow() {
  return (
    <div className="flex items-center gap-3 p-4 animate-pulse">
      <div className="w-9 h-9 rounded-full bg-surface-800" />
      <div className="flex-1 space-y-2">
        <div className="h-4 bg-surface-800 rounded w-3/4" />
        <div className="h-3 bg-surface-800 rounded w-1/2" />
      </div>
      <div className="h-4 bg-surface-800 rounded w-20" />
    </div>
  );
}

export function SkeletonCard() {
  return (
    <div className="p-5 rounded-xl bg-surface-900 border border-surface-800 animate-pulse space-y-3">
      <div className="h-5 bg-surface-800 rounded w-2/3" />
      <div className="h-8 bg-surface-800 rounded w-1/2" />
      <div className="h-3 bg-surface-800 rounded w-1/3" />
    </div>
  );
}

export function SkeletonStatCard() {
  return (
    <div className="p-5 rounded-xl bg-surface-900/80 border border-surface-800 animate-pulse space-y-2">
      <div className="h-3 bg-surface-800 rounded w-1/2" />
      <div className="h-7 bg-surface-800 rounded w-2/3" />
    </div>
  );
}

export function SkeletonChart() {
  return (
    <div className="h-64 rounded-xl bg-surface-900 border border-surface-800 animate-pulse flex items-center justify-center">
      <div className="w-32 h-32 rounded-full bg-surface-800" />
    </div>
  );
}
