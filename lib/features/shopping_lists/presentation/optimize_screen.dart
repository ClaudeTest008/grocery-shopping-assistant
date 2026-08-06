import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/ai_services.dart';
import '../../../core/observability/telemetry.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../maps/presentation/map_providers.dart';
import '../../products/data/product_repositories.dart';
import '../../profile/data/preferences_repository.dart';
import '../data/shopping_list_repositories.dart';
import '../domain/basket_optimizer.dart';
import 'shopping_lists_providers.dart';

/// The payoff screen: compares one-store vs multi-store trips with an
/// honest total (items - coupons + driving) and explains the tradeoff.
class OptimizeScreen extends ConsumerWidget {
  const OptimizeScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(optimizationProvider(listId));
    return Scaffold(
      appBar: AppBar(title: const Text('Cheapest way to shop')),
      body: AsyncValueWidget(
        value: result,
        onRetry: () => ref.invalidate(optimizationProvider(listId)),
        data: (optimization) {
          if (optimization.options.isEmpty) {
            return EmptyState(
              icon: Icons.route_rounded,
              title: 'Nothing to optimize',
              message:
                  'We need store prices to compare trips. Add items by '
                  'searching the catalog or scanning a barcode.',
              actionLabel: 'Back to list',
              onAction: () => context.pop(),
            );
          }
          final options = optimization.options;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: options.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              if (i == 0) return _Explainer(result: optimization);
              final option = options[i - 1];
              return _OptionCard(
                option: option,
                label: String.fromCharCode(64 + i), // A, B, C...
                result: optimization,
                index: i - 1,
                listId: listId,
              );
            },
          );
        },
      ),
    );
  }
}

class _Explainer extends StatelessWidget {
  const _Explainer({required this.result});

