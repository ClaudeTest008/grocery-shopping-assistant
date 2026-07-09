import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/shopping_list_repositories.dart';
import '../domain/shopping_list.dart';
import 'shopping_lists_providers.dart';

class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(shoppingListsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping lists')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New list'),
      ),
      body: AsyncValueWidget(
        value: lists,
        onRetry: () => ref.invalidate(shoppingListsProvider),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.checklist_rounded,
                title: 'No lists yet',
                message:
                    'Create a list, then let the optimizer find the cheapest '
                    'way to shop it.',
                actionLabel: 'Create list',
                onAction: () => _createDialog(context, ref),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(shoppingListsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ListCard(list: items[i]),
                ),
              ),
      ),
    );
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New shopping list'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget (optional)',
                prefixText: r'$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (created != true || nameController.text.trim().isEmpty) return;
    final list = await ref
        .read(shoppingListRepositoryProvider)
        .create(
          nameController.text.trim(),
          budget: double.tryParse(budgetController.text),
        );
    ref.invalidate(shoppingListsProvider);
    if (context.mounted) await context.push('/lists/${list.id}');
  }
}

class _ListCard extends ConsumerWidget {
  const _ListCard({required this.list});

  final ShoppingList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(shoppingListRepositoryProvider);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/lists/${list.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) async {
                      switch (action) {
                        case 'duplicate':
                          await repo.duplicate(list.id);
                        case 'delete':
                          await repo.delete(list.id);
                      }
                      ref.invalidate(shoppingListsProvider);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${list.checkedCount}/${list.items.length} items'
                '${list.budget != null ? '  ·  budget ${Formatters.currency(list.budget!)}' : ''}',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: list.progress,
                  minHeight: 6,
                  backgroundColor: context.colors.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
