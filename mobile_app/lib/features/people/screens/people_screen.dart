import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:expense_tracker_app/features/people/providers/people_provider.dart';
import 'package:expense_tracker_app/features/reports/providers/reports_provider.dart';
import 'package:expense_tracker_app/shared/widgets/error_helpers.dart';
import 'package:expense_tracker_app/shared/widgets/skeleton_widgets.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(peopleProvider);
    final balancesAsync = ref.watch(personBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPersonForm(context, ref),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Person'),
      ),
      body: peopleAsync.when(
        loading: () => skeletonList(count: 5, card: true),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (people) {
          final active = people.where((p) => p.archivedAt == null).toList();
          final archived = people.where((p) => p.archivedAt != null).toList();

          final balanceMap = <String, int>{};
          balancesAsync.whenData((items) {
            for (final b in items) {
              balanceMap[b.personId] = b.netPaisa;
            }
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(peopleProvider);
              ref.invalidate(personBalancesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (active.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No people yet.')),
                  ),
                ...active.map((p) => _PersonCard(
                  person: p,
                  netPaisa: balanceMap[p.id],
                  onEdit: () => _showPersonForm(context, ref, person: p),
                  onArchive: () => _confirmArchive(context, ref, p.id, p.name),
                )),
                if (archived.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text('Archived (${archived.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  ...archived.map((p) => _PersonCard(
                    person: p,
                    netPaisa: balanceMap[p.id],
                    onEdit: () => _showPersonForm(context, ref, person: p),
                    onArchive: () {
                      ref.read(peopleProvider.notifier).editPerson(p.id, archived: false)
                        .then((_) { if (context.mounted) showSuccessSnackBar(context, 'Restored'); })
                        .catchError((Object e) { if (context.mounted) showErrorSnackBar(context, e); });
                    },
                    archiveLabel: 'Restore',
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPersonForm(BuildContext context, WidgetRef ref, {Person? person}) {
    final nameCtrl = TextEditingController(text: person?.name ?? '');
    final isEdit = person != null;

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
            Text(isEdit ? 'Edit Person' : 'Add Person',
              style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  if (isEdit) {
                    await ref.read(peopleProvider.notifier).editPerson(person.id, name: name);
                    if (context.mounted) showSuccessSnackBar(context, 'Updated');
                  } else {
                    await ref.read(peopleProvider.notifier).create(name);
                    if (context.mounted) showSuccessSnackBar(context, 'Added');
                  }
                } catch (e) {
                  if (context.mounted) showErrorSnackBar(context, e);
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
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
        title: Text('Archive $name?'),
        content: const Text('They will be hidden from dropdowns.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(peopleProvider.notifier).editPerson(id, archived: true)
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

class _PersonCard extends StatelessWidget {
  final Person person;
  final int? netPaisa;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final String archiveLabel;

  const _PersonCard({
    required this.person,
    this.netPaisa,
    required this.onEdit,
    required this.onArchive,
    this.archiveLabel = 'Archive',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final net = netPaisa ?? 0;
    final isPositive = net > 0;
    final isZero = net == 0;

    String statusLabel;
    Color statusColor;
    if (isZero) {
      statusLabel = 'Settled';
      statusColor = cs.onSurfaceVariant;
    } else if (isPositive) {
      statusLabel = 'Owes you ${MoneyFormatter.format(net)}';
      statusColor = Colors.green.shade600;
    } else {
      statusLabel = 'You owe ${MoneyFormatter.format(net.abs())}';
      statusColor = Colors.red.shade400;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(
            (person!.name)[0].toUpperCase(),
            style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(person.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 13)),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'archive') onArchive();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Rename')),
            PopupMenuItem(value: 'archive', child: Text(archiveLabel)),
          ],
        ),
      ),
    );
  }
}
