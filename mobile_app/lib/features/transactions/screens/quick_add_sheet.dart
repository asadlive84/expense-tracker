import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:expense_tracker_app/features/people/providers/people_provider.dart';
import 'package:expense_tracker_app/features/tags/providers/tags_provider.dart';
import 'package:expense_tracker_app/features/transactions/providers/transactions_provider.dart';
import 'package:expense_tracker_app/shared/constants/tx_type_config.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app/core/formatters/date_formatter.dart';
import 'package:intl/intl.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const QuickAddSheet({super.key, this.transaction});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = 'expense';
  String? _fromBucketId;
  String? _toBucketId;
  String? _personId;
  DateTime _occurredAt = DateTime.now();
  List<String> _selectedTagIds = [];
  bool _isSaving = false;

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _selectedType = tx.type;
      _amountController.text = (tx.amountPaisa / 100).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      _noteController.text = tx.note;
      _fromBucketId = tx.fromBucketId;
      _toBucketId = tx.toBucketId;
      _personId = tx.personId;
      _occurredAt = tx.occurredAt;
      _selectedTagIds = tx.tags.map((t) => t.id).toList();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _needsFromBucket => ['expense', 'transfer', 'loan_given', 'repayment_paid'].contains(_selectedType);
  bool get _needsToBucket => ['income', 'transfer', 'loan_taken', 'repayment_received'].contains(_selectedType);
  bool get _needsPerson => ['loan_given', 'loan_taken', 'repayment_received', 'repayment_paid'].contains(_selectedType);

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _occurredAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _handleSave() async {
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      showErrorSnackBar(context, 'Please enter a valid amount');
      return;
    }
    if (_needsFromBucket && _fromBucketId == null) {
      showErrorSnackBar(context, 'Please select a source bucket');
      return;
    }
    if (_needsToBucket && _toBucketId == null) {
      showErrorSnackBar(context, 'Please select a destination bucket');
      return;
    }
    if (_selectedType == 'transfer' && _fromBucketId == _toBucketId) {
      showErrorSnackBar(context, 'Source and destination buckets must be different');
      return;
    }
    if (_needsPerson && _personId == null) {
      showErrorSnackBar(context, 'Please select a person');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final request = CreateTransactionRequest(
        type: _selectedType,
        amountPaisa: (amount * 100).round(),
        fromBucketId: _needsFromBucket ? _fromBucketId : null,
        toBucketId: _needsToBucket ? _toBucketId : null,
        personId: _needsPerson ? _personId : null,
        note: _noteController.text.trim(),
        occurredAt: _occurredAt.toUtc(),
        tagIds: _selectedTagIds,
      );
      if (_isEdit) {
        await ref.read(transactionsProvider.notifier).editTransaction(widget.transaction!.id, request);
        if (mounted) showSuccessSnackBar(context, 'Transaction updated');
      } else {
        await ref.read(transactionsProvider.notifier).create(request);
        if (mounted) showSuccessSnackBar(context, 'Transaction saved');
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
    final buckets = ref.watch(bucketsProvider).value ?? [];
    final activeBuckets = buckets.where((b) => b.archivedAt == null).toList();
    final people = ref.watch(peopleProvider).value ?? [];
    final activePeople = people.where((p) => p.archivedAt == null).toList();
    final tags = ref.watch(tagsProvider).value ?? [];
    final activeTags = tags.where((t) => t.archivedAt == null).toList();
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  _isEdit ? 'Edit Transaction' : 'New Transaction',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              children: [
                // Type selector chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: txTypeConfigs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final entry = txTypeConfigs.entries.elementAt(i);
                      final cfg = entry.value;
                      final selected = _selectedType == entry.key;
                      return ChoiceChip(
                        label: Text(cfg.label),
                        avatar: Icon(cfg.icon, size: 16,
                          color: selected ? Colors.white : cfg.color),
                        selected: selected,
                        selectedColor: cfg.color,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : null,
                          fontWeight: selected ? FontWeight.w600 : null,
                        ),
                        onSelected: (_) => setState(() {
                          _selectedType = entry.key;
                          _fromBucketId = null;
                          _toBucketId = null;
                          _personId = null;
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Amount — big and prominent
                TextFormField(
                  controller: _amountController,
                  autofocus: !_isEdit,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: txTypeConfigs[_selectedType]!.color,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: '৳  ',
                    hintText: '0',
                    border: InputBorder.none,
                    prefixStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // From bucket
                if (_needsFromBucket)
                  _BucketDropdown(
                    label: _selectedType == 'transfer' ? 'From' : 'Bucket',
                    buckets: activeBuckets,
                    value: _fromBucketId,
                    onChanged: (v) => setState(() => _fromBucketId = v),
                  ),

                // To bucket
                if (_needsToBucket) ...[
                  if (_needsFromBucket) const SizedBox(height: 12),
                  _BucketDropdown(
                    label: _selectedType == 'transfer' ? 'To' : 'Bucket',
                    buckets: activeBuckets.where((b) => b.id != _fromBucketId).toList(),
                    value: _toBucketId,
                    onChanged: (v) => setState(() => _toBucketId = v),
                  ),
                ],

                // Person
                if (_needsPerson) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _personId,
                    decoration: const InputDecoration(
                      labelText: 'Person',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: activePeople.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    )).toList(),
                    onChanged: (v) => setState(() => _personId = v),
                  ),
                ],

                const SizedBox(height: 12),
                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 12),
                // Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(DateFormatter.full(_occurredAt)),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: cs.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: _pickDateTime,
                ),

                // Tags
                if (activeTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Tags', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: activeTags.map((tag) {
                      final selected = _selectedTagIds.contains(tag.id);
                      return FilterChip(
                        label: Text(tag.name),
                        selected: selected,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _selectedTagIds = [..._selectedTagIds, tag.id];
                          } else {
                            _selectedTagIds = _selectedTagIds.where((id) => id != tag.id).toList();
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: txTypeConfigs[_selectedType]!.color,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isEdit ? 'Update Transaction' : 'Save Transaction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BucketDropdown extends StatelessWidget {
  final String label;
  final List<dynamic> buckets;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _BucketDropdown({
    required this.label,
    required this.buckets,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
      ),
      items: buckets.map((b) => DropdownMenuItem(
        value: b.id as String,
        child: Text(b.name as String),
      )).toList(),
      onChanged: onChanged,
    );
  }
}
