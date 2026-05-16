import 'package:expense_tracker_app/core/formatters/date_formatter.dart';
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
import 'package:intl/intl.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;
  final String? initialType;

  const QuickAddSheet({super.key, this.transaction, this.initialType});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  final _noteFocus  = FocusNode();

  late String _type;
  String? _fromBucketId;
  String? _toBucketId;
  String? _personId;
  DateTime _occurredAt  = DateTime.now();
  List<String> _tagIds  = [];
  bool _isSaving        = false;
  bool _dateCustomized  = false;

  bool get _isEdit       => widget.transaction != null;
  bool get _needsFrom    => ['expense','transfer','loan_given','repayment_paid'].contains(_type);
  bool get _needsTo      => ['income','transfer','loan_taken','repayment_received'].contains(_type);
  bool get _needsPerson  => ['loan_given','loan_taken','repayment_received','repayment_paid'].contains(_type);

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? 'expense';
    final tx = widget.transaction;
    if (tx != null) {
      _type         = tx.type;
      _amountCtrl.text =
          (tx.amountPaisa / 100).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      _noteCtrl.text   = tx.note;
      _fromBucketId    = tx.fromBucketId;
      _toBucketId      = tx.toBucketId;
      _personId        = tx.personId;
      _occurredAt      = tx.occurredAt;
      _dateCustomized  = true;
      _tagIds          = tx.tags.map((t) => t.id).toList();
    } else {
      final defaultId = ref.read(defaultMoneySourceProvider);
      if (defaultId != null) _fromBucketId = defaultId;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickSource({required bool isFrom}) async {
    final all = ref.read(bucketsProvider).value ?? [];
    final exclude = isFrom ? null : _fromBucketId;
    final list = all.where((b) => b.archivedAt == null && b.id != exclude).toList();

    if (list.isEmpty) {
      if (mounted) showErrorSnackBar(context,
          'No money sources yet — add one in Settings → Money Sources');
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _MoneySourcePicker(
        buckets: list,
        selectedId: isFrom ? _fromBucketId : _toBucketId,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() { if (isFrom) _fromBucketId = picked; else _toBucketId = picked; });
  }

  Future<void> _pickDateTime() async {
    // Step 1 — Calendar
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null) return; // user cancelled date — stop here

    // Step 2 — Clock (always runs after a date is confirmed)
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (!mounted) return;

    setState(() {
      final h = time?.hour   ?? _occurredAt.hour;
      final m = time?.minute ?? _occurredAt.minute;
      _occurredAt     = DateTime(date.year, date.month, date.day, h, m);
      _dateCustomized = true;
    });
  }

  Future<void> _pickPerson() async {
    final people = ref.read(peopleProvider).value ?? [];
    final active = people.where((p) => p.archivedAt == null).toList();
    if (active.isEmpty) {
      if (mounted) showErrorSnackBar(context, 'No people added yet');
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _PersonPicker(people: active, selectedId: _personId),
    );
    if (picked == null || !mounted) return;
    setState(() => _personId = picked);
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) { showErrorSnackBar(context, 'Enter a valid amount'); return; }
    if (_needsFrom && _fromBucketId == null) { showErrorSnackBar(context, 'Select a money source'); return; }
    if (_needsTo   && _toBucketId == null)   { showErrorSnackBar(context, 'Select a destination'); return; }
    if (_type == 'transfer' && _fromBucketId == _toBucketId) {
      showErrorSnackBar(context, 'Source and destination must be different'); return;
    }
    if (_needsPerson && _personId == null) { showErrorSnackBar(context, 'Select a person'); return; }

    setState(() => _isSaving = true);
    try {
      final req = CreateTransactionRequest(
        type:         _type,
        amountPaisa:  (amount * 100).round(),
        fromBucketId: _needsFrom ? _fromBucketId : null,
        toBucketId:   _needsTo   ? _toBucketId   : null,
        personId:     _needsPerson ? _personId    : null,
        note:         _noteCtrl.text.trim(),
        occurredAt:   (_dateCustomized ? _occurredAt : DateTime.now()).toUtc(),
        tagIds:       _tagIds,
      );
      if (_isEdit) {
        await ref.read(transactionsProvider.notifier).editTransaction(widget.transaction!.id, req);
        if (mounted) showSuccessSnackBar(context, 'Transaction updated');
      } else {
        await ref.read(transactionsProvider.notifier).create(req);
        if (mounted) showSuccessSnackBar(context, 'Transaction saved');
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final buckets    = ref.watch(bucketsProvider).value ?? [];
    final tags       = ref.watch(tagsProvider).value ?? [];
    final activeTags = tags.where((t) => t.archivedAt == null).toList();
    final cs         = Theme.of(context).colorScheme;
    final typeColor  = txTypeConfigs[_type]!.color;

    final fromName = _fromBucketId == null ? null
        : buckets.where((b) => b.id == _fromBucketId).firstOrNull?.name;
    final toName = _toBucketId == null ? null
        : buckets.where((b) => b.id == _toBucketId).firstOrNull?.name;
    final personName = _personId == null ? null
        : (ref.read(peopleProvider).value ?? [])
            .where((p) => p.id == _personId).firstOrNull?.name;

    // Sort tags: selected first, then rest
    final sortedTags = [
      ...activeTags.where((t) => _tagIds.contains(t.id)),
      ...activeTags.where((t) => !_tagIds.contains(t.id)),
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle ──────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [

                  // ── Type chips ────────────────────────────────────────
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: txTypeConfigs.entries.map((e) {
                        final sel = _type == e.key;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _type = e.key;
                            _fromBucketId = null;
                            _toBucketId   = null;
                            _personId     = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? e.value.color : e.value.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(e.value.icon, size: 13,
                                  color: sel ? Colors.white : e.value.color),
                              const SizedBox(width: 5),
                              Text(e.value.label,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: sel ? Colors.white : e.value.color)),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Amount — HERO ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('৳',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            autofocus: !_isEdit,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                              letterSpacing: -1,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: cs.outlineVariant,
                                letterSpacing: -1,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _noteFocus.requestFocus(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Note — borderless ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _noteCtrl,
                      focusNode: _noteFocus,
                      maxLines: 1,
                      style: TextStyle(fontSize: 15, color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Write a note…',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.edit_note_outlined,
                            size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),

                  // ── Pills row ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [

                        // From source
                        if (_needsFrom)
                          _Pill(
                            icon: Icons.account_balance_wallet_outlined,
                            label: fromName ?? (_type == 'transfer' ? 'From' : 'Source ↓'),
                            empty: fromName == null,
                            trailing: fromName != null ? Icons.swap_horiz_rounded : null,
                            onTap: () => _pickSource(isFrom: true),
                          ),

                        // To source
                        if (_needsTo)
                          _Pill(
                            icon: Icons.account_balance_wallet_outlined,
                            label: toName ?? (_type == 'transfer' ? 'To ↓' : 'Source ↓'),
                            empty: toName == null,
                            trailing: toName != null ? Icons.swap_horiz_rounded : null,
                            onTap: () => _pickSource(isFrom: false),
                          ),

                        // Date
                        _Pill(
                          icon: Icons.schedule_outlined,
                          label: _dateCustomized
                              ? DateFormat('d MMM, h:mm a').format(_occurredAt)
                              : 'Now',
                          active: _dateCustomized,
                          onTap: _pickDateTime,
                          onLongPress: _dateCustomized
                              ? () => setState(() {
                                  _occurredAt     = DateTime.now();
                                  _dateCustomized = false;
                                })
                              : null,
                        ),

                        // Person
                        if (_needsPerson)
                          _Pill(
                            icon: Icons.person_outline,
                            label: personName ?? 'Person',
                            empty: personName == null,
                            onTap: _pickPerson,
                          ),
                      ],
                    ),
                  ),

                  // ── Tags — always visible, horizontal scroll ───────────
                  if (activeTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: sortedTags.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, i) {
                          final tag = sortedTags[i];
                          final sel = _tagIds.contains(tag.id);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel) {
                                _tagIds = _tagIds.where((id) => id != tag.id).toList();
                              } else {
                                _tagIds = [..._tagIds, tag.id];
                              }
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: sel
                                    ? cs.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel
                                      ? cs.primary.withValues(alpha: 0.4)
                                      : cs.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                tag.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: sel
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Save button ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: typeColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              _isEdit ? 'Update' : 'Save',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small pill chip ────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool empty;
  final bool active;
  final IconData? trailing;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _Pill({
    required this.icon,
    required this.label,
    this.empty = false,
    this.active = false,
    this.trailing,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bg    = empty    ? cs.errorContainer.withValues(alpha: 0.3)
                      : active   ? cs.primaryContainer
                                 : cs.surfaceContainerHigh;
    final Color fgCol = empty    ? cs.error
                      : active   ? cs.primary
                                 : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: fgCol),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: empty ? cs.error : cs.onSurface)),
          if (trailing != null) ...[
            const SizedBox(width: 2),
            Icon(trailing, size: 13, color: fgCol),
          ],
        ]),
      ),
    );
  }
}

