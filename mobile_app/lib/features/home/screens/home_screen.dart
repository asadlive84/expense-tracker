import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/core/storage/default_source_storage.dart';
import 'package:expense_tracker_app/l10n/app_localizations.dart';
import 'package:expense_tracker_app/features/auth/data/auth_api.dart';
import 'package:expense_tracker_app/features/auth/providers/user_profile_provider.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:expense_tracker_app/features/reminders/providers/reminders_provider.dart';
import 'package:expense_tracker_app/features/reports/providers/reports_provider.dart';
import 'package:expense_tracker_app/features/tags/providers/tags_provider.dart';
import 'package:expense_tracker_app/features/transactions/providers/transactions_provider.dart';
import 'package:expense_tracker_app/features/transactions/screens/quick_add_sheet.dart';
import 'package:expense_tracker_app/shared/constants/tx_type_config.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app/core/formatters/date_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _timeframe = 'today'; // 'yesterday' | 'today' | 'month' | 'custom'
  DateTime? _customFrom;
  DateTime? _customTo;

  void _openSheet({String? type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickAddSheet(initialType: type),
    );
  }

  void _openTagManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TagManagementSheet(),
    );
  }

  void _openTagDetail(TagTotal tag, String fromUtc, String toUtc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TagDetailSheet(tag: tag, fromUtc: fromUtc, toUtc: toUtc),
    );
  }

  void _openMoneySourcesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MoneySourcesSheet(),
    );
  }

  // ── Date range computation (called once per build with a single DateTime.now()) ──

  /// Computes (fromUtc, toUtc) for the current timeframe using a single "now"
  /// snapshot so both boundaries are always consistent within a build frame.
  (String, String) _computeRange() {
    final now = DateTime.now();

    String startOf(DateTime d) =>
        DateTime(d.year, d.month, d.day).toUtc().toIso8601String();
    String endOf(DateTime d) =>
        DateTime(d.year, d.month, d.day, 23, 59, 59).toUtc().toIso8601String();

    switch (_timeframe) {
      case 'yesterday':
        final y = DateTime(now.year, now.month, now.day - 1);
        return (startOf(y), endOf(y));
      case 'month':
        return (startOf(DateTime(now.year, now.month, 1)), endOf(now));
      case 'custom':
        if (_customFrom != null && _customTo != null) {
          return (startOf(_customFrom!), endOf(_customTo!));
        }
        return (startOf(now), endOf(now)); // fallback to today
      default: // today
        return (startOf(now), endOf(now));
    }
  }

  String get _customLabel {
    if (_customFrom == null || _customTo == null) return 'Custom';
    final fmt = DateFormat('d MMM');
    final from = fmt.format(_customFrom!);
    final to   = fmt.format(_customTo!);
    return from == to ? from : '$from – $to';
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: (_customFrom != null && _customTo != null)
          ? DateTimeRange(start: _customFrom!, end: _customTo!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            ),
      builder: (ctx, child) => Theme(data: Theme.of(ctx), child: child!),
    );
    if (range == null || !mounted) return;
    setState(() {
      _customFrom = range.start;
      _customTo   = range.end;
      _timeframe  = 'custom';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Compute range ONCE — single DateTime.now() snapshot for the entire frame.
    final (fromUtc, toUtc) = _computeRange();
    final rangeKey = '$fromUtc|$toUtc';

    // Single provider keyed on the active date range.
    // Changing timeframe → rangeKey changes → different provider instance → data syncs.
    final activeAsync = ref.watch(dateRangeSummaryProvider(rangeKey));
    final bucketsAsync   = ref.watch(bucketsProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final userName       = ref.watch(userNameProvider).value;

    final activeBuckets = bucketsAsync.value
            ?.where((b) => b.archivedAt == null)
            .toList() ??
        [];
    final noSources = bucketsAsync.hasValue && activeBuckets.isEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dateRangeSummaryProvider); // invalidates all cached ranges
          ref.invalidate(bucketBalancesProvider);
          ref.invalidate(bucketsProvider);
          ref.invalidate(remindersProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              titleSpacing: 20,
              title: Text(
                userName != null && userName.isNotEmpty
                    ? 'Hi, $userName 👋'
                    : S.of(context)?.appName ?? 'Expense Tracker',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              actions: [
                // Quick-access to money sources
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  tooltip: 'Money Sources',
                  onPressed: _openMoneySourcesSheet,
                ),
              ],
            ),

            if (noSources)
              SliverFillRemaining(
                child: _EmptySourcesState(
                    onTap: () => context.push('/buckets')),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Name prompt
                      if (userName == null || userName.isEmpty) ...[
                        const SizedBox(height: 8),
                        _AddNameCard(
                            onSaved: () => ref.invalidate(userNameProvider)),
                      ],

                      const SizedBox(height: 12),

                      // ── Balance card (toggleable) ─────────────────────────
                      _BalanceSummaryCard(
                        balancesAsync: ref.watch(bucketBalancesProvider),
                        defaultName: ref.watch(defaultMoneySourceProvider) == null
                            ? null
                            : bucketsAsync.value
                                ?.where((b) =>
                                    b.id == ref.watch(defaultMoneySourceProvider))
                                .firstOrNull
                                ?.name,
                        onTapSources: _openMoneySourcesSheet,
                      ),

                      const SizedBox(height: 20),

                      // ── Timeframe toggle (4 options) ─────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          _TimeChip(
                            label: 'Yesterday',
                            selected: _timeframe == 'yesterday',
                            onTap: () => setState(() => _timeframe = 'yesterday'),
                          ),
                          const SizedBox(width: 8),
                          _TimeChip(
                            label: 'Today',
                            selected: _timeframe == 'today',
                            onTap: () => setState(() => _timeframe = 'today'),
                          ),
                          const SizedBox(width: 8),
                          _TimeChip(
                            label: 'This Month',
                            selected: _timeframe == 'month',
                            onTap: () => setState(() => _timeframe = 'month'),
                          ),
                          const SizedBox(width: 8),
                          _TimeChip(
                            label: _customLabel,
                            icon: _timeframe == 'custom'
                                ? null
                                : Icons.calendar_month_outlined,
                            selected: _timeframe == 'custom',
                            onTap: _pickCustomRange,
                          ),
                        ]),
                      ),

                      const SizedBox(height: 20),

                      // ── Two metric cards (animated swap) ─────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: animation, curve: Curves.easeOut),
                              child: child,
                            ),
                        child: KeyedSubtree(
                          key: ValueKey(_timeframe),
                          child: activeAsync.when(
                            loading: () => Row(children: [
                              Expanded(child: skeletonList(
                                  count: 1, card: true, shrinkWrap: true)),
                              const SizedBox(width: 12),
                              Expanded(child: skeletonList(
                                  count: 1, card: true, shrinkWrap: true)),
                            ]),
                            error: (e, _) => GestureDetector(
                              onTap: () => ref.invalidate(dateRangeSummaryProvider),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Icon(Icons.refresh, size: 16, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text('Tap to retry',
                                      style: TextStyle(
                                          fontSize: 13, color: cs.onSurfaceVariant)),
                                ]),
                              ),
                            ),
                            data: (s) => Row(children: [
                              Expanded(child: _MetricCard(
                                label: 'Income',
                                paisa: s.incomePaisa,
                                color: const Color(0xFF2E7D32),
                                onTap: () => _openSheet(type: 'income'),
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: _MetricCard(
                                label: 'Expense',
                                paisa: s.expensePaisa,
                                color: const Color(0xFFC62828),
                                onTap: () => _openSheet(type: 'expense'),
                              )),
                            ]),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Tag breakdown (animated swap) ─────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: animation, curve: Curves.easeOut),
                              child: child,
                            ),
                        child: KeyedSubtree(
                          key: ValueKey('tags_$_timeframe'),
                          child: activeAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (s) {
                            final tags = s.byTag
                                .where((t) => t.totalPaisa > 0)
                                .toList()
                              ..sort((a, b) =>
                                  b.totalPaisa.compareTo(a.totalPaisa));
                            if (tags.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text('By Tag',
                                      style: Theme.of(context)
                                          .textTheme.labelMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          letterSpacing: 0.5)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: _openTagManagement,
                                    child: Text('Manage',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: cs.onSurfaceVariant)),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                ...tags.take(5).map((tag) => _TodayTagRow(
                                  tag: tag,
                                  onTap: () => _openTagDetail(
                                      tag, fromUtc, toUtc),
                                )),
                              ],
                            );
                          },
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Upcoming reminders ───────────────────────────────
                      remindersAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (reminders) {
                          final upcoming = reminders
                              .where((r) => r.nextDueAt.isBefore(
                                  DateTime.now().add(const Duration(days: 7))))
                              .take(3).toList();
                          if (upcoming.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Upcoming',
                                  style: Theme.of(context)
                                      .textTheme.labelMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 8),
                              ...upcoming.map((r) => _ReminderRow(
                                    reminder: r,
                                    onPay: () => _payReminder(r),
                                  )),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _payReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pay "${reminder.title}"?'),
        content: reminder.amountPaisa != null
            ? Text('Amount: ${MoneyFormatter.format(reminder.amountPaisa!)}')
            : const Text('Amount will be recorded as set on the reminder.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(remindersProvider.notifier).pay(
                    reminder.id, occurredAt: DateTime.now());
                if (mounted) showSuccessSnackBar(context, 'Payment recorded!');
              } catch (e) {
                if (mounted) showErrorSnackBar(context, e);
              }
            },
            child: Text(S.of(context)?.pay ?? 'Pay'),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptySourcesState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptySourcesState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, size: 52, color: cs.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No money sources yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the + above to add your first source\n(e.g. Cash, Bank Account)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add name prompt ────────────────────────────────────────────────────────────

