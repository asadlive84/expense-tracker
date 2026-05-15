import { useIsFetching } from '@tanstack/react-query';

export function GlobalProgressBar() {
  const isFetching = useIsFetching();
  return isFetching ? (
    <div className="fixed top-0 left-0 right-0 h-0.5 z-50">
      <div className="h-full bg-gradient-to-r from-primary-400 via-primary-500 to-primary-600 animate-pulse" />
    </div>
  ) : null;
}
