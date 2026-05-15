interface BadgeProps {
  children: React.ReactNode;
  color?: 'green' | 'red' | 'blue' | 'orange' | 'purple' | 'amber' | 'neutral';
  className?: string;
}

const colorClasses: Record<NonNullable<BadgeProps['color']>, string> = {
  green: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/20',
  red: 'bg-red-500/15 text-red-400 border-red-500/20',
  blue: 'bg-blue-500/15 text-blue-400 border-blue-500/20',
  orange: 'bg-orange-500/15 text-orange-400 border-orange-500/20',
  purple: 'bg-purple-500/15 text-purple-400 border-purple-500/20',
  amber: 'bg-amber-500/15 text-amber-400 border-amber-500/20',
  neutral: 'bg-surface-700/50 text-surface-300 border-surface-600/20',
};

export function Badge({ children, color = 'neutral', className = '' }: BadgeProps) {
  return (
    <span
      className={`
        inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium
        border ${colorClasses[color]} ${className}
      `}
    >
      {children}
    </span>
  );
}