class _AddNameCard extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _AddNameCard({required this.onSaved});

  @override
  ConsumerState<_AddNameCard> createState() => _AddNameCardState();
}

class _AddNameCardState extends ConsumerState<_AddNameCard> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ref.read(userNameProvider.notifier).setName(_ctrl.text.trim());
    widget.onSaved();
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.waving_hand_rounded, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              S.of(context)?.whatShouldWeCallYou ?? 'What should we call you?',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  isDense: true,
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12)),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(S.of(context)?.save ?? 'Save'),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

// ── Balance summary card with show/hide toggle ────────────────────────────────

class _BalanceSummaryCard extends StatefulWidget {
  final AsyncValue<List<BucketBalance>> balancesAsync;
  final String? defaultName;
  final VoidCallback onTapSources;

  const _BalanceSummaryCard({
    required this.balancesAsync,
    required this.defaultName,
    required this.onTapSources,
  });

  @override
  State<_BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<_BalanceSummaryCard> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return widget.balancesAsync.when(
      loading: () => const SkeletonCard(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final total = items.fold(0, (s, b) => s + b.balancePaisa);

        if (!_visible) {
          // Collapsed state — just a slim tap bar
          return GestureDetector(
            onTap: () => setState(() => _visible = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('Balance hidden',
                    style: TextStyle(
                        fontSize: 13, color: cs.onSurfaceVariant)),
                const Spacer(),
                Icon(Icons.visibility_outlined,
                    size: 16, color: cs.onSurfaceVariant),
              ]),
            ),
          );
        }

