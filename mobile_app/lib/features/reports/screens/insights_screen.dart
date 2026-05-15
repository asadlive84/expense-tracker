import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/reports/providers/reports_provider.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  late DateTime _selectedMonth;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  String get _monthKey => DateFormat('yyyy-MM').format(_selectedMonth);
  String get _fromDate => DateFormat('yyyy-MM-dd').format(
    DateTime(_selectedMonth.year, _selectedMonth.month, 1));
  String get _toDate => DateFormat('yyyy-MM-dd').format(
    DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0));

  void _previousMonth() =>
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));

  void _nextMonth() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (!next.isAfter(DateTime.now())) {
      setState(() => _selectedMonth = next);
    }
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    // Simple year-month picker via date picker (first day of months only)
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select month',
      fieldLabelText: 'Month',
      selectableDayPredicate: (d) => d.day == 1,
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final summaryAsync = ref.watch(monthlySummaryProvider(_monthKey));
    final bucketAsync = ref.watch(bucketBalancesProvider);
    final personAsync = ref.watch(personBalancesProvider);
    final tagAsync = ref.watch(tagTotalsProvider('$_fromDate,$_toDate'));

    // Build 6-month history for bar chart
    final monthHistory = List.generate(6, (i) {
      final m = DateTime(_selectedMonth.year, _selectedMonth.month - (5 - i));
      return DateTime(m.year, m.month);
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthlySummaryProvider);
          ref.invalidate(bucketBalancesProvider);
          ref.invalidate(personBalancesProvider);
          ref.invalidate(tagTotalsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Insights'),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Period selector ─────────────────────────────────
                    _PeriodSelector(
                      selectedMonth: _selectedMonth,
                      onPrevious: _previousMonth,
                      onNext: _isCurrentMonth ? null : _nextMonth,
                      onPickMonth: _pickMonth,
                      onThisMonth: () => setState(() =>
                        _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month)),
                      onLastMonth: () => setState(() {
                        final now = DateTime.now();
                        _selectedMonth = DateTime(now.year, now.month - 1);
                      }),
                      isCurrentMonth: _isCurrentMonth,
                    ),

                    const SizedBox(height: 20),

                    // ── Summary cards ────────────────────────────────────
                    summaryAsync.when(
                      loading: () => Row(children: [
                        Expanded(child: skeletonList(count: 1, card: true)),
                        const SizedBox(width: 12),
                        Expanded(child: skeletonList(count: 1, card: true)),
                        const SizedBox(width: 12),
                        Expanded(child: skeletonList(count: 1, card: true)),
                      ]),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (s) => Row(
                        children: [
                          Expanded(child: _SummaryCard(
                            label: 'Income',
                            paisa: s.incomePaisa,
                            color: Colors.green.shade500,
                            icon: Icons.arrow_downward_rounded,
                          )),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryCard(
                            label: 'Expense',
                            paisa: s.expensePaisa,
                            color: Colors.red.shade400,
                            icon: Icons.arrow_upward_rounded,
                          )),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryCard(
                            label: 'Net',
                            paisa: s.netPaisa,
                            color: s.netPaisa >= 0
                              ? Colors.green.shade500 : Colors.red.shade400,
                            icon: Icons.account_balance_rounded,
                          )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Income vs Expense bar chart ─────────────────────
                    _SectionHeader(
                      title: 'Income vs Expense',
                      subtitle: 'Last 6 months',
                    ),
                    const SizedBox(height: 12),
                    _IncomeExpenseBarChart(months: monthHistory),

                    const SizedBox(height: 28),

                    // ── Tag spending donut chart ──────────────────────────
                    _SectionHeader(
                      title: 'Spending by Category',
                      subtitle: DateFormat('MMMM yyyy').format(_selectedMonth),
                    ),
                    const SizedBox(height: 12),
                    tagAsync.when(
                      loading: () => const SkeletonBox(width: double.infinity, height: 220),
                      error: (_, __) => const _EmptyState(message: 'No tag data'),
                      data: (tags) {
                        final withAmount = tags.where((t) => t.totalPaisa > 0).toList();
                        if (withAmount.isEmpty) {
                          return const _EmptyState(
                            message: 'No tagged expenses this month');
                        }
                        return _TagDonutChart(
                          tags: withAmount,
                          touchedIndex: _touchedPieIndex,
                          onTouch: (i) => setState(() => _touchedPieIndex = i),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── Bucket balances ───────────────────────────────────
                    _SectionHeader(
                      title: 'Bucket Balances',
                      subtitle: 'Live',
                    ),
                    const SizedBox(height: 12),
                    bucketAsync.when(
                      loading: () => skeletonList(count: 3),
                      error: (_, __) => const _EmptyState(message: 'Failed to load'),
                      data: (buckets) {
                        if (buckets.isEmpty) {
                          return const _EmptyState(message: 'No buckets');
                        }
                        final maxBal = buckets
                          .map((b) => b.balancePaisa.abs())
                          .fold(0, (a, b) => a > b ? a : b);
                        return _BucketBalanceBars(
                          buckets: buckets, maxBalance: maxBal);
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── People balances ───────────────────────────────────
                    _SectionHeader(
                      title: 'People Balances',
                      subtitle: 'Outstanding loans',
                    ),
                    const SizedBox(height: 12),
                    personAsync.when(
                      loading: () => skeletonList(count: 3),
                      error: (_, __) => const _EmptyState(message: 'Failed to load'),
                      data: (people) {
                        final active = people
                          .where((p) => p.netPaisa != 0).toList();
                        if (active.isEmpty) {
                          return const _EmptyState(
                            icon: Icons.handshake_rounded,
                            message: 'All settled up! 🎉');
                        }
                        return Column(
                          children: active.map((p) => _PersonBalanceRow(person: p)).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Period selector widget ──────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPickMonth;
  final VoidCallback onThisMonth;
  final VoidCallback onLastMonth;
  final bool isCurrentMonth;

  const _PeriodSelector({
    required this.selectedMonth,
    required this.onPrevious,
    this.onNext,
    required this.onPickMonth,
    required this.onThisMonth,
    required this.onLastMonth,
    required this.isCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isLastMonth = selectedMonth.month == now.month - 1 &&
                        selectedMonth.year == now.year;

    return Column(
      children: [
        // Month navigation row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: onPrevious,
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onPickMonth,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMMM').format(selectedMonth),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        DateFormat('yyyy').format(selectedMonth),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded,
                  color: onNext == null ? cs.onSurfaceVariant.withValues(alpha: 0.3) : null),
                onPressed: onNext,
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Quick chips
        Row(
          children: [
            _QuickChip(
              label: 'This Month',
              selected: isCurrentMonth,
              onTap: onThisMonth,
            ),
            const SizedBox(width: 8),
            _QuickChip(
              label: 'Last Month',
              selected: isLastMonth,
              onTap: onLastMonth,
            ),
            const SizedBox(width: 8),
            _QuickChip(
              label: 'Custom',
              selected: false,
              icon: Icons.calendar_month_rounded,
              onTap: onPickMonth,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.selected,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                color: selected ? Colors.white : cs.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : cs.onSurfaceVariant,
              )),
          ],
        ),
      ),
    );
  }
}

// ── Summary card ────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final int paisa;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.paisa,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              MoneyFormatter.format(paisa),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Text(subtitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// ── Income vs Expense bar chart (6 months) ──────────────────────────────────

class _IncomeExpenseBarChart extends ConsumerWidget {
  final List<DateTime> months;

  const _IncomeExpenseBarChart({required this.months});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Fetch summaries for each month
    final summaries = months.map((m) {
      final key = DateFormat('yyyy-MM').format(m);
      return ref.watch(monthlySummaryProvider(key));
    }).toList();

    final allLoaded = summaries.every((s) => s.hasValue);
    if (!allLoaded) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    double maxVal = 0;
    for (final s in summaries) {
      s.whenData((d) {
        if (d.incomePaisa > maxVal) maxVal = d.incomePaisa.toDouble();
        if (d.expensePaisa > maxVal) maxVal = d.expensePaisa.toDouble();
      });
    }
    if (maxVal == 0) maxVal = 1;

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < months.length; i++) {
      double income = 0, expense = 0;
      summaries[i].whenData((d) {
        income = d.incomePaisa.toDouble();
        expense = d.expensePaisa.toDouble();
      });
      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Colors.green.shade400,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: expense,
            color: Colors.red.shade400,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      ));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendDot(color: Colors.green.shade400, label: 'Income'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.red.shade400, label: 'Expense'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: groups,
                maxY: maxVal * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: cs.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (val, _) => Text(
                        _shortMoney(val.toInt()),
                        style: TextStyle(
                          fontSize: 9,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('MMM').format(months[idx]),
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => cs.surface,
                    tooltipBorder: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0 ? 'Income' : 'Expense';
                      return BarTooltipItem(
                        '$label\n${MoneyFormatter.format(rod.toY.toInt())}',
                        TextStyle(
                          color: rod.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortMoney(int paisa) {
    final taka = paisa / 100;
    if (taka >= 100000) return '${(taka / 100000).toStringAsFixed(1)}L';
    if (taka >= 1000) return '${(taka / 1000).toStringAsFixed(0)}K';
    return taka.toStringAsFixed(0);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label,
        style: TextStyle(fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ],
  );
}

// ── Tag donut chart ─────────────────────────────────────────────────────────

const _chartColors = [
  Color(0xFF6366F1),
  Color(0xFFEC4899),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF3B82F6),
  Color(0xFFEF4444),
  Color(0xFF8B5CF6),
  Color(0xFF14B8A6),
];

class _TagDonutChart extends StatelessWidget {
  final List<dynamic> tags;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _TagDonutChart({
    required this.tags,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = tags.fold<int>(0, (s, t) => s + (t.totalPaisa as int));

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < tags.length; i++) {
      final isTouched = i == touchedIndex;
      final color = _chartColors[i % _chartColors.length];
      final pct = (tags[i].totalPaisa as int) / total * 100;
      sections.add(PieChartSectionData(
        value: (tags[i].totalPaisa as int).toDouble(),
        color: color,
        radius: isTouched ? 52 : 44,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: isTouched
          ? null
          : null,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 48,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          if (event is FlTapUpEvent) {
                            if (response?.touchedSection != null) {
                              onTouch(response!.touchedSection!.touchedSectionIndex);
                            } else {
                              onTouch(-1);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant)),
                      Text(
                        MoneyFormatter.format(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      ...tags.take(5).toList().asMap().entries.map((e) {
                        final color = _chartColors[e.key % _chartColors.length];
                        final pct = (e.value.totalPaisa as int) / total * 100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  e.value.name as String,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (tags.length > 5)
                        Text('+${tags.length - 5} more',
                          style: TextStyle(
                            fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bar breakdown below donut
          ...tags.take(8).toList().asMap().entries.map((e) {
            final color = _chartColors[e.key % _chartColors.length];
            final pct = (e.value.totalPaisa as int) / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(e.value.name as String,
                          style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500)),
                      ),
                      Text(
                        MoneyFormatter.format(e.value.totalPaisa as int),
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Bucket balance bars ─────────────────────────────────────────────────────

class _BucketBalanceBars extends StatelessWidget {
  final List<dynamic> buckets;
  final int maxBalance;

  const _BucketBalanceBars({required this.buckets, required this.maxBalance});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: buckets.map((b) {
          final bal = b.balancePaisa as int;
          final isPositive = bal >= 0;
          final pct = maxBalance > 0 ? bal.abs() / maxBalance : 0.0;
          final color = isPositive ? Colors.green.shade500 : Colors.red.shade400;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(b.name as String,
                      style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w500))),
                    Text(
                      MoneyFormatter.format(bal),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Person balance row ──────────────────────────────────────────────────────

class _PersonBalanceRow extends StatelessWidget {
  final dynamic person;
  const _PersonBalanceRow({required this.person});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final net = person.netPaisa as int;
    final isPositive = net > 0;
    final color = isPositive ? Colors.green.shade500 : Colors.red.shade400;
    final label = isPositive
      ? 'Owes you ${MoneyFormatter.format(net)}'
      : 'You owe ${MoneyFormatter.format(net.abs())}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              (person.name as String)[0].toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(label,
                style: TextStyle(fontSize: 12, color: color)),
            ],
          )),
          Icon(
            isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color, size: 18,
          ),
        ],
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({
    required this.message,
    this.icon = Icons.bar_chart_rounded,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 100,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28,
          color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(message,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
      ],
    ),
  );
}