  final OptimizationResult result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        'Totals include item prices, clipped coupons, and driving cost — '
        'so an extra stop is only recommended when it genuinely pays off.',
        style: context.text.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _OptionCard extends ConsumerWidget {
  const _OptionCard({
    required this.option,
    required this.label,
    required this.result,
    required this.index,
    required this.listId,
  });

  final BasketOption option;
  final String label;
  final OptimizationResult result;
  final int index;
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final storeNames = option.visits.map((v) => v.store.name).join(' + ');
    // The label, stores, total, savings and explanation are one
    // recommendation and should be announced as one.
    return MergeSemantics(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: option.recommended
              ? BorderSide(color: colors.primary, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: option.recommended
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: option.recommended
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      storeNames,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (option.recommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Recommended',
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(option.totalCost),
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'all-in total',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              // A screen called "Cheapest way to shop" has to show the
              // payoff, not just the price.
              if (option.savingsVsBaseline > 0.01) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Saves ${Formatters.currency(option.savingsVsBaseline)} '
                        'vs your nearest store',
                        style: context.text.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _Fact(
                    icon: Icons.shopping_bag_outlined,
                    text: 'Items ${Formatters.currency(option.itemsTotal)}',
                  ),
                  if (option.couponSavings > 0)
                    _Fact(
                      icon: Icons.local_offer_outlined,
                      text:
                          'Coupons −${Formatters.currency(option.couponSavings)}',
                    ),
                  _Fact(
                    icon: Icons.directions_car_outlined,
                    text:
                        '${Formatters.distanceKm(option.travelKm)} · ${Formatters.duration(option.travelTime)} · ${Formatters.currency(option.travelCost)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(option.explanation, style: context.text.bodyMedium),
              const SizedBox(height: 12),
              // Per-store breakdown.
              for (final visit in option.visits) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${visit.store.name} — ${Formatters.currency(visit.subtotal)}',
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final line in visit.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${line.item.name} ×${_qty(line.item.quantity)}',
                                  style: context.text.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                Formatters.currency(line.lineTotal),
                                style: context.text.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (option.unavailableItems.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Not available: ${option.unavailableItems.join(', ')}',
                        style: context.text.bodySmall?.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _suggestSubstitutes(context, ref),
                      child: const Text('Find substitutes'),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        ref.read(tripOverlayProvider.notifier).state =
                            TripOverlay(result: result, selectedIndex: index);
                        context.push('/map');
                      },
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('View on map'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _explainWithAi(context, ref),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text('Ask AI why'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _suggestSubstitutes(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    // These are multi-second network calls; without immediate feedback
    // the button looks broken and gets tapped repeatedly.
    _showThinking(context, 'Finding substitutes…');
    try {
      final subs = await ref
          .read(aiServicesProvider)
          .suggestSubstitutions(
            option.unavailableItems,
            // Asking for someone's dietary needs and then ignoring them
            // is worse than never asking.
            dietaryRestrictions: ref
                .read(preferencesProvider)
                .dietaryRestrictions,
          );
      if (!context.mounted) return;
      Navigator.pop(context); // dismiss the thinking dialog
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cheaper substitutes'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final sub in subs)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${sub['original']} → ${sub['replacement']}'),
                    subtitle: Text(sub['reason'] as String? ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sub['savings'] != null)
                          Text(
                            '−${Formatters.currency((sub['savings'] as num).toDouble())}',
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        TextButton(
                          onPressed: () => _useSubstitute(
                            ctx,
                            ref,
                            original: sub['original']?.toString() ?? '',
                            replacement: sub['replacement']?.toString() ?? '',
                          ),
                          child: const Text('Use'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e, stack) {
      // Raw exception text leaks internals; log it, tell the user less.
      Telemetry.recordError(e, stack);
      if (context.mounted) Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not fetch substitutes — try again.'),
        ),
      );
    }
  }

  /// Swaps the unavailable list item for the suggested substitute — the
  /// rename re-links to a catalog product so the optimizer can actually
  /// price the replacement on the next run.
  Future<void> _useSubstitute(
    BuildContext dialogContext,
    WidgetRef ref, {
    required String original,
    required String replacement,
  }) async {
    final messenger = ScaffoldMessenger.of(dialogContext);
    Navigator.pop(dialogContext);
    if (original.isEmpty || replacement.isEmpty) return;
    try {
      final repo = ref.read(shoppingListRepositoryProvider);
      final list = await repo.byId(listId);
      final item = list?.items.where((i) => i.name == original).firstOrNull;
      if (item == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('$original is no longer on the list')),
        );
        return;
      }
      final matches = await ref
          .read(productRepositoryProvider)
          .search(query: replacement);
      await repo.updateItem(
        item.copyWith(
          name: matches.firstOrNull?.name ?? replacement,
          productId: matches.firstOrNull?.id,
        ),
      );
      ref
        ..invalidate(shoppingListProvider(listId))
        ..invalidate(shoppingListsProvider)
        ..invalidate(optimizationProvider(listId));
      messenger.showSnackBar(
        SnackBar(content: Text('Replaced $original with $replacement')),
      );
    } catch (e, stack) {
      Telemetry.recordError(e, stack);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not apply the substitute — try again.'),
        ),
      );
    }
  }

  /// Blocking "working on it" dialog. Callers pop it before showing the
  /// result, and in their catch block.
  void _showThinking(BuildContext context, String message) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _explainWithAi(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    _showThinking(context, 'Thinking it through…');
    try {
      final explanation = await ref
          .read(aiServicesProvider)
          .explainTrip(
            storeNames: [for (final v in option.visits) v.store.name],
            itemsTotal: option.itemsTotal,
            couponSavings: option.couponSavings,
            travelCost: option.travelCost,
            travelMinutes: option.travelTime.inMinutes,
            totalCost: option.totalCost,
            recommended: option.recommended,
          );
      if (!context.mounted) return;
      Navigator.pop(context);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Why option $label?'),
          content: Text(explanation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e, stack) {
      Telemetry.recordError(e, stack);
      if (context.mounted) Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not get an explanation — try again.'),
        ),
      );
    }
  }

  static String _qty(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: context.colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