// ── Money source picker ────────────────────────────────────────────────────────

class _MoneySourcePicker extends StatelessWidget {
  final List<Bucket> buckets;
  final String? selectedId;
  const _MoneySourcePicker({required this.buckets, this.selectedId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(children: [
            Text('Money Source',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ]),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: buckets.length,
            itemBuilder: (ctx, i) {
              final b  = buckets[i];
              final ok = b.id == selectedId;
              return ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: ok ? cs.primaryContainer : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined, size: 18,
                      color: ok ? cs.primary : cs.onSurfaceVariant),
                ),
                title: Text(b.name,
                    style: TextStyle(fontWeight: ok ? FontWeight.w600 : FontWeight.normal)),
                subtitle: Text(MoneyFormatter.format(b.startingBalancePaisa),
                    style: const TextStyle(fontSize: 12)),
                trailing: ok ? Icon(Icons.check_circle_rounded, color: cs.primary) : null,
                onTap: () => Navigator.pop(ctx, b.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Person picker ──────────────────────────────────────────────────────────────

class _PersonPicker extends StatelessWidget {
  final List<Person> people;
  final String? selectedId;
  const _PersonPicker({required this.people, this.selectedId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text('Select Person',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: people.length,
            itemBuilder: (ctx, i) {
              final p  = people[i];
              final ok = p.id == selectedId;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: ok ? cs.primaryContainer : cs.surfaceContainerHighest,
                  child: Text(p.name[0].toUpperCase(),
                      style: TextStyle(
                          color: ok ? cs.primary : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                ),
                title: Text(p.name,
                    style: TextStyle(fontWeight: ok ? FontWeight.w600 : FontWeight.normal)),
                trailing: ok ? Icon(Icons.check_circle_rounded, color: cs.primary) : null,
                onTap: () => Navigator.pop(ctx, p.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
