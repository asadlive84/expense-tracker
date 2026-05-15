import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/reports/providers/reports_provider.dart';
import 'package:expense_tracker_app/features/tags/providers/tags_provider.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    final now = DateTime.now();
    final from = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    final to = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
    final totalsAsync = ref.watch(tagTotalsProvider('$from,$to'));

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTagForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Tag'),
      ),
      body: tagsAsync.when(
        loading: () => skeletonList(count: 8),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tags) {
          final active = tags.where((t) => t.archivedAt == null).toList();
          final archived = tags.where((t) => t.archivedAt != null).toList();

          final totalsMap = <String, int>{};
          totalsAsync.whenData((items) {
            for (final t in items) totalsMap[t.tagId] = t.totalPaisa;
          });

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tagsProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (active.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No tags yet.')),
                  ),
                ...active.map((tag) => ListTile(
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.label_outline, size: 18),
                  ),
                  title: Text(tag!.name),
                  subtitle: totalsMap.containsKey(tag.id)
                      ? Text('${MoneyFormatter.format(totalsMap[tag.id]!)} this month',
                          style: const TextStyle(fontSize: 12))
                      : null,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _showTagForm(context, ref, tag: tag);
                      if (v == 'archive') _confirmArchive(context, ref, tag!.id, tag!.name);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Rename')),
                      PopupMenuItem(value: 'archive', child: Text('Archive')),
                    ],
                  ),
                )),
                if (archived.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text('Archived (${archived.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  ...archived.map((tag) => ListTile(
                    enabled: false,
                    leading: const Icon(Icons.label_off_outlined),
                    title: Text(tag!.name),
                    trailing: TextButton(
                      onPressed: () {
                        ref.read(tagsProvider.notifier).editTag(tag!.id, archived: false)
                          .then((_) { if (context.mounted) showSuccessSnackBar(context, 'Restored'); })
                          .catchError((Object e) { if (context.mounted) showErrorSnackBar(context, e); });
                      },
                      child: const Text('Restore'),
                    ),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTagForm(BuildContext context, WidgetRef ref, {Tag? tag}) {
    final nameCtrl = TextEditingController(text: tag?.name ?? '');
    final isEdit = tag != null;

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
            Text(isEdit ? 'Rename Tag' : 'New Tag',
              style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tag name',
                border: OutlineInputBorder(),
                hintText: 'e.g. food, transport, family',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim().toLowerCase();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  if (isEdit) {
                    await ref.read(tagsProvider.notifier).editTag(tag!.id, name: name);
                    if (context.mounted) showSuccessSnackBar(context, 'Tag renamed');
                  } else {
                    await ref.read(tagsProvider.notifier).create(name);
                    if (context.mounted) showSuccessSnackBar(context, 'Tag created');
                  }
                } catch (e) {
                  if (context.mounted) showErrorSnackBar(context, e);
                }
              },
              child: Text(isEdit ? 'Rename' : 'Create'),
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
        title: Text('Archive "$name"?'),
        content: const Text('Archived tags won\'t appear in the tag picker.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tagsProvider.notifier).editTag(id, archived: true)
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
