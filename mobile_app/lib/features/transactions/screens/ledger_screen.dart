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

  // Transaction type filter
  String? _filterType;

  // Money source / person / tag filters
  String? _filterBucketId;
  String? _filterPersonId;
  String? _filterTagId;

  // Date filters — managed via _quickTime presets
  String? _filterFrom;
  String? _filterTo;
  String? _quickTime; // 'today' | 'yesterday' | 'this_month' | 'last_month' | 'custom' | null

  Map<String, dynamic> get _activeFilters => {
    if (_filterType != null) 'type': _filterType,
    if (_filterBucketId != null) 'bucket_id': _filterBucketId,
    if (_filterPersonId != null) 'person_id': _filterPersonId,
    if (_filterTagId != null) 'tag_id': _filterTagId,
    if (_filterFrom != null) 'from': _filterFrom,
    if (_filterTo != null) 'to': _filterTo,
  };

  int get _activeFilterCount {
    int n = 0;
    if (_filterType != null) n++;
    if (_filterBucketId != null) n++;
    if (_filterPersonId != null) n++;
    if (_filterTagId != null) n++;
    if (_quickTime != null) n++; // date range counts as one filter
    return n;
  }

  void _applyFilters() {
    ref.read(transactionsProvider.notifier).applyFilters(_activeFilters);
  }

  void _applyQuickTime(String? preset) {
    final now = DateTime.now();
    String? from;
    String? to;

    switch (preset) {
      case 'today':
        from = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
        to = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc().toIso8601String();
      case 'yesterday':
        final y = now.subtract(const Duration(days: 1));
        from = DateTime(y.year, y.month, y.day).toUtc().toIso8601String();
        to = DateTime(y.year, y.month, y.day, 23, 59, 59).toUtc().toIso8601String();
      case 'this_month':
        from = DateTime(now.year, now.month, 1).toUtc().toIso8601String();
        to = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc().toIso8601String();
      case 'last_month':
        final firstOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastOfLastMonth = DateTime(now.year, now.month, 0); // day 0 = last day of prev month
        from = DateTime(firstOfLastMonth.year, firstOfLastMonth.month, 1).toUtc().toIso8601String();
        to = DateTime(lastOfLastMonth.year, lastOfLastMonth.month, lastOfLastMonth.day, 23, 59, 59)
            .toUtc().toIso8601String();
      default:
        from = null;
        to = null;
    }

    setState(() {
      _quickTime = preset;
      _filterFrom = from;
      _filterTo = to;
    });
    _applyFilters();
  }

  Future<void> _pickCustomDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: (_filterFrom != null && _filterTo != null)
          ? DateTimeRange(
              start: DateTime.parse(_filterFrom!).toLocal(),
              end: DateTime.parse(_filterTo!).toLocal(),
            )
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (range == null || !mounted) return;
    setState(() {
      _quickTime = 'custom';
      _filterFrom = DateTime(range.start.year, range.start.month, range.start.day)
          .toUtc().toIso8601String();
      _filterTo = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59)
          .toUtc().toIso8601String();
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _filterType = null;
      _filterBucketId = null;
      _filterPersonId = null;
      _filterTagId = null;
      _filterFrom = null;
      _filterTo = null;
      _quickTime = null;
    });
    ref.read(transactionsProvider.notifier).applyFilters({});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsProvider);
    final buckets = ref.watch(bucketsProvider).value ?? [];
    final activeBuckets = buckets.where((b) => b.archivedAt == null).toList();
    final people = ref.watch(peopleProvider).value ?? [];
    final tags = ref.watch(tagsProvider).value ?? [];
    final activeTags = tags.where((t) => t.archivedAt == null).toList();
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
              buckets: activeBuckets,
              people: people,
              tags: activeTags,
              filterType: _filterType,
              filterBucketId: _filterBucketId,
              filterPersonId: _filterPersonId,
              filterTagId: _filterTagId,
              quickTime: _quickTime,
              filterFrom: _filterFrom,
              filterTo: _filterTo,
              onTypeChanged: (v) { setState(() => _filterType = v); _applyFilters(); },
              onBucketChanged: (v) { setState(() => _filterBucketId = v); _applyFilters(); },
              onPersonChanged: (v) { setState(() => _filterPersonId = v); _applyFilters(); },
              onTagChanged: (v) { setState(() => _filterTagId = v); _applyFilters(); },
              onQuickTimeChanged: _applyQuickTime,
              onCustomDateTap: _pickCustomDateRange,
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

