import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/ai_services.dart';
import '../../../core/platform/platform_support.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../products/data/product_repositories.dart';
import '../data/shopping_list_repositories.dart';
import '../domain/shopping_list.dart';
import 'shopping_lists_providers.dart';

const _uuid = Uuid();

class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final _input = TextEditingController();
  final _speech = SpeechToText();
  bool _listening = false;

  @override
  void dispose() {
    _speech.cancel();
    _input.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(shoppingListProvider(widget.listId));
    ref.invalidate(shoppingListsProvider);
    ref.invalidate(optimizationProvider(widget.listId));
  }

  Future<void> _addItem(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    // Link to a catalog product when the name matches one.
    final matches = await ref
        .read(productRepositoryProvider)
        .search(query: trimmed);
    await ref
        .read(shoppingListRepositoryProvider)
        .addItem(
          widget.listId,
          ShoppingItem(
            id: _uuid.v4(),
            listId: widget.listId,
            productId: matches.firstOrNull?.id,
            name: matches.firstOrNull?.name ?? trimmed,
          ),
        );
    _input.clear();
    _refresh();
  }

  Future<void> _addByBarcode() async {
    final barcode = await context.push<String>('/scan');
    if (barcode == null || !mounted) return;
    final product = await ref
        .read(productRepositoryProvider)
        .byBarcode(barcode);
    if (product == null) {
      if (mounted) context.showSnack('No product found for that barcode');
      return;
    }
    await ref
        .read(shoppingListRepositoryProvider)
        .addItem(
          widget.listId,
          ShoppingItem(
            id: _uuid.v4(),
            listId: widget.listId,
            productId: product.id,
            name: product.name,
          ),
        );
    _refresh();
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' && mounted) {
          setState(() => _listening = false);
        }
      },
    );
    if (!available) {
      if (mounted) {
        // speech_to_text_windows works, but only once the OS speech
        // stack is switched on — point there instead of a dead end.
        context.showSnack(
          PlatformSupport.isWindows
              ? 'Voice input unavailable — enable Windows Settings › '
                    'Privacy & security › Speech.'
              : 'Voice input unavailable',
          error: true,
        );
      }
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        _input.text = result.recognizedWords;
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _addItem(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _aiGenerateSheet() async {
    final goalController = TextEditingController();
    final budgetController = TextEditingController();
    try {
      await _runAiGenerate(goalController, budgetController);
    } finally {
      goalController.dispose();
      budgetController.dispose();
    }
  }

  Future<void> _runAiGenerate(
    TextEditingController goalController,
    TextEditingController budgetController,
  ) async {
    final generate = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('AI list builder', style: ctx.text.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Describe the trip and the assistant fills the list.',
              style: ctx.text.bodyMedium?.copyWith(
                color: ctx.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'What do you need?',
                hintText: 'e.g. dinners for a family of 4 this week',
              ),
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
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate items'),
            ),
          ],
        ),
      ),
    );
    if (generate != true || goalController.text.trim().isEmpty || !mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Generating list with AI…')),
    );
    try {
      final (_, items) = await ref
          .read(aiServicesProvider)
          .generateShoppingList(
            goal: goalController.text.trim(),
            listId: widget.listId,
            budget: double.tryParse(budgetController.text),
          );
      final repo = ref.read(shoppingListRepositoryProvider);
      // Link generated items to catalog products where names match.
      final productRepo = ref.read(productRepositoryProvider);
      for (final item in items) {
        final matches = await productRepo.search(query: item.name);
        await repo.addItem(
          widget.listId,
          item.copyWith(productId: matches.firstOrNull?.id),
        );
      }
      _refresh();
      messenger.showSnackBar(
        SnackBar(content: Text('Added ${items.length} items')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Generation failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(shoppingListProvider(widget.listId));
    return Scaffold(
      appBar: AppBar(
        title: Text(listAsync.value?.name ?? 'List'),
        actions: [
          IconButton(
            tooltip: 'AI list builder',
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: _aiGenerateSheet,
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: listAsync,
        onRetry: _refresh,
        data: (list) {
          if (list == null) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'List not found',
            );
          }
          final estimated = list.items.fold<double>(
            0,
            (sum, i) => sum + (i.estimatedPrice ?? 0) * i.quantity,
          );
          return Column(
            children: [
              Expanded(
                child: list.items.isEmpty
                    ? EmptyState(
                        icon: Icons.add_shopping_cart_rounded,
                        title: 'Empty list',
                        message:
                            'Add items by typing, scanning a barcode, voice, '
                            'or let AI build the list.',
                        actionLabel: 'Use AI builder',
                        onAction: _aiGenerateSheet,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: list.items.length,
                        itemBuilder: (_, i) =>
                            _ItemTile(item: list.items[i], onChanged: _refresh),
                      ),
              ),
              if (list.items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (estimated > 0)
                        Expanded(
                          child: Text(
                            'Estimated: ${Formatters.currency(estimated)}'
                            '${list.budget != null ? ' / ${Formatters.currency(list.budget!)}' : ''}',
                            style: context.text.bodyMedium?.copyWith(
                              color:
                                  list.budget != null &&
                                      estimated > list.budget!
                                  ? context.colors.error
                                  : context.colors.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      FilledButton.icon(
                        onPressed: () =>
                            context.push('/lists/${widget.listId}/optimize'),
                        icon: const Icon(Icons.route_rounded),
                        label: const Text('Optimize trip'),
                      ),
                    ],
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          decoration: InputDecoration(
                            hintText: 'Add item…',
                            prefixIcon: const Icon(Icons.add_rounded),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Voice input',
                                  icon: Icon(
                                    _listening
                                        ? Icons.mic_rounded
                                        : Icons.mic_none_rounded,
                                    color: _listening
                                        ? context.colors.primary
                                        : null,
                                  ),
                                  onPressed: _toggleVoice,
                                ),
                                IconButton(
                                  tooltip: 'Scan barcode',
                                  icon: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                  ),
                                  onPressed: _addByBarcode,
                                ),
                              ],
                            ),
                          ),
                          onSubmitted: _addItem,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item, required this.onChanged});

  final ShoppingItem item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(shoppingListRepositoryProvider);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: context.colors.errorContainer,
        child: Icon(
          Icons.delete_rounded,
          color: context.colors.onErrorContainer,
        ),
      ),
      onDismissed: (_) async {
        await repo.removeItem(item.listId, item.id);
        onChanged();
        Haptics.light();
        if (context.mounted) {
          context.showUndoSnack(
            'Removed ${item.name}',
            onUndo: () async {
              await repo.addItem(item.listId, item);
              onChanged();
            },
          );
        }
      },
      child: CheckboxListTile(
        value: item.checked,
        onChanged: (checked) async {
          // Ticking items off is the single most repeated action in the
          // app; the tick should feel physical.
          Haptics.selection();
          await repo.updateItem(item.copyWith(checked: checked ?? false));
          onChanged();
        },
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          item.name,
          style: item.checked
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: context.colors.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: Text(
          '${_trimZero(item.quantity)} ${item.unit}'
          '${item.notes != null ? '  ·  ${item.notes}' : ''}',
        ),
        secondary: item.productId != null
            ? IconButton(
                tooltip: 'Product details',
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => context.push('/products/${item.productId}'),
              )
            : null,
      ),
    );
  }

  static String _trimZero(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
