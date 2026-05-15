import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:expense_tracker_app/core/formatters/date_formatter.dart';
import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/shared/constants/tx_type_config.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ── Public entry points ────────────────────────────────────────────────────────

/// Single-transaction receipt.
Future<void> showReceiptSheet(
  BuildContext context,
  Transaction tx, {
  String? fromBucketName,
  String? toBucketName,
  String? personName,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReceiptSheet(
      tx: tx,
      fromBucketName: fromBucketName,
      toBucketName: toBucketName,
      personName: personName,
    ),
  );
}

/// Multi-transaction summary receipt.
Future<void> showSummaryReceiptSheet(
  BuildContext context,
  List<Transaction> transactions, {
  Map<String, String> bucketNames = const {},
  Map<String, String> personNames = const {},
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SummaryReceiptSheet(
      transactions: transactions,
      bucketNames: bucketNames,
      personNames: personNames,
    ),
  );
}

// ── Receipt bottom sheet ───────────────────────────────────────────────────────

class _ReceiptSheet extends StatefulWidget {
  final Transaction tx;
  final String? fromBucketName;
  final String? toBucketName;
  final String? personName;

  const _ReceiptSheet({
    required this.tx,
    this.fromBucketName,
    this.toBucketName,
    this.personName,
  });

  @override
  State<_ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends State<_ReceiptSheet> {
  final _receiptKey = GlobalKey();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
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
                  Text('Receipt',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Receipt card (captured as image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RepaintBoundary(
                key: _receiptKey,
                child: _ReceiptCard(
                  tx: widget.tx,
                  fromBucketName: widget.fromBucketName,
                  toBucketName: widget.toBucketName,
                  personName: widget.personName,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.download_rounded),
                      label: Text(_saving ? 'Saving…' : 'Save PNG'),
                      onPressed: _saving
                          ? null
                          : () => _saveAndShare(isPng: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share'),
                      onPressed:
                          _saving ? null : () => _saveAndShare(isPng: true, share: true),
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

  Future<void> _saveAndShare({required bool isPng, bool share = false}) async {
    setState(() => _saving = true);
    try {
      final bytes = await _captureReceipt(isPng: isPng);
      final ext   = isPng ? 'png' : 'jpg';
      final dir   = await getTemporaryDirectory();
      final file  = File('${dir.path}/receipt_${widget.tx.id}.$ext');
      await file.writeAsBytes(bytes);

      if (share) {
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/$ext')],
          subject: 'Transaction Receipt',
        );
      } else {
        // Save → open share sheet so user can save to Downloads / Gallery
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/$ext')],
          subject: 'Transaction Receipt',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<Uint8List> _captureReceipt({required bool isPng}) async {
    final boundary =
        _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final format =
        isPng ? ui.ImageByteFormat.png : ui.ImageByteFormat.rawRgba;
    final byteData = await image.toByteData(format: format);
    return byteData!.buffer.asUint8List();
  }
}

// ── Receipt card widget (what gets rendered into the image) ───────────────────

class _ReceiptCard extends StatelessWidget {
  final Transaction tx;
  final String? fromBucketName;
  final String? toBucketName;
  final String? personName;

  const _ReceiptCard({
    required this.tx,
    this.fromBucketName,
    this.toBucketName,
    this.personName,
  });

  @override
  Widget build(BuildContext context) {
    final cfg   = txTypeConfigs[tx.type];
    final color = cfg?.color ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cfg?.icon ?? Icons.receipt_long,
                      color: color, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  MoneyFormatter.format(tx.amountPaisa),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (cfg?.label ?? tx.type).toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
          ),

          // Divider with notches
          _NotchedDivider(color: color.withValues(alpha: 0.2)),

          // Details
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                if (fromBucketName != null)
                  _Row(
                    label: tx.type == 'transfer' ? 'From' : 'Source',
                    value: fromBucketName!,
                  ),
                if (toBucketName != null)
                  _Row(
                    label: tx.type == 'transfer' ? 'To' : 'Destination',
                    value: toBucketName!,
                  ),
                if (personName != null)
                  _Row(label: 'Person', value: personName!),
                _Row(
                  label: 'Date',
                  value: DateFormatter.full(tx.occurredAt.toLocal()),
                ),
                if (tx.note.isNotEmpty)
                  _Row(label: 'Note', value: tx.note),
                if (tx.tags.isNotEmpty)
                  _Row(
                    label: 'Tags',
                    value: tx.tags.map((t) => t.name).join(', '),
                  ),
              ],
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ref: ${tx.id.substring(0, 8).toUpperCase()}…',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  'Expense Tracker · ${DateFormatter.dateOnly(DateTime.now())}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// Decorative divider with circular notches on left and right edges
class _NotchedDivider extends StatelessWidget {
  final Color color;
  const _NotchedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DashedLinePainter(color: color)),
          ),
          Positioned(
              left: -12, top: 0,
              child: _Notch(bg: bg, color: color)),
          Positioned(
              right: -12, top: 0,
              child: _Notch(bg: bg, color: color)),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  final Color bg;
  final Color color;
  const _Notch({required this.bg, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
      );
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashW = 6.0;
    const gapW  = 4.0;
    double x    = 16;
    final y     = size.height / 2;

    while (x < size.width - 16) {
      canvas.drawLine(Offset(x, y), Offset(x + dashW, y), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ════════════════════════════════════════════════════════════════════════════
// Multi-transaction summary receipt
// ════════════════════════════════════════════════════════════════════════════

class _SummaryReceiptSheet extends StatefulWidget {
  final List<Transaction> transactions;
  final Map<String, String> bucketNames;
  final Map<String, String> personNames;

  const _SummaryReceiptSheet({
    required this.transactions,
    required this.bucketNames,
    required this.personNames,
  });

  @override
  State<_SummaryReceiptSheet> createState() => _SummaryReceiptSheetState();
}

class _SummaryReceiptSheetState extends State<_SummaryReceiptSheet> {
  final _key = GlobalKey();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Text('Summary Receipt',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),
            const SizedBox(height: 8),

            // Scrollable preview of the card
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RepaintBoundary(
                  key: _key,
                  child: _SummaryReceiptCard(
                    transactions: widget.transactions,
                    bucketNames: widget.bucketNames,
                    personNames: widget.personNames,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_rounded),
                    label: Text(_saving ? 'Saving…' : 'Save PNG'),
                    onPressed: _saving ? null : () => _export(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                    onPressed: _saving ? null : () => _export(share: true),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export({bool share = false}) async {
    setState(() => _saving = true);
    try {
      final boundary = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/summary_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'Transaction Summary',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Summary receipt card ───────────────────────────────────────────────────────

class _SummaryReceiptCard extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<String, String> bucketNames;
  final Map<String, String> personNames;

  const _SummaryReceiptCard({
    required this.transactions,
    required this.bucketNames,
    required this.personNames,
  });

  bool _isPositive(String type) =>
      type == 'income' || type == 'repayment_received' || type == 'loan_taken';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs     = Theme.of(context).colorScheme;

    // Totals
    int totalIncomePaisa  = 0;
    int totalExpensePaisa = 0;
    int netPaisa          = 0;
    for (final tx in transactions) {
      if (_isPositive(tx.type)) {
        totalIncomePaisa += tx.amountPaisa;
        netPaisa         += tx.amountPaisa;
      } else {
        totalExpensePaisa += tx.amountPaisa;
        netPaisa          -= tx.amountPaisa;
      }
    }
    final isNetPos = netPaisa >= 0;
    final netColor = isNetPos ? Colors.green.shade600 : Colors.red.shade400;

    // Date range label
    final sorted = [...transactions]
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    String dateLabel;
    if (sorted.isEmpty) {
      dateLabel = '';
    } else if (sorted.length == 1 ||
        DateFormatter.dateOnly(sorted.first.occurredAt) ==
            DateFormatter.dateOnly(sorted.last.occurredAt)) {
      dateLabel = DateFormatter.dateOnly(sorted.first.occurredAt);
    } else {
      dateLabel =
          '${DateFormatter.dateOnly(sorted.first.occurredAt)} – ${DateFormatter.dateOnly(sorted.last.occurredAt)}';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.receipt_long_rounded,
                      color: cs.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Expense Tracker',
                    style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                  const Spacer(),
                  Text('Summary',
                    style: TextStyle(
                        color: cs.primary.withValues(alpha: 0.7),
                        fontSize: 12)),
                ]),
                const SizedBox(height: 14),
                Text(
                  '${isNetPos ? '+' : '−'}${MoneyFormatter.format(netPaisa.abs())}',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: netColor,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transactions.length} transaction${transactions.length == 1 ? '' : 's'} · $dateLabel',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                // Income / Expense pills
                Row(children: [
                  _Pill(
                    label: 'Income',
                    value: MoneyFormatter.format(totalIncomePaisa),
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  _Pill(
                    label: 'Expense',
                    value: MoneyFormatter.format(totalExpensePaisa),
                    color: Colors.red.shade400,
                  ),
                ]),
              ],
            ),
          ),

          _NotchedDivider(color: cs.primary.withValues(alpha: 0.15)),

          // ── Transaction rows ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(
              children: sorted.map((tx) {
                final cfg   = txTypeConfigs[tx.type];
                final color = cfg?.color ?? cs.primary;
                final isPos = _isPositive(tx.type);
                final bucketName = tx.fromBucketId != null
                    ? bucketNames[tx.fromBucketId]
                    : tx.toBucketId != null
                        ? bucketNames[tx.toBucketId]
                        : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type dot
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Note + meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.note.isNotEmpty
                                  ? tx.note
                                  : (cfg?.label ?? tx.type),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                DateFormatter.full(tx.occurredAt.toLocal()),
                                if (bucketName != null) bucketName,
                              ].join(' · '),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Amount
                      Text(
                        '${isPos ? '+' : '−'}${MoneyFormatter.format(tx.amountPaisa)}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isPos
                                ? Colors.green.shade600
                                : Colors.red.shade400),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Footer ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Text(
              'Generated ${DateFormatter.full(DateTime.now())}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Pill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: color)),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );
}