        return _HeroCard(
          total: total,
          bucketCount: items.length,
          defaultSourceName: widget.defaultName,
          onTap: widget.onTapSources,
          onHide: () => setState(() => _visible = false),
        );
      },
    );
  }
}

// ── Hero balance card ──────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final int total;
  final int bucketCount;
  final String? defaultSourceName;
  final VoidCallback onTap;
  final VoidCallback? onHide;

  const _HeroCard({
    required this.total,
    required this.bucketCount,
    this.defaultSourceName,
    required this.onTap,
    this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Total Balance',
                  style: TextStyle(
                      color: cs.onPrimary.withValues(alpha: 0.8),
                      fontSize: 14)),
              const Spacer(),
              // Hide button
              if (onHide != null)
                GestureDetector(
                  onTap: onHide,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.visibility_off_outlined,
                        size: 16,
                        color: cs.onPrimary.withValues(alpha: 0.6)),
                  ),
                ),
            ]),
            const SizedBox(height: 8),
            Text(
              MoneyFormatter.format(total),
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text('across $bucketCount source${bucketCount == 1 ? '' : 's'}',
                style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.7),
                    fontSize: 13)),
            if (defaultSourceName != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.star_rounded, size: 12,
                    color: cs.onPrimary.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Text('Default: $defaultSourceName',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onPrimary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Timeframe chip (4-option toggle) ──────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Metric card — large, clean, tappable ──────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String label;
  final int paisa;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({
    required this.label, required this.paisa,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3)),
          const SizedBox(height: 8),
          Text(
            MoneyFormatter.format(paisa),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700));
}

