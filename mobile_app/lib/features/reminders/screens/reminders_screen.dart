import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:expense_tracker_app/features/people/providers/people_provider.dart';
import 'package:expense_tracker_app/features/reminders/providers/reminders_provider.dart';
import 'package:expense_tracker_app/shared/constants/tx_type_config.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReminderForm(context, ref),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('New Reminder'),
      ),
      body: remindersAsync.when(
        loading: () => skeletonList(count: 5),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reminders) {
          if (reminders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No reminders yet', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Tap + to create one', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final overdue = reminders.where((r) => r.nextDueAt.isBefore(now)).toList();
          final dueSoon = reminders.where((r) =>
            r.nextDueAt.isAfter(now) &&
            r.nextDueAt.isBefore(now.add(const Duration(days: 3)))).toList();
          final upcoming = reminders.where((r) =>
            r.nextDueAt.isAfter(now.add(const Duration(days: 3)))).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(remindersProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (overdue.isNotEmpty) ...[
                  _SectionHeader(title: '🔴  Overdue (${overdue.length})'),
                  ...overdue.map((r) => _ReminderCard(
                    reminder: r,
                    onEdit: () => _showReminderForm(context, ref, reminder: r),
                    onPay: () => _showPayDialog(context, ref, r),
                    onSkip: () => _confirmSkip(context, ref, r),
                  )),
                ],
                if (dueSoon.isNotEmpty) ...[
                  _SectionHeader(title: '🟡  Due Soon (${dueSoon.length})'),
                  ...dueSoon.map((r) => _ReminderCard(
                    reminder: r,
                    onEdit: () => _showReminderForm(context, ref, reminder: r),
                    onPay: () => _showPayDialog(context, ref, r),
                    onSkip: () => _confirmSkip(context, ref, r),
                  )),
                ],
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(title: 'Upcoming (${upcoming.length})'),
                  ...upcoming.map((r) => _ReminderCard(
                    reminder: r,
                    onEdit: () => _showReminderForm(context, ref, reminder: r),
                    onPay: () => _showPayDialog(context, ref, r),
                    onSkip: () => _confirmSkip(context, ref, r),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPayDialog(BuildContext context, WidgetRef ref, Reminder reminder) {
    final amountCtrl = TextEditingController(
      text: reminder.amountPaisa != null
        ? (reminder.amountPaisa! / 100).toStringAsFixed(0)
        : '',
    );
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pay: ${reminder.title}',
              style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Will create a ${reminder.defaultType.replaceAll("_", " ")} transaction',
              style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (৳)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Mark as Paid'),
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                Navigator.pop(ctx);
                try {
                  await ref.read(remindersProvider.notifier).pay(
                    reminder.id,
                    amountPaisa: amount != null ? (amount * 100).round() : null,
                    occurredAt: DateTime.now(),
                    note: noteCtrl.text.trim(),
                  );
                  if (context.mounted) showSuccessSnackBar(context, 'Payment recorded!');
                } catch (e) {
                  if (context.mounted) showErrorSnackBar(context, e);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmSkip(BuildContext context, WidgetRef ref, Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Skip "${reminder.title}"?'),
        content: Text(
          'Next due date will advance to: '
          '${DateFormat("MMM d, yyyy").format(_nextDuePreview(reminder))}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(remindersProvider.notifier).skip(reminder.id);
                if (context.mounted) showSuccessSnackBar(context, 'Skipped');
              } catch (e) {
                if (context.mounted) showErrorSnackBar(context, e);
              }
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  DateTime _nextDuePreview(Reminder r) {
    return switch (r.recurrenceType) {
      'weekly' => r.nextDueAt.add(const Duration(days: 7)),
      'monthly' => DateTime(r.nextDueAt.year, r.nextDueAt.month + 1, r.nextDueAt.day),
      'yearly' => DateTime(r.nextDueAt.year + 1, r.nextDueAt.month, r.nextDueAt.day),
      _ => r.nextDueAt,
    };
  }

  void _showReminderForm(BuildContext context, WidgetRef ref, {Reminder? reminder}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ReminderFormSheet(reminder: reminder),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onPay;
  final VoidCallback onSkip;

  const _ReminderCard({
    required this.reminder,
    required this.onEdit,
    required this.onPay,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = reminder.nextDueAt.isBefore(now);
    final cfg = txTypeConfigs[reminder.defaultType];
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: (cfg?.color ?? cs.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cfg?.icon ?? Icons.alarm, size: 18,
                    color: cfg?.color ?? cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Row(
                        children: [
                          Icon(
                            isOverdue ? Icons.warning_rounded : Icons.calendar_today_outlined,
                            size: 12,
                            color: isOverdue ? Colors.red : cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(reminder.nextDueAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              reminder.recurrenceType,
                              style: TextStyle(fontSize: 10, color: cs.onSecondaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (reminder.amountPaisa != null)
                  Text(
                    MoneyFormatter.format(reminder.amountPaisa!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cfg?.color ?? cs.primary,
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Pay'),
                    onPressed: onPay,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.skip_next_rounded, size: 16),
                    label: const Text('Skip'),
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    )),
  );
}

class _ReminderFormSheet extends ConsumerStatefulWidget {
  final Reminder? reminder;
  const _ReminderFormSheet({this.reminder});

  @override
  ConsumerState<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends ConsumerState<_ReminderFormSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _defaultType = 'expense';
  String _recurrenceType = 'monthly';
  int? _recurrenceDay;
  DateTime _nextDueAt = DateTime.now().add(const Duration(days: 1));
  String? _linkedBucketId;
  String? _linkedPersonId;
  bool _isSaving = false;

  bool get _isEdit => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    if (r != null) {
      _titleCtrl.text = r.title;
      if (r.amountPaisa != null) {
        _amountCtrl.text = (r.amountPaisa! / 100).toStringAsFixed(0);
      }
      _defaultType = r.defaultType;
      _recurrenceType = r.recurrenceType;
      _recurrenceDay = r.recurrenceDay;
      _nextDueAt = r.nextDueAt;
      _linkedBucketId = r.linkedBucketId;
      _linkedPersonId = r.linkedPersonId;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      showErrorSnackBar(context, 'Title is required');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final amount = double.tryParse(_amountCtrl.text);
      final request = CreateReminderRequest(
        title: title,
        amountPaisa: amount != null ? (amount * 100).round() : null,
        defaultType: _defaultType,
        recurrenceType: _recurrenceType,
        recurrenceDay: _recurrenceDay,
        nextDueAt: _nextDueAt.toUtc(),
        linkedBucketId: _linkedBucketId,
        linkedPersonId: _linkedPersonId,
      );
      if (_isEdit) {
        await ref.read(remindersProvider.notifier).editReminder(
          widget.reminder!.id,
          Map<String, dynamic>.from(request.toJson())..removeWhere((k, v) => v == null),
        );
        if (mounted) showSuccessSnackBar(context, 'Reminder updated');
      } else {
        await ref.read(remindersProvider.notifier).create(request);
        if (mounted) showSuccessSnackBar(context, 'Reminder created');
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buckets = ref.watch(bucketsProvider).value
        ?.where((b) => b.archivedAt == null).toList() ?? [];
    final people = ref.watch(peopleProvider).value
        ?.where((p) => p.archivedAt == null).toList() ?? [];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(_isEdit ? 'Edit Reminder' : 'New Reminder',
                  style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              children: [
                TextField(
                  controller: _titleCtrl,
                  autofocus: !_isEdit,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount ৳ (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Can be set when paying',
                  ),
                ),
                const SizedBox(height: 16),
                Text('Transaction Type', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: txTypeConfigs.entries.map((e) {
                    final selected = _defaultType == e.key;
                    return ChoiceChip(
                      label: Text(e.value.label),
                      selected: selected,
                      selectedColor: e.value.color,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : null,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _defaultType = e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Recurrence', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'none', label: Text('Once')),
                    ButtonSegment(value: 'weekly', label: Text('Weekly')),
                    ButtonSegment(value: 'monthly', label: Text('Monthly')),
                    ButtonSegment(value: 'yearly', label: Text('Yearly')),
                  ],
                  selected: {_recurrenceType},
                  onSelectionChanged: (s) => setState(() => _recurrenceType = s.first),
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
                if (_recurrenceType == 'monthly') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: _recurrenceDay,
                    decoration: const InputDecoration(
                      labelText: 'Day of month (optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Same as start date')),
                      ...List.generate(31, (i) => DropdownMenuItem(
                        value: i + 1, child: Text('Day ${i + 1}'))),
                    ],
                    onChanged: (v) => setState(() => _recurrenceDay = v),
                  ),
                ],
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text('Next due: ${DateFormat("EEE, d MMM yyyy").format(_nextDueAt)}'),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _nextDueAt,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (d != null) setState(() => _nextDueAt = d);
                  },
                ),
                if (buckets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _linkedBucketId,
                    decoration: const InputDecoration(
                      labelText: 'Linked bucket (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...buckets.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                    ],
                    onChanged: (v) => setState(() => _linkedBucketId = v),
                  ),
                ],
                if (people.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _linkedPersonId,
                    decoration: const InputDecoration(
                      labelText: 'Linked person (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                    ],
                    onChanged: (v) => setState(() => _linkedPersonId = v),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEdit ? 'Update Reminder' : 'Create Reminder',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
