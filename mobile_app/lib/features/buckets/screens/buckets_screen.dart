import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/core/storage/default_source_storage.dart';
import 'package:expense_tracker_app/features/auth/data/auth_api.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:expense_tracker_app/features/reports/providers/reports_provider.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BucketsScreen extends ConsumerWidget {
  const BucketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketsAsync = ref.watch(bucketsProvider);
    final balancesAsync = ref.watch(bucketBalancesProvider);
    final defaultId = ref.watch(defaultMoneySourceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Money Sources')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Money Source'),
      ),
      body: bucketsAsync.when(
        loading: () => skeletonList(count: 5, card: true),
        error: (e, _) => _ErrorRetry(error: e, onRetry: () => ref.refresh(bucketsProvider)),
        data: (buckets) {
          final active = buckets.where((b) => b.archivedAt == null).toList();
          final archived = buckets.where((b) => b.archivedAt != null).toList();

          final balanceMap = <String, int>{};
          balancesAsync.whenData((items) {
            for (final b in items) {
              balanceMap[b.bucketId] = b.balancePaisa;
            }
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(bucketsProvider);
              ref.invalidate(bucketBalancesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (active.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No money sources yet. Create one!')),
                  ),
                ...active.map((b) => _BucketCard(
                  bucket: b,
                  balance: balanceMap[b.id],
                  isDefault: defaultId == b.id,
                  onEdit: () => _showForm(context, ref, bucket: b),
                  onArchive: () => _confirmArchive(context, ref, b.id, b.name),
                  onSetDefault: () => _setDefault(context, ref, b.id),
                  onClearDefault: () => _clearDefault(context, ref),
                )),
                if (archived.isNotEmpty) ...[
                  _SectionHeader(title: 'Archived (${archived.length})'),
                  ...archived.map((b) => _BucketCard(
                    bucket: b,
                    balance: balanceMap[b.id],
                    isDefault: false,
                    onEdit: () => _showForm(context, ref, bucket: b),
                    onArchive: () => ref.read(bucketsProvider.notifier)
                        .editBucket(b.id, archived: false)
                        .catchError((Object e) => showErrorSnackBar(context, e)),
                    onSetDefault: () {},
                    onClearDefault: () {},
                    archiveLabel: 'Unarchive',
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _setDefault(BuildContext context, WidgetRef ref, String id) async {
    // Update locally first for instant feedback
    ref.read(defaultMoneySourceProvider.notifier).state = id;
    await DefaultSourceStorage.write(id);
    // Sync to server
    try {
      await ref.read(authApiProvider).updateProfile(defaultBucketId: id);
    } catch (_) {
      // Local update succeeded — server sync failure is non-critical
    }
    if (context.mounted) showSuccessSnackBar(context, 'Default money source set');
  }

  Future<void> _clearDefault(BuildContext context, WidgetRef ref) async {
    ref.read(defaultMoneySourceProvider.notifier).state = null;
    await DefaultSourceStorage.clear();
    try {
      await ref.read(authApiProvider).updateProfile(clearDefault: true);
    } catch (_) {}
    if (context.mounted) showSuccessSnackBar(context, 'Default cleared');
  }

  void _showForm(BuildContext context, WidgetRef ref, {Bucket? bucket}) {
    final nameCtrl = TextEditingController(text: bucket?.name ?? '');
    final balanceCtrl = TextEditingController(
      text: bucket == null ? '' : (bucket.startingBalancePaisa / 100).toStringAsFixed(0),
    );
    final isEdit = bucket != null;

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
            Text(
              isEdit ? 'Edit Money Source' : 'New Money Source',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            if (!isEdit) ...[
              const SizedBox(height: 12),
              TextField(
                controller: balanceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Starting balance (৳)',
                  border: OutlineInputBorder(),
                  hintText: '0',
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  if (isEdit) {
                    await ref.read(bucketsProvider.notifier).editBucket(bucket.id, name: name);
                    if (context.mounted) showSuccessSnackBar(context, 'Money source updated');
                  } else {
                    final bal = double.tryParse(balanceCtrl.text) ?? 0;
                    await ref.read(bucketsProvider.notifier).create(name, (bal * 100).round());
                    if (context.mounted) showSuccessSnackBar(context, 'Money source created');
                  }
                } catch (e) {
                  if (context.mounted) showErrorSnackBar(context, e);
                }
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Money Source?'),
        content: Text('$name will be hidden from lists. Transactions are preserved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(bucketsProvider.notifier).editBucket(id, archived: true)
                .then((_) { if (context.mounted) showSuccessSnackBar(context, 'Archived'); })
                .catchError((Object e) { if (context.mounted) showErrorSnackBar(context, e); });
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }
}

class _BucketCard extends StatelessWidget {
  final Bucket bucket;
  final int? balance;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onSetDefault;
  final VoidCallback onClearDefault;
  final String archiveLabel;

  const _BucketCard({
    required this.bucket,
    this.balance,
    required this.isDefault,
    required this.onEdit,
    required this.onArchive,
    required this.onSetDefault,
    required this.onClearDefault,
    this.archiveLabel = 'Archive',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bal = balance ?? bucket.startingBalancePaisa;
    final isPositive = bal >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDefault ? cs.primaryContainer : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded,
                    color: isDefault ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                ),
                if (isDefault)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 1.5),
                      ),
                      child: Icon(Icons.check, size: 8, color: cs.onPrimary),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(bucket.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      if (isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Default',
                            style: TextStyle(fontSize: 10, color: cs.primary,
                              fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    MoneyFormatter.format(bal),
                    style: TextStyle(
                      fontSize: 13,
                      color: isPositive ? Colors.green.shade600 : Colors.red.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'archive') onArchive();
                if (v == 'set_default') onSetDefault();
                if (v == 'clear_default') onClearDefault();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Rename')),
                if (!isDefault)
                  const PopupMenuItem(
                    value: 'set_default',
                    child: Row(children: [
                      Icon(Icons.star_outline, size: 16),
                      SizedBox(width: 8),
                      Text('Set as Default'),
                    ]),
                  )
                else
                  const PopupMenuItem(
                    value: 'clear_default',
                    child: Row(children: [
                      Icon(Icons.star, size: 16),
                      SizedBox(width: 8),
                      Text('Remove Default'),
                    ]),
                  ),
                PopupMenuItem(value: 'archive', child: Text(archiveLabel)),
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
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    )),
  );
}

class _ErrorRetry extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 12),
        Text('Failed to load', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}