class _ReminderRow extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onPay;
  const _ReminderRow({required this.reminder, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final isOverdue = reminder.nextDueAt.isBefore(DateTime.now());
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          isOverdue ? Icons.warning_rounded : Icons.alarm_rounded,
          color: isOverdue ? Colors.red : Colors.amber,
        ),
        title: Text(reminder.title,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          DateFormatter.dateOnly(reminder.nextDueAt),
          style:
              TextStyle(fontSize: 12, color: isOverdue ? Colors.red : null),
        ),
        trailing: TextButton(
          onPressed: onPay,
          child: Text(S.of(context)?.pay ?? 'Pay'),
        ),
      ),
    );
  }
}

// ── Money Sources sheet ────────────────────────────────────────────────────────

class _MoneySourcesSheet extends ConsumerWidget {
  const _MoneySourcesSheet();

  Future<void> _setDefault(BuildContext context, WidgetRef ref, String id) async {
    ref.read(defaultMoneySourceProvider.notifier).state = id;
    await DefaultSourceStorage.write(id);
    try {
      await ref.read(authApiProvider).updateProfile(defaultBucketId: id);
    } catch (_) {}
  }

  void _showAddForm(BuildContext context, WidgetRef ref) {
    final nameCtrl    = TextEditingController();
    final balanceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('New Money Source',
                  style: Theme.of(ctx).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Cash, Bank, bKash…',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: balanceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_outlined),
                  labelText: 'Starting Balance (৳)',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  final bal = (double.tryParse(balanceCtrl.text) ?? 0);
                  // Close the add form first (ctx is the add form's context — still valid)
                  Navigator.pop(ctx);
                  try {
                    await ref.read(bucketsProvider.notifier)
                        .create(name, (bal * 100).round());
                    // Sources sheet auto-refreshes via bucketsProvider watch
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create: $e')),
                      );
                    }
                  }
                },
                child: const Text('Create',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buckets   = ref.watch(bucketsProvider).value ?? [];
    final active    = buckets.where((b) => b.archivedAt == null).toList();
    final balances  = ref.watch(bucketBalancesProvider).value ?? [];
    final defaultId = ref.watch(defaultMoneySourceProvider);
    final cs        = Theme.of(context).colorScheme;

    final balanceMap = {for (final b in balances) b.bucketId: b.balancePaisa};

    // Default source always floats to top
    final sorted = [...active]..sort((a, b) {
        if (a.id == defaultId) return -1;
        if (b.id == defaultId) return 1;
        return a.name.compareTo(b.name);
      });

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
            child: Row(
              children: [
                Text('Money Sources',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No money sources yet.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 72,
                    color: cs.outlineVariant.withValues(alpha: 0.4)),
                itemBuilder: (_, i) {
                  final b         = sorted[i];
                  final isDefault = b.id == defaultId;
                  final balance   = balanceMap[b.id] ?? b.startingBalancePaisa;
                  return _SourceRow(
                    bucket: b,
                    balance: balance,
                    isDefault: isDefault,
                    onSetDefault: isDefault
                        ? null
                        : () => _setDefault(context, ref, b.id),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _SourceDetailSheet(
                        bucket: b,
                        currentBalance: balance,
                      ),
                    ),
                  );
                },
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              // Do NOT pop the sources sheet first — context would be dead.
              // Show the add form on top; sources sheet auto-refreshes on create.
              onPressed: () => _showAddForm(context, ref),
              child: const Text('Add Money Source'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single source row ──────────────────────────────────────────────────────────

class _SourceRow extends StatelessWidget {
  final Bucket bucket;
  final int balance;
  final bool isDefault;
  final VoidCallback? onSetDefault;
  final VoidCallback? onTap;

  const _SourceRow({
    required this.bucket,
    required this.balance,
    required this.isDefault,
    required this.onSetDefault,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isDefault ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          color: isDefault ? cs.primary : cs.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(bucket.name,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDefault ? cs.primary : cs.onSurface),
                overflow: TextOverflow.ellipsis),
          ),
          if (isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Default',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: cs.primary)),
            ),
          ],
        ],
      ),
      subtitle: Text(
        MoneyFormatter.format(balance),
        style: TextStyle(
            fontSize: 13,
            color: balance >= 0 ? Colors.green.shade600 : Colors.red.shade400,
            fontWeight: FontWeight.w500),
      ),
      trailing: isDefault
          ? Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 26)
          : IconButton(
              icon: Icon(Icons.star_outline_rounded,
                  color: cs.onSurfaceVariant, size: 26),
              tooltip: 'Set as Default',
              onPressed: onSetDefault,
            ),
    );
  }
}