// ─── Transaction tile ──────────────────────────────────────────────────────────

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
        return false;
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

// ─── Enhanced Filters Panel ────────────────────────────────────────────────────

class _FiltersPanel extends StatelessWidget {
  final List<dynamic> buckets;
  final List<dynamic> people;
  final List<dynamic> tags;
  final String? filterType;
  final String? filterBucketId;
  final String? filterPersonId;
  final String? filterTagId;
  final String? quickTime;
  final String? filterFrom;
  final String? filterTo;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onBucketChanged;
  final ValueChanged<String?> onPersonChanged;
  final ValueChanged<String?> onTagChanged;
  final ValueChanged<String?> onQuickTimeChanged;
  final VoidCallback onCustomDateTap;
  final VoidCallback onClear;
  final int activeCount;

  const _FiltersPanel({
    required this.buckets,
    required this.people,
    required this.tags,
    this.filterType,
    this.filterBucketId,
    this.filterPersonId,
    this.filterTagId,
    this.quickTime,
    this.filterFrom,
    this.filterTo,
    required this.onTypeChanged,
    required this.onBucketChanged,
    required this.onPersonChanged,
    required this.onTagChanged,
    required this.onQuickTimeChanged,
    required this.onCustomDateTap,
    required this.onClear,
    required this.activeCount,
  });

  String _customLabel() {
    if (quickTime != 'custom' || filterFrom == null || filterTo == null) return 'Custom';
    final from = DateTime.parse(filterFrom!).toLocal();
    final to = DateTime.parse(filterTo!).toLocal();
    final fmt = DateFormat('d MMM');
    return '${fmt.format(from)} – ${fmt.format(to)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Date quick presets ──────────────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(
                  label: 'All Time',
                  selected: quickTime == null,
                  onTap: () => onQuickTimeChanged(null),
                ),
                _Chip(
                  label: 'Today',
                  selected: quickTime == 'today',
                  onTap: () => onQuickTimeChanged('today'),
                ),
                _Chip(
                  label: 'Yesterday',
                  selected: quickTime == 'yesterday',
                  onTap: () => onQuickTimeChanged('yesterday'),
                ),
                _Chip(
                  label: 'This Month',
                  selected: quickTime == 'this_month',
                  onTap: () => onQuickTimeChanged('this_month'),
                ),
                _Chip(
                  label: 'Last Month',
                  selected: quickTime == 'last_month',
                  onTap: () => onQuickTimeChanged('last_month'),
                ),
                _Chip(
                  label: _customLabel(),
                  selected: quickTime == 'custom',
                  icon: Icons.date_range_rounded,
                  onTap: onCustomDateTap,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Transaction type chips ──────────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(
                  label: 'All',
                  selected: filterType == null,
                  onTap: () => onTypeChanged(null),
                ),
                ...txTypeConfigs.entries.map((e) => _Chip(
                  label: e.value.label,
                  selected: filterType == e.key,
                  color: e.value.color,
                  onTap: () => onTypeChanged(filterType == e.key ? null : e.key),
                )),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Money Source + Person dropdowns ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DropdownFilter(
                  hint: 'Money Source',
                  value: filterBucketId,
                  items: buckets.map((b) => DropdownMenuItem(
                    value: b.id as String,
                    child: Text(b.name as String),
                  )).toList(),
                  onChanged: onBucketChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownFilter(
                  hint: 'Person',
                  value: filterPersonId,
                  items: people.map((p) => DropdownMenuItem(
                    value: p.id as String,
                    child: Text(p.name as String),
                  )).toList(),
                  onChanged: onPersonChanged,
                ),
              ),
            ],
          ),

          // ── Tag chips ───────────────────────────────────────────────────────
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: tags.map((t) => _Chip(
                  label: t.name as String,
                  selected: filterTagId == (t.id as String),
                  color: cs.secondary,
                  onTap: () => onTagChanged(
                    filterTagId == (t.id as String) ? null : t.id as String,
                  ),
                )).toList(),
              ),
            ),
          ],

          // ── Clear button ────────────────────────────────────────────────────
          if (activeCount > 0) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 14),
                label: Text('Clear $activeCount filter${activeCount > 1 ? "s" : ""}'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

// ─── Chip widget ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final IconData? icon;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c : c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: selected ? Colors.white : c),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dropdown filter ───────────────────────────────────────────────────────────

class _DropdownFilter extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
  });

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
        DropdownMenuItem(
          value: null,
          child: Text(hint, style: const TextStyle(color: Colors.grey)),
        ),
        ...items,
      ],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
    );
  }
}
