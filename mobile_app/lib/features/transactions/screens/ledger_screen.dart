import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:expense_tracker_app/features/people/providers/people_provider.dart';
import 'package:expense_tracker_app/features/tags/providers/tags_provider.dart';
import 'package:expense_tracker_app/features/transactions/providers/transactions_provider.dart';
import 'package:expense_tracker_app/features/transactions/screens/quick_add_sheet.dart';
import 'package:expense_tracker_app/features/transactions/widgets/receipt_view.dart';
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
  // ── Filter state ───────────────────────────────────────────────────────────
  bool _showFilters  = false;
  String? _filterType;
  String? _filterBucketId;
  String? _filterPersonId;
  String? _filterTagId;
  String? _filterFrom;
  String? _filterTo;
  String? _quickTime;

  // ── Selection state ────────────────────────────────────────────────────────
  final Set<String> _selectedIds = {};
  bool get _isSelecting => _selectedIds.isNotEmpty;

  // ── Filter helpers ─────────────────────────────────────────────────────────

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
    if (_quickTime != null) n++;
    return n;
  }

  void _applyFilters() =>
      ref.read(transactionsProvider.notifier).applyFilters(_activeFilters);

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
        final first = DateTime(now.year, now.month - 1, 1);
        final last  = DateTime(now.year, now.month, 0);
        from = DateTime(first.year, first.month, 1).toUtc().toIso8601String();
        to = DateTime(last.year, last.month, last.day, 23, 59, 59).toUtc().toIso8601String();
      default:
        from = null;
        to   = null;
    }
    setState(() { _quickTime = preset; _filterFrom = from; _filterTo = to; });
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
              end: DateTime.parse(_filterTo!).toLocal())
          : null,
    );
    if (range == null || !mounted) return;
    setState(() {
      _quickTime  = 'custom';
      _filterFrom = DateTime(range.start.year, range.start.month, range.start.day)
          .toUtc().toIso8601String();
      _filterTo = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59)
          .toUtc().toIso8601String();
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _filterType = _filterBucketId = _filterPersonId =
          _filterTagId = _filterFrom = _filterTo = _quickTime = null;
    });
    ref.read(transactionsProvider.notifier).applyFilters({});
  }

  // ── Selection helpers ──────────────────────────────────────────────────────

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() => setState(() => _selectedIds.clear());

  /// Net total of selected transactions (income positive, expense negative).
  int _selectionNet(List<Transaction> allItems) {
    return allItems
        .where((t) => _selectedIds.contains(t.id))
        .fold(0, (sum, t) {
      final sign = _isPositiveType(t.type) ? 1 : -1;
      return sum + sign * t.amountPaisa;
    });
  }

  bool _isPositiveType(String type) =>
      type == 'income' || type == 'repayment_received' || type == 'loan_taken';

  /// Net of ALL currently-loaded filtered transactions.
  int _filterNet(List<Transaction> items) => items.fold(0, (sum, t) {
        final sign = _isPositiveType(t.type) ? 1 : -1;
        return sum + sign * t.amountPaisa;
      });

  // ── Share all filtered transactions ───────────────────────────────────────

  void _shareFiltered(BuildContext context, List<Transaction> items) {
    final buckets     = ref.read(bucketsProvider).value ?? [];
    final people      = ref.read(peopleProvider).value ?? [];
    final bucketNames = {for (final b in buckets) b.id: b.name};
    final personNames = {for (final p in people) p.id: p.name};
    showSummaryReceiptSheet(context, items,
        bucketNames: bucketNames, personNames: personNames);
  }

  // ── Share selected transactions ────────────────────────────────────────────

  void _shareSummary(BuildContext context, List<Transaction> allItems) {
    final selected = allItems.where((t) => _selectedIds.contains(t.id)).toList();
    if (selected.isEmpty) return;

    final buckets = ref.read(bucketsProvider).value ?? [];
    final people  = ref.read(peopleProvider).value ?? [];
    final bucketNames = {for (final b in buckets) b.id: b.name};
    final personNames = {for (final p in people) p.id: p.name};

    showSummaryReceiptSheet(
      context,
      selected,
      bucketNames: bucketNames,
      personNames: personNames,
    );
  }

  // ── Single-transaction receipt ─────────────────────────────────────────────

  void _openReceipt(BuildContext context, Transaction tx) {
    final buckets = ref.read(bucketsProvider).value ?? [];
    final people  = ref.read(peopleProvider).value ?? [];
    final bucketMap = {for (final b in buckets) b.id: b.name};
    final personMap = {for (final p in people) p.id: p.name};

    showReceiptSheet(
      context,
      tx,
      fromBucketName: tx.fromBucketId != null ? bucketMap[tx.fromBucketId] : null,
      toBucketName: tx.toBucketId != null ? bucketMap[tx.toBucketId] : null,
      personName: tx.personId != null ? personMap[tx.personId] : null,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state        = ref.watch(transactionsProvider);
    final buckets      = ref.watch(bucketsProvider).value ?? [];
    final activeBuckets = buckets.where((b) => b.archivedAt == null).toList();
    final people       = ref.watch(peopleProvider).value ?? [];
    final tags         = ref.watch(tagsProvider).value ?? [];
    final activeTags   = tags.where((t) => t.archivedAt == null).toList();
    final cs           = Theme.of(context).colorScheme;

    final allItems = state.value?.items ?? [];

    // Selection totals (multi-select mode)
    final selNet    = _isSelecting ? _selectionNet(allItems) : 0;
    final isSelPos  = selNet >= 0;

    // Filter totals (auto-calculated whenever filters are active)
    final hasFilteredData = _activeFilterCount > 0 && state.hasValue && allItems.isNotEmpty;
    final filterNet   = _filterNet(allItems);
    final isFilterPos = filterNet >= 0;

    return Scaffold(
      // ── App bar — switches to selection toolbar ──────────────────────────
      appBar: _isSelecting
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
              title: Text('${_selectedIds.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  tooltip: 'Select all',
                  onPressed: () => setState(() {
                    _selectedIds.addAll(allItems.map((t) => t.id));
                  }),
                ),
              ],
            )
          : AppBar(
              title: const Text('Ledger'),
              actions: [
                Badge(
                  isLabelVisible: _activeFilterCount > 0,
                  label: Text('$_activeFilterCount'),
                  child: IconButton(
                    icon: Icon(_showFilters
                        ? Icons.filter_list_off
                        : Icons.filter_list_rounded),
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                  ),
                ),
              ],
            ),

      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButton: _isSelecting
          ? null
          : FloatingActionButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const QuickAddSheet(),
              ),
              child: const Icon(Icons.add),
            ),

      body: Stack(
        children: [
          Column(
            children: [
              // ── Filters panel ──────────────────────────────────────────
              if (_showFilters && !_isSelecting)
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
                  onTypeChanged: (v) {
                    setState(() => _filterType = v);
                    _applyFilters();
                  },
                  onBucketChanged: (v) {
                    setState(() => _filterBucketId = v);
                    _applyFilters();
                  },
                  onPersonChanged: (v) {
                    setState(() => _filterPersonId = v);
                    _applyFilters();
                  },
                  onTagChanged: (v) {
                    setState(() => _filterTagId = v);
                    _applyFilters();
                  },
                  onQuickTimeChanged: _applyQuickTime,
                  onCustomDateTap: _pickCustomDateRange,
                  onClear: _clearFilters,
                  activeCount: _activeFilterCount,
                ),

              // ── Transaction list ───────────────────────────────────────
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
                            Icon(Icons.receipt_long_outlined,
                                size: 56, color: cs.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text('No transactions found',
                                style: Theme.of(context).textTheme.titleMedium),
                            if (_activeFilterCount > 0) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _clearFilters,
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(transactionsProvider.notifier).refresh(),
                      child: ListView.builder(
                        itemCount: data.items.length +
                            (data.nextCursor != null &&
                                    data.nextCursor!.isNotEmpty
                                ? 1
                                : 0),
                        itemBuilder: (context, i) {
                          if (i == data.items.length) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref
                                  .read(transactionsProvider.notifier)
                                  .loadMore();
                            });
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          final tx = data.items[i];
                          final isSelected =
                              _selectedIds.contains(tx.id);
                          return _TxTile(
                            tx: tx,
                            isSelected: isSelected,
                            isSelecting: _isSelecting,
                            onTap: () {
                              if (_isSelecting) {
                                _toggleSelect(tx.id);
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => QuickAddSheet(transaction: tx),
                                );
                              }
                            },
                            onLongPress: () => _toggleSelect(tx.id),
                            onDelete: () => _confirmDelete(context, ref, tx),
                            onReceipt: () => _openReceipt(context, tx),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Filter summary bar (auto, when filters are active) ────────
          if (hasFilteredData && !_isSelecting)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _FilterSummaryBar(
                count: allItems.length,
                net: filterNet,
                isPositive: isFilterPos,
                onShare: () => _shareFiltered(context, allItems),
                onClear: _clearFilters,
              ),
            ),

          // ── Selection summary bar (manual multi-select) ───────────────
          if (_isSelecting)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _SelectionBar(
                count: _selectedIds.length,
                net: selNet,
                isPositive: isSelPos,
                onClear: _clearSelection,
                onShare: () => _shareSummary(context, allItems),
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
        content: const Text(
            'A reversal entry will be inserted. The original is kept.'),
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
                await ref
                    .read(transactionsProvider.notifier)
                    .delete(tx.id);
                if (context.mounted)
                  showSuccessSnackBar(context, 'Transaction deleted');
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

// ── Selection summary bar ──────────────────────────────────────────────────────

class _SelectionBar extends StatelessWidget {
  final int count;
  final int net;
  final bool isPositive;
  final VoidCallback onClear;
  final VoidCallback onShare;

  const _SelectionBar({
    required this.count,
    required this.net,
    required this.isPositive,
    required this.onClear,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final color = isPositive ? Colors.green.shade600 : Colors.red.shade400;
    final sign  = isPositive ? '+' : '';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: cs.inversePrimary, size: 18),
          const SizedBox(width: 8),
          Text(
            '$count selected',
            style: TextStyle(
                color: cs.onInverseSurface,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 16,
              color: cs.onInverseSurface.withValues(alpha: 0.3)),
          const SizedBox(width: 8),
          Text(
            '$sign${MoneyFormatter.format(net.abs())}',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Spacer(),
          // Share summary receipt
          GestureDetector(
            onTap: onShare,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.inversePrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.share_rounded, color: cs.onInverseSurface, size: 16),
                const SizedBox(width: 4),
                Text('Share',
                    style: TextStyle(
                        color: cs.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, color: cs.onInverseSurface, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Filter summary bar ─────────────────────────────────────────────────────────

class _FilterSummaryBar extends StatelessWidget {
  final int count;
  final int net;
  final bool isPositive;
  final VoidCallback onShare;
  final VoidCallback onClear;

  const _FilterSummaryBar({
    required this.count,
    required this.net,
    required this.isPositive,
    required this.onShare,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final color = isPositive ? Colors.green.shade400 : Colors.red.shade400;
    final sign  = isPositive ? '+' : '−';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded,
              color: cs.onInverseSurface.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 6),
          Text(
            '$count result${count == 1 ? '' : 's'}',
            style: TextStyle(
                color: cs.onInverseSurface.withValues(alpha: 0.8),
                fontSize: 13),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 14,
              color: cs.onInverseSurface.withValues(alpha: 0.3)),
          const SizedBox(width: 6),
          Text(
            '$sign${MoneyFormatter.format(net.abs())}',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          const Spacer(),
          // Share button
          GestureDetector(
            onTap: onShare,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.inversePrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.share_rounded,
                    color: cs.onInverseSurface, size: 15),
                const SizedBox(width: 4),
                Text('Share',
                    style: TextStyle(
                        color: cs.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close,
                color: cs.onInverseSurface.withValues(alpha: 0.6), size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Transaction tile ───────────────────────────────────────────────────────────

class _TxTile extends StatelessWidget {
  final Transaction tx;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final VoidCallback onReceipt;

  const _TxTile({
    required this.tx,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    required this.onReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final cfg   = txTypeConfigs[tx.type];
    final color = cfg?.color ?? Theme.of(context).colorScheme.primary;
    final cs    = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(tx.id),
      direction: isSelecting
          ? DismissDirection.none
          : DismissDirection.endToStart,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected
            ? cs.primaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                // Checkbox appears in select mode
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: isSelecting
                      ? Padding(
                          key: const ValueKey('checkbox'),
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked,
                            color: isSelected ? cs.primary : cs.onSurfaceVariant,
                            size: 22,
                          ),
                        )
                      : const SizedBox(key: ValueKey('no-checkbox')),
                ),

                // Type icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isSelected ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cfg?.icon ?? Icons.receipt,
                      color: color, size: 18),
                ),
                const SizedBox(width: 12),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.note.isNotEmpty
                            ? tx.note
                            : tx.type.replaceAll('_', ' '),
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            DateFormatter.smart(tx.occurredAt),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          if (tx.tags.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            ...tx.tags.take(2).map((t) => Container(
                                  margin: const EdgeInsets.only(right: 3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color:
                                        color.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(t.name,
                                      style: TextStyle(
                                          fontSize: 10, color: color)),
                                )),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  '${amountPrefix(tx.type)}${MoneyFormatter.format(tx.amountPaisa)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: amountColor(tx.type),
                    fontSize: 14,
                  ),
                ),

                // Receipt icon — always visible, tap to generate
                if (!isSelecting) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onReceipt,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Enhanced Filters Panel ─────────────────────────────────────────────────────

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
    if (quickTime != 'custom' || filterFrom == null || filterTo == null) {
      return 'Custom';
    }
    final from = DateTime.parse(filterFrom!).toLocal();
    final to   = DateTime.parse(filterTo!).toLocal();
    final fmt  = DateFormat('d MMM');
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
            bottom: BorderSide(color: cs.outline.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date presets
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(label: 'All Time', selected: quickTime == null,
                    onTap: () => onQuickTimeChanged(null)),
                _Chip(label: 'Today', selected: quickTime == 'today',
                    onTap: () => onQuickTimeChanged('today')),
                _Chip(label: 'Yesterday', selected: quickTime == 'yesterday',
                    onTap: () => onQuickTimeChanged('yesterday')),
                _Chip(label: 'This Month', selected: quickTime == 'this_month',
                    onTap: () => onQuickTimeChanged('this_month')),
                _Chip(label: 'Last Month', selected: quickTime == 'last_month',
                    onTap: () => onQuickTimeChanged('last_month')),
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

          // Type chips
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(label: 'All', selected: filterType == null,
                    onTap: () => onTypeChanged(null)),
                ...txTypeConfigs.entries.map((e) => _Chip(
                      label: e.value.label,
                      selected: filterType == e.key,
                      color: e.value.color,
                      onTap: () =>
                          onTypeChanged(filterType == e.key ? null : e.key),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Dropdowns
          Row(
            children: [
              Expanded(
                child: _DropdownFilter(
                  hint: 'Money Source',
                  value: filterBucketId,
                  items: buckets
                      .map((b) => DropdownMenuItem(
                          value: b.id as String,
                          child: Text(b.name as String)))
                      .toList(),
                  onChanged: onBucketChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownFilter(
                  hint: 'Person',
                  value: filterPersonId,
                  items: people
                      .map((p) => DropdownMenuItem(
                          value: p.id as String,
                          child: Text(p.name as String)))
                      .toList(),
                  onChanged: onPersonChanged,
                ),
              ),
            ],
          ),

          // Tag chips
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: tags
                    .map((t) => _Chip(
                          label: t.name as String,
                          selected: filterTagId == (t.id as String),
                          color: cs.secondary,
                          onTap: () => onTagChanged(
                              filterTagId == (t.id as String)
                                  ? null
                                  : t.id as String),
                        ))
                    .toList(),
              ),
            ),
          ],

          // Clear
          if (activeCount > 0) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 14),
                label: Text(
                    'Clear $activeCount filter${activeCount > 1 ? "s" : ""}'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
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

// ── Reusable chip ──────────────────────────────────────────────────────────────

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
              Icon(icon, size: 13,
                  color: selected ? Colors.white : c),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : c)),
          ],
        ),
      ),
    );
  }
}

// ── Dropdown filter ────────────────────────────────────────────────────────────

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(hint,
              style: const TextStyle(color: Colors.grey)),
        ),
        ...items,
      ],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
    );
  }
}