// ── Today at-a-glance chip ─────────────────────────────────────────────────────

// ── Today chip — borderless, airy ─────────────────────────────────────────────

class _TodayChip extends StatelessWidget {
  final String label;
  final int paisa;
  final Color color;
  const _TodayChip({required this.label, required this.paisa,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(MoneyFormatter.format(paisa),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: -0.3)),
      ]),
    );
  }
}

// ── Today tag row — minimal tap target ────────────────────────────────────────

class _TodayTagRow extends StatelessWidget {
  final TagTotal tag;
  final VoidCallback onTap;
  const _TodayTagRow({required this.tag, required this.onTap});

  static const _palette = [
    Color(0xFF6750A4), Color(0xFF00897B), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final color = _palette[tag.name.length % _palette.length];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tag.name,
                style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ),
          Text(MoneyFormatter.format(tag.totalPaisa),
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}

// ── Top Tags bar chart — minimalist, tappable ─────────────────────────────────

class _TagsBarChart extends StatelessWidget {
  final List<TagTotal> tags;
  final String fromUtc;
  final String toUtc;
  final void Function(TagTotal)? onTagTap;

  const _TagsBarChart({
    required this.tags,
    required this.fromUtc,
    required this.toUtc,
    this.onTagTap,
  });

  static const _palette = [
    Color(0xFF6750A4), Color(0xFF00897B), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final max = tags.fold(0, (m, t) => t.totalPaisa > m ? t.totalPaisa : m).toDouble();

    return Column(
      children: tags.asMap().entries.map((e) {
        final i     = e.key;
        final tag   = e.value;
        final ratio = max > 0 ? tag.totalPaisa / max : 0.0;
        final color = _palette[i % _palette.length];

        return InkWell(
          onTap: onTagTap != null ? () => onTagTap!(tag) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              SizedBox(
                width: 72,
                child: Text(tag.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio.clamp(0.04, 1.0),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 68,
                child: Text(MoneyFormatter.format(tag.totalPaisa),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color),
                    textAlign: TextAlign.right),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, size: 14, color: cs.onSurfaceVariant),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tag Detail Sheet ───────────────────────────────────────────────────────────

class _TagDetailSheet extends ConsumerWidget {
  final TagTotal tag;
  final String fromUtc;
  final String toUtc;
  const _TagDetailSheet(
      {required this.tag, required this.fromUtc, required this.toUtc});

  static const _palette = [
    Color(0xFF6750A4), Color(0xFF00897B), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs    = Theme.of(context).colorScheme;
    final color = _palette[tag.name.length % _palette.length];
    final txApi = ref.watch(transactionApiProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 12),
              child: Row(children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(tag.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(MoneyFormatter.format(tag.totalPaisa),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: txApi.getTransactions(limit: 50, filters: {
                  'tag_id': tag.tagId,
                  'from': fromUtc,
                  'to': toUtc,
                }),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  final items = (snap.data?['items'] as List?) ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.label_off_outlined,
                              size: 40, color: cs.onSurfaceVariant),
                          const SizedBox(height: 10),
                          Text('No transactions',
                              style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.only(top: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 56,
                        color: cs.outlineVariant.withValues(alpha: 0.4)),
                    itemBuilder: (_, i) {
                      final tx = Transaction.fromJson(
                          items[i] as Map<String, dynamic>);
                      final cfg  = txTypeConfigs[tx.type];
                      final tc   = cfg?.color ?? cs.primary;
                      final isPos = ['income', 'repayment_received',
                          'loan_taken'].contains(tx.type);
                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              color: tc.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(cfg?.icon ?? Icons.receipt,
                              color: tc, size: 16),
                        ),
                        title: Text(
                            tx.note.isNotEmpty ? tx.note : (cfg?.label ?? tx.type),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(DateFormatter.smart(tx.occurredAt),
                            style: const TextStyle(fontSize: 11)),
                        trailing: Text(
                          '${isPos ? '+' : '−'}${MoneyFormatter.format(tx.amountPaisa)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isPos
                                  ? Colors.green.shade600
                                  : Colors.red.shade400),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Money Source Detail Sheet ──────────────────────────────────────────────────

class _SourceDetailSheet extends ConsumerStatefulWidget {
  final Bucket bucket;
  final int currentBalance;
  const _SourceDetailSheet({required this.bucket, required this.currentBalance});

  @override
  ConsumerState<_SourceDetailSheet> createState() => _SourceDetailSheetState();
}

class _SourceDetailSheetState extends ConsumerState<_SourceDetailSheet> {
  String _period = 'month'; // 'today' | 'month' | 'last_month' | 'all'

  String get _fromUtc {
    final now = DateTime.now();
    return switch (_period) {
      'today'      => DateTime(now.year, now.month, now.day).toUtc().toIso8601String(),
      'last_month' => DateTime(now.year, now.month - 1, 1).toUtc().toIso8601String(),
      'all'        => DateTime(2020).toUtc().toIso8601String(),
      _            => DateTime(now.year, now.month, 1).toUtc().toIso8601String(),
    };
  }

  String get _toUtc {
    final now = DateTime.now();
    return switch (_period) {
      'today'      => DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc().toIso8601String(),
      'last_month' => DateTime(now.year, now.month, 0, 23, 59, 59).toUtc().toIso8601String(),
      'all'        => DateTime(now.year + 1).toUtc().toIso8601String(),
      _            => DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc().toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Transactions filtered for this bucket + period
    final filters = <String, dynamic>{
      'bucket_id': widget.bucket.id,
      'from': _fromUtc,
      'to': _toUtc,
    };

    // Fetch summary for this period
    final summaryKey = '$_fromUtc|$_toUtc';
    final summaryAsync = ref.watch(dateRangeSummaryProvider(summaryKey));

    // Fetch recent transactions for this source
    final txApi = ref.watch(transactionApiProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2)),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.account_balance_wallet_rounded,
                      color: cs.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.bucket.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(MoneyFormatter.format(widget.currentBalance),
                        style: TextStyle(
                            fontSize: 13,
                            color: widget.currentBalance >= 0
                                ? Colors.green.shade600
                                : Colors.red.shade400,
                            fontWeight: FontWeight.w600)),
                  ],
                )),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ]),
            ),

            // Period chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final (key, label) in [
                    ('today', 'Today'),
                    ('month', 'This Month'),
                    ('last_month', 'Last Month'),
                    ('all', 'All Time'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _period = key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: _period == key
                                ? cs.primary
                                : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _period == key
                                      ? cs.onPrimary
                                      : cs.onSurface)),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // Period summary
            summaryAsync.when(
              loading: () => const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const SizedBox.shrink(),
              data: (s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _MiniStat(label: 'In', paisa: s.incomePaisa,
                      color: Colors.green.shade600),
                  const SizedBox(width: 10),
                  _MiniStat(label: 'Out', paisa: s.expensePaisa,
                      color: Colors.red.shade400),
                  const SizedBox(width: 10),
                  _MiniStat(label: 'Net', paisa: s.netPaisa,
                      color: s.netPaisa >= 0
                          ? Colors.green.shade600
                          : Colors.red.shade400),
                ]),
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // Transaction list for this source
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: txApi.getTransactions(
                    limit: 30, filters: filters),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  final items = snap.data == null
                      ? <dynamic>[]
                      : snap.data!['items'] as List? ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Text('No transactions',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    );
                  }
                  return ListView.separated(
                    controller: ctrl,
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, indent: 56,
                            color: cs.outlineVariant.withValues(alpha: 0.4)),
                    itemBuilder: (_, i) {
                      final tx = Transaction.fromJson(
                          items[i] as Map<String, dynamic>);
                      final cfg   = txTypeConfigs[tx.type];
                      final color = cfg?.color ?? cs.primary;
                      final isPos = ['income', 'repayment_received',
                          'loan_taken'].contains(tx.type);
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10)),
                          child: Icon(cfg?.icon ?? Icons.receipt,
                              color: color, size: 16),
                        ),
                        title: Text(
                            tx.note.isNotEmpty ? tx.note
                                : (cfg?.label ?? tx.type),
                            style: const TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                            DateFormatter.smart(tx.occurredAt),
                            style: const TextStyle(fontSize: 11)),
                        trailing: Text(
                          '${isPos ? '+' : '−'}${MoneyFormatter.format(tx.amountPaisa)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isPos
                                  ? Colors.green.shade600
                                  : Colors.red.shade400),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int paisa;
  final Color color;
  const _MiniStat({required this.label, required this.paisa,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: color)),
          Text(MoneyFormatter.format(paisa.abs()),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ]),
      ),
    );
  }
}

