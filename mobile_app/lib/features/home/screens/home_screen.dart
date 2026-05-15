import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/l10n/app_localizations.dart';
import 'package:expense_tracker_app/features/auth/providers/user_profile_provider.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:expense_tracker_app/features/reminders/providers/reminders_provider.dart';
import 'package:expense_tracker_app/features/reports/providers/reports_provider.dart';
import 'package:expense_tracker_app/features/transactions/screens/quick_add_sheet.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app/core/formatters/date_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openSheet(BuildContext context, {String? type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickAddSheet(initialType: type),
    );
  }

  void _openAddMoneySource(BuildContext context, WidgetRef ref) {
    final nameCtrl    = TextEditingController();
    final balanceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
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
                  prefixIcon: Icon(Icons.savings_outlined),
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
                  final bal = double.tryParse(balanceCtrl.text) ?? 0;
                  Navigator.pop(ctx);
                  try {
                    await ref.read(bucketsProvider.notifier)
                        .create(name, (bal * 100).round());
                  } catch (_) {}
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
    final now       = DateTime.now();
    final monthStr  = DateFormat('yyyy-MM').format(now);

    final summaryAsync   = ref.watch(monthlySummaryProvider(monthStr));
    final balancesAsync  = ref.watch(bucketBalancesProvider);
    final bucketsAsync   = ref.watch(bucketsProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final userName       = ref.watch(userNameProvider).value;
    final defaultId      = ref.watch(defaultMoneySourceProvider);
    final defaultName    = defaultId == null ? null
        : bucketsAsync.value?.where((b) => b.id == defaultId).firstOrNull?.name;

    // Detect zero active money sources
    final activeBuckets = bucketsAsync.value
            ?.where((b) => b.archivedAt == null)
            .toList() ??
        [];
    final noSources = bucketsAsync.hasValue && activeBuckets.isEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthlySummaryProvider);
          ref.invalidate(bucketBalancesProvider);
          ref.invalidate(bucketsProvider);
          ref.invalidate(remindersProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(
                userName != null && userName.isNotEmpty
                    ? 'Hi, $userName 👋'
                    : S.of(context)?.appName ?? 'Expense Tracker',
              ),
            ),

            // ── Empty state — no money sources ────────────────────────────
            if (noSources)
              SliverFillRemaining(
                child: _EmptySourcesState(
                  onTap: () => context.push('/buckets'),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Name prompt
                      if (userName == null || userName.isEmpty)
                        _AddNameCard(
                          onSaved: () => ref.invalidate(userNameProvider)),

                      const SizedBox(height: 4),

                      // ── Net worth hero card (tap → general add) ──────────
                      balancesAsync.when(
                        loading: () => const SkeletonCard(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (items) {
                          final total =
                              items.fold(0, (s, b) => s + b.balancePaisa);
                          return _HeroCard(
                            total: total,
                            bucketCount: items.length,
                            defaultSourceName: defaultName,
                            onTap: () => _openAddMoneySource(context, ref),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Income / Expense cards (contextual tap) ──────────
                      summaryAsync.when(
                        loading: () => Row(children: [
                          Expanded(child: skeletonList(count: 1, card: true, shrinkWrap: true)),
                          const SizedBox(width: 12),
                          Expanded(child: skeletonList(count: 1, card: true, shrinkWrap: true)),
                        ]),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (s) => Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Income',
                                paisa: s.incomePaisa,
                                icon: Icons.arrow_downward_rounded,
                                color: Colors.green.shade600,
                                onTap: () =>
                                    _openSheet(context, type: 'income'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Expenses',
                                paisa: s.expensePaisa,
                                icon: Icons.arrow_upward_rounded,
                                color: Colors.red.shade400,
                                onTap: () =>
                                    _openSheet(context, type: 'expense'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Upcoming reminders ───────────────────────────────
                      remindersAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (reminders) {
                          final upcoming = reminders
                              .where((r) => r.nextDueAt.isBefore(
                                  DateTime.now()
                                      .add(const Duration(days: 7))))
                              .take(3)
                              .toList();
                          if (upcoming.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle('Upcoming Reminders'),
                              const SizedBox(height: 8),
                              ...upcoming.map((r) => _ReminderRow(
                                    reminder: r,
                                    onPay: () =>
                                        _payReminder(context, ref, r),
                                  )),
                              const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  void _payReminder(BuildContext context, WidgetRef ref, Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pay "${reminder.title}"?'),
        content: reminder.amountPaisa != null
            ? Text('Amount: ${MoneyFormatter.format(reminder.amountPaisa!)}')
            : const Text(
                'Amount will be recorded as set on the reminder.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(remindersProvider.notifier).pay(
                    reminder.id,
                    occurredAt: DateTime.now());
                if (context.mounted)
                  showSuccessSnackBar(context, 'Payment recorded!');
              } catch (e) {
                if (context.mounted) showErrorSnackBar(context, e);
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

class _HeroCard extends StatelessWidget {
  final int total;
  final int bucketCount;
  final String? defaultSourceName;
  final VoidCallback onTap;

  const _HeroCard({
    required this.total,
    required this.bucketCount,
    this.defaultSourceName,
    required this.onTap,
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Icon(Icons.savings_outlined, size: 13, color: cs.onPrimary),
                  const SizedBox(width: 4),
                  Text('+ Source',
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w500)),
                ]),
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

class _StatCard extends StatelessWidget {
  final String label;
  final int paisa;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.paisa,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Icon(Icons.add_circle_outline,
                  size: 16, color: color.withValues(alpha: 0.6)),
            ]),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(MoneyFormatter.format(paisa),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 15)),
          ],
        ),
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
