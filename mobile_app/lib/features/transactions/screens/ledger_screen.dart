import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:expense_tracker_app/features/people/providers/people_provider.dart';
import 'package:expense_tracker_app/features/tags/providers/tags_provider.dart';
import 'package:expense_tracker_app/features/transactions/providers/transactions_provider.dart';
import 'package:expense_tracker_app/features/transactions/screens/quick_add_sheet.dart';
import 'package:expense_tracker_app/shared/constants/tx_type_config.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app/core/formatters/date_formatter.dart';
import 'package:intl/intl.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  bool _showFilters = false;
  String? _filterType;
  String? _filterBucketId;
  String? _filterPersonId;
  String? _filterTagId;
  String? _filterFrom;
  String? _filterTo;

  Map<String, dynamic> get _activeFilters => {
    if (_filterType != null) 'type': _filterType,
    if (_filterBucketId != null) 'bucket_id': _filterBucketId,
    if (_filterPersonId != null) 'person_id': _filterPersonId,
    if (_filterTagId != null) 'tag_id': _filterTagId,
    if (_filterFrom != null) 'from': _filterFrom,
    if (_filterTo != null) 'to': _filterTo,
  };

  int get _activeFilterCount => _activeFilters.length;

  void _applyFilters() {
    ref.read(transactionsProvider.notifier).applyFilters(_activeFilters);
  }

  void _clearFilters() {
    setState(() {
      _filterType = null;
      _filterBucketId = null;
      _filterPersonId = null;
      _filterTagId = null;
      _filterFrom = null;
      _filterTo = null;
    });
    ref.read(transactionsProvider.notifier).applyFilters({});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsProvider);
    final buckets = ref.watch(bucketsProvider).value ?? [];
    final people = ref.watch(peopleProvider).value ?? [];
    final tags = ref.watch(tagsProvider).value ?? [];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
        actions: [
          Badge(
            isLabelVisible: _activeFilterCount > 0,
            label: Text('$_activeFilterCount'),
            child: IconButton(
              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list_rounded),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const QuickAddSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_showFilters)
            _FiltersPanel(
              buckets: buckets,
              people: people,
              tags: tags,
              filterType: _filterType,
              filterBucketId: _filterBucketId,
              filterPersonId: _filterPersonId,
              filterTagId: _filterTagId,
              filterFrom: _filterFrom,
              filterTo: _filterTo,
              onTypeChanged: (v) { setState(() => _filterType = v); _applyFilters(); },
              onBucketChanged: (v) { setState(() => _filterBucketId = v); _applyFilters(); },
              onPersonChanged: (v) { setState(() => _filterPersonId = v); _applyFilters(); },
              onTagChanged: (v) { setState(() => _filterTagId = v); _applyFilters(); },
              onFromChanged: (v) { setState(() => _filterFrom = v); _applyFilters(); },
              onToChanged: (v) { setState(() => _filterTo = v); _applyFilters(); },
              onClear: _clearFilters,
              activeCount: _activeFilterCount,
            ),
          Expanded(
            child: state.when(
              loading: () => skeletonList(count: 10),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) {
                if (data.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: cs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No transactions found',
                          style: Theme.of(context).textTheme.titleMedium),
                        if (_activeFilterCount > 0) ...[
                          const SizedBox(height: 8),
                          TextButton(onPressed: _clearFilters, child: const Text('Clear filters')),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: data.items.length +
                      (data.nextCursor != null && data.nextCursor!.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == data.items.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(transactionsProvider.notifier).loadMore();
                        });
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final tx = data.items[i];
                      return _TxTile(
                        tx: tx,
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => QuickAddSheet(transaction: tx),
                        ),
                        onDelete: () => _confirmDelete(context, ref, tx),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('A reversal entry will be inserted. The original is kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(transactionsProvider.notifier).delete(tx.id);
                if (context.mounted) showSuccessSnackBar(context, 'Transaction deleted');
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
}

class _TxTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TxTile({required this.tx, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cfg = txTypeConfigs[tx.type];
    final color = cfg?.color ?? Theme.of(context).colorScheme.primary;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade700,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // We handle deletion ourselves
      },
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cfg?.icon ?? Icons.receipt, color: color, size: 18),
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
                          DateFormatter.smart(tx.occurredAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        if (tx.tags.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          ...tx.tags.take(2).map((t) => Container(
                            margin: const EdgeInsets.only(right: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final List<dynamic> buckets;
  final List<dynamic> people;
  final List<dynamic> tags;
  final String? filterType;
  final String? filterBucketId;
  final String? filterPersonId;
  final String? filterTagId;
  final String? filterFrom;
  final String? filterTo;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onBucketChanged;
  final ValueChanged<String?> onPersonChanged;
  final ValueChanged<String?> onTagChanged;
  final ValueChanged<String?> onFromChanged;
  final ValueChanged<String?> onToChanged;
  final VoidCallback onClear;
  final int activeCount;

  const _FiltersPanel({
    required this.buckets, required this.people, required this.tags,
    this.filterType, this.filterBucketId, this.filterPersonId,
    this.filterTagId, this.filterFrom, this.filterTo,
    required this.onTypeChanged, required this.onBucketChanged,
    required this.onPersonChanged, required this.onTagChanged,
    required this.onFromChanged, required this.onToChanged,
    required this.onClear, required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border(bottom: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3))),
      ),
      child: Column(
        children: [
          // Type chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(label: 'All', selected: filterType == null,
                  onTap: () => onTypeChanged(null)),
                ...txTypeConfigs.entries.map((e) => _FilterChip(
                  label: e.value.label,
                  selected: filterType == e.key,
                  color: e.value.color,
                  onTap: () => onTypeChanged(filterType == e.key ? null : e.key),
                )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _DropdownFilter(
                hint: 'Bucket',
                value: filterBucketId,
                items: buckets.map((b) => DropdownMenuItem(
                  value: b.id as String, child: Text(b.name as String))).toList(),
                onChanged: onBucketChanged,
              )),
              const SizedBox(width: 8),
              Expanded(child: _DropdownFilter(
                hint: 'Person',
                value: filterPersonId,
                items: people.map((p) => DropdownMenuItem(
                  value: p.id as String, child: Text(p.name as String))).toList(),
                onChanged: onPersonChanged,
              )),
              const SizedBox(width: 8),
              Expanded(child: _DropdownFilter(
                hint: 'Tag',
                value: filterTagId,
                items: tags.map((t) => DropdownMenuItem(
                  value: t.id as String, child: Text(t.name as String))).toList(),
                onChanged: onTagChanged,
              )),
            ],
          ),
          if (activeCount > 0) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 14),
                label: Text('Clear $activeCount filter${activeCount > 1 ? "s" : ""}'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected,
    this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c : c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : c,
        )),
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({required this.hint, this.value,
    required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(hint,
          style: const TextStyle(color: Colors.grey))),
        ...items,
      ],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
    );
  }
}