// ── Tag Management Sheet ───────────────────────────────────────────────────────

class _TagManagementSheet extends ConsumerWidget {
  const _TagManagementSheet();

  static const _palette = [
    Color(0xFF6750A4), Color(0xFF00897B), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF1E88E5),
  ];

  Color _tagColor(String name) => _palette[name.length % _palette.length];

  void _showForm(BuildContext context, WidgetRef ref, {Tag? tag}) {
    final ctrl  = TextEditingController(text: tag?.name ?? '');
    final isEdit = tag != null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Center(child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2)),
            )),
            Text(isEdit ? 'Rename Tag' : 'New Tag',
                style: Theme.of(ctx).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. food, transport, family',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Tag name',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final name = ctrl.text.trim().toLowerCase();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  if (isEdit) {
                    await ref.read(tagsProvider.notifier).editTag(tag!.id, name: name);
                  } else {
                    await ref.read(tagsProvider.notifier).create(name);
                  }
                } catch (e) {
                  if (context.mounted) showErrorSnackBar(context, e);
                }
              },
              child: Text(isEdit ? 'Rename' : 'Create'),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Tag tag,
      {required bool hasTransactions}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${tag.name}"?'),
        content: Text(
          hasTransactions
              ? '⚠️ This tag is linked to existing transactions.\n\n'
                  'The tag will be removed, but all your transactions '
                  'will remain safe in the ledger as untagged items.'
              : 'This tag will be permanently removed.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(tagsProvider.notifier).deleteTag(tag.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${tag.name}" deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) showErrorSnackBar(context, e);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync    = ref.watch(tagsProvider);
    final cs           = Theme.of(context).colorScheme;

    // Get this month's tag totals to detect which tags have transactions
    final now  = DateTime.now();
    final from = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    final to   = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
    final totalsAsync = ref.watch(tagTotalsProvider('$from,$to'));
    final totalsMap   = <String, int>{};
    totalsAsync.whenData((items) {
      for (final t in items) totalsMap[t.tagId] = t.totalPaisa;
    });

    final tags   = (tagsAsync.value ?? []).whereType<Tag>().toList();
    final active = tags.where((t) => t.archivedAt == null).toList();

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: Row(children: [
              Text('Tags',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () => _showForm(context, ref),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                child: const Text('New'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          const Divider(height: 1),

          if (active.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: Text('No tags yet.',
                  style: TextStyle(color: Colors.grey))),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: active.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1, indent: 60,
                    color: cs.outlineVariant.withValues(alpha: 0.4)),
                itemBuilder: (_, i) {
                  final tag     = active[i];
                  final total   = totalsMap[tag.id] ?? 0;
                  final color   = _tagColor(tag.name);
                  final hasTxns = total > 0;

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    title: Text(tag.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: hasTxns
                        ? Text(MoneyFormatter.format(total) + ' this month',
                            style: const TextStyle(fontSize: 11))
                        : null,
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showForm(context, ref, tag: tag),
                        color: cs.onSurfaceVariant,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Rename',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 18,
                            color: hasTxns ? cs.error : cs.onSurfaceVariant),
                        onPressed: () => _confirmDelete(context, ref, tag,
                            hasTransactions: hasTxns),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Delete',
                      ),
                    ]),
                  );
                },
              ),
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20, MediaQuery.of(context).padding.bottom + 12),
            child: TextButton(
              onPressed: () => _showForm(context, ref),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Tag'),
            ),
          ),
        ],
      ),
    );
  }
}
