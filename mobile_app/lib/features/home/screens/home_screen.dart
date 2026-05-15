import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/auth/providers/user_profile_provider.dart';
import 'package:expense_tracker_app/features/reminders/providers/reminders_provider.dart';
import 'package:expense_tracker_app/features/reports/providers/reports_provider.dart';
import 'package:expense_tracker_app/features/transactions/providers/transactions_provider.dart';
import 'package:expense_tracker_app/features/transactions/screens/quick_add_sheet.dart';
import 'package:expense_tracker_app/shared/constants/tx_type_config.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthStr = DateFormat('yyyy-MM').format(now);

    final summaryAsync = ref.watch(monthlySummaryProvider(monthStr));
    final balancesAsync = ref.watch(bucketBalancesProvider);
    final recentTxAsync = ref.watch(transactionsProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final userName = ref.watch(userNameProvider).value;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthlySummaryProvider);
          ref.invalidate(bucketBalancesProvider);
          ref.invalidate(remindersProvider);
          ref.read(transactionsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(userName != null ? 'Hi, $userName 👋' : 'Expense Tracker'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const QuickAddSheet(),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add name prompt if missing
                    if (userName == null || userName.isEmpty)
                      _AddNameCard(onSaved: () => ref.invalidate(userNameProvider)),

                    const SizedBox(height: 4),

                    // Net worth hero card
                    balancesAsync.when(
                      loading: () => const SkeletonCard(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (items) {
                        final total = items.fold(0, (s, b) => s + b.balancePaisa);
                        return _HeroCard(total: total, bucketCount: items.length);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Income / Expense row
                    summaryAsync.when(
                      loading: () => Row(children: [
                        Expanded(child: skeletonList(count: 1, card: true)),
                        const SizedBox(width: 12),
                        Expanded(child: skeletonList(count: 1, card: true)),
                      ]),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (s) => Row(
                        children: [
                          Expanded(child: _StatCard(
                            label: 'Income', paisa: s.incomePaisa,
                            icon: Icons.arrow_downward_rounded,
                            color: Colors.green.shade600,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            label: 'Expenses', paisa: s.expensePaisa,
                            icon: Icons.arrow_upward_rounded,
                            color: Colors.red.shade400,
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upcoming reminders
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
                            _SectionTitle('Upcoming Reminders'),
                            ...upcoming.map((r) => _ReminderRow(
                              reminder: r,
                              onPay: () => _payReminder(context, ref, r),
                            )),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),

                    // Recent transactions
                    _SectionTitle('Recent Transactions'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            recentTxAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const SkeletonListTile(), childCount: 6),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (state) {
                final items = state.items.take(10).toList();
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No transactions yet')),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TxRow(
                      tx: items[i],
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => QuickAddSheet(transaction: items[i]),
                      ),
                    ),
                    childCount: items.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
            : const Text('Amount will be recorded as set on the reminder.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(remindersProvider.notifier).pay(
                  reminder.id, occurredAt: DateTime.now());
                if (context.mounted) showSuccessSnackBar(context, 'Payment recorded!');
              } catch (e) {
                if (context.mounted) showErrorSnackBar(context, e);
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }
}


// ── Add name prompt card ─────────────────────────────────────────────────────

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
          Row(
            children: [
              Icon(Icons.waving_hand_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text('What should we call you?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                child: _saving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int total;
  final int bucketCount;
  const _HeroCard({required this.total, required this.bucketCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
          Text('Total Balance',
            style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8), fontSize: 14)),
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
          Text('across $bucketCount buckets',
            style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.7), fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int paisa;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.paisa,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(MoneyFormatter.format(paisa),
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
}

class _TxRow extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onTap;
  const _TxRow({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cfg = txTypeConfigs[tx.type];
    final color = cfg?.color ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cfg?.icon ?? Icons.swap_horiz, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note.isNotEmpty ? tx.note : tx.type.replaceAll('_', ' '),
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM d').format(tx.occurredAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (tx.tags.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        ...tx.tags.take(2).map((t) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(t.name, style: TextStyle(fontSize: 10, color: color)),
                        )),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${amountPrefix(tx.type)}${MoneyFormatter.format(tx.amountPaisa)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amountColor(tx.type),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        title: Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          DateFormat('MMM d').format(reminder.nextDueAt),
          style: TextStyle(
            fontSize: 12,
            color: isOverdue ? Colors.red : null,
          ),
        ),
        trailing: TextButton(
          onPressed: onPay,
          child: const Text('Pay'),
        ),
      ),
    );
  }
}
