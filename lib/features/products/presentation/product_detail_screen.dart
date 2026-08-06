import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/observability/telemetry.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/price_tag.dart';
import '../../../shared/widgets/section_header.dart';
import '../../stores/data/store_repositories.dart';
import '../../stores/domain/store.dart';
import '../data/price_observation_repository.dart';
import '../data/product_repositories.dart';
import '../domain/price.dart';
import '../domain/price_observation.dart';
import '../domain/price_verdict.dart';
import '../domain/product.dart';

final _productProvider = FutureProvider.family<Product?, String>(
  (ref, id) => ref.watch(productRepositoryProvider).byId(id),
);
final _pricesProvider = FutureProvider.family<List<Price>, String>(
  (ref, id) => ref.watch(productRepositoryProvider).pricesFor(id),
);

/// Catalog history merged with the user's own observations (receipt
/// lines, reported prices) so real data shows up the moment it exists.
/// Observation failures never blank the chart — catalog history still
/// renders.
final _priceHistoryProvider = FutureProvider.family<List<PricePoint>, String>((
  ref,
  id,
) async {
  final catalog = await ref.watch(productRepositoryProvider).priceHistory(id);
  var observed = const <PricePoint>[];
  try {
    observed = await ref
        .watch(priceObservationRepositoryProvider)
        .observationsFor(id);
  } catch (_) {}
  return [...catalog, ...observed]
    ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
});
final _alternativesProvider = FutureProvider.family<List<Product>, String>(
  (ref, id) => ref.watch(productRepositoryProvider).alternatives(id),
);

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(_productProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text(productAsync.value?.name ?? 'Product')),
      body: AsyncValueWidget<Product?>(
        value: productAsync,
        onRetry: () => ref.invalidate(_productProvider(productId)),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Header(product: product),
              const SectionHeader(title: 'Prices near you'),
              _PricesSection(product: product),
              SectionHeader(
                title: 'Price history',
                actionLabel: 'Report a price',
                onAction: () => _reportPrice(context, ref, product),
              ),
              _PriceHistorySection(productId: productId),
              if (product.nutrition != null &&
                  product.nutrition!.isNotEmpty) ...[
                const SectionHeader(title: 'Nutrition'),
                _NutritionSection(nutrition: product.nutrition!),
              ],
              const SectionHeader(title: 'Alternatives'),
              _AlternativesSection(productId: productId),
            ],
          );
        },
      ),
    );
  }

  /// Community price submission: the shopper is standing in front of the
  /// shelf and knows the real price better than any feed. Their report
  /// lands in their own history immediately; on connected builds it also
  /// queues for review into the shared catalog.
  Future<void> _reportPrice(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final observations = ref.read(priceObservationRepositoryProvider);
    final stores = ref.read(nearbyStoresProvider).value ?? const <Store>[];
    // The dialog + network write outlive this screen easily; the
    // container invalidates safely where a disposed WidgetRef throws.
    final container = ProviderScope.containerOf(context, listen: false);
    final priceCtrl = TextEditingController();
    String? storeId;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Report a price for ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price you saw',
                prefixText: r'$ ',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: storeId,
              decoration: const InputDecoration(labelText: 'Store'),
              items: [
                const DropdownMenuItem(child: Text('Not sure')),
                for (final s in stores)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => storeId = v,
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    final price = double.tryParse(priceCtrl.text.trim().replaceAll(',', '.'));
    priceCtrl.dispose();
    if (submitted != true) return;
    if (price == null || price <= 0 || price >= 10000) {
      if (context.mounted) {
        context.showSnack('Enter a price like 3.49', error: true);
      }
      return;
    }
    try {
      await observations.record(
        PriceObservation(
          id: const Uuid().v4(),
          productId: product.id,
          storeId: storeId,
          price: price,
          source: 'community',
          observedAt: DateTime.now(),
        ),
      );
      Telemetry.logEvent('price_reported', {'has_store': storeId != null});
      container.invalidate(_priceHistoryProvider(product.id));
      if (context.mounted) {
        context.showSnack('Thanks — added to your price history');
      }
    } catch (e) {
      Telemetry.recordError(e, StackTrace.current);
      if (context.mounted) {
        context.showSnack('Could not save the price — try again', error: true);
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (product.brand != null) ...[
            const SizedBox(height: 4),
            Text(
              product.brand!,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(Formatters.titleCase(product.category))),
              for (final tag in product.tags)
                Chip(
                  label: Text(Formatters.titleCase(tag)),
                  backgroundColor: context.colors.secondaryContainer,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PricesSection extends ConsumerWidget {
  const _PricesSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricesAsync = ref.watch(_pricesProvider(product.id));
    final storesAsync = ref.watch(nearbyStoresProvider);
    final storeNames = <String, String>{
      for (final s in storesAsync.value ?? const <Store>[]) s.id: s.name,
    };

    return AsyncValueWidget<List<Price>>(
      value: pricesAsync,
      onRetry: () => ref.invalidate(_pricesProvider(product.id)),
      data: (prices) {
        if (prices.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No prices available.'),
          );
        }
        // In-stock rows first, each group cheapest-first. "Cheapest"
        // must mean cheapest you can actually buy — the optimizer already
        // refuses to route to an out-of-stock price, so badging one here
        // would contradict the app's own recommendation.
        final sorted = [...prices]
          ..sort((a, b) {
            if (a.inStock != b.inStock) return a.inStock ? -1 : 1;
            return a.price.compareTo(b.price);
          });
        final cheapestInStock = sorted.where((p) => p.inStock).firstOrNull;

        return Column(
          children: [
            for (final price in sorted)
              ListTile(
                leading: Icon(
                  price.inStock
                      ? Icons.storefront_outlined
                      : Icons.remove_shopping_cart_outlined,
                  color: price.inStock ? null : context.colors.outline,
                ),
                title: Text(
                  storeNames[price.storeId] ?? price.storeId,
                  style: price.inStock
                      ? null
                      : TextStyle(color: context.colors.onSurfaceVariant),
                ),
                subtitle: Text(
                  [
                    if (price.unitPrice != null)
                      Formatters.unitPrice(price.unitPrice!, product.unit),
                    if (!price.inStock) 'Out of stock',
                    if (price.updatedAt != null)
                      'updated ${Formatters.relativeDays(price.updatedAt!).toLowerCase()}',
                  ].join(' · '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (identical(price, cheapestInStock))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: const Text('Cheapest'),
                          backgroundColor: context.colors.tertiaryContainer,
                          labelStyle: TextStyle(
                            color: context.colors.onTertiaryContainer,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    Opacity(
                      opacity: price.inStock ? 1 : 0.5,
                      child: PriceTag(
                        price: price.price,
                        originalPrice: price.regularPrice,
                        currency: price.currency,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PriceHistorySection extends ConsumerWidget {
  const _PriceHistorySection({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(_priceHistoryProvider(productId));
    return AsyncValueWidget<List<PricePoint>>(
      value: historyAsync,
      onRetry: () => ref.invalidate(_priceHistoryProvider(productId)),
      data: (points) {
        if (points.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No price history yet.'),
          );
        }
        final sorted = [...points]
          ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
        final prices = sorted.map((p) => p.price).toList();
        final lowest = prices.reduce((a, b) => a < b ? a : b);
        final highest = prices.reduce((a, b) => a > b ? a : b);
        final average = prices.reduce((a, b) => a + b) / prices.length;

        // Compare today's best buyable price against its own history so
        // the chart draws a conclusion instead of leaving the reader to.
        final best = (ref.watch(_pricesProvider(productId)).value ?? const [])
            .where((p) => p.inStock)
            .fold<double?>(
              null,
              (min, p) => min == null || p.price < min ? p.price : min,
            );
        final verdict = best == null ? null : sorted.verdictFor(best);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (verdict != null) ...[
                _VerdictBanner(verdict: verdict),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < sorted.length; i++)
                            FlSpot(i.toDouble(), sorted[i].price),
                        ],
                        isCurved: true,
                        color: context.colors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: context.colors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'Lowest', value: lowest),
                  _Stat(label: 'Average', value: average),
                  _Stat(label: 'Highest', value: highest),
                ],
              ),
              // Provenance: tell the user when their own real data is in
              // the chart — it is the difference between a demo and a
              // product that learns from their shopping.
              if (sorted.any(
                (p) => p.source == 'receipt' || p.source == 'community',
              ))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Includes ${sorted.where((p) => p.source == 'receipt' || p.source == 'community').length} '
                    'prices from your receipts and reports.',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Formatters.currency(value),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Turns the history chart into an answer. Colour and icon carry the
/// same message as the words, so the meaning survives both a glance and
/// a screen reader.
class _VerdictBanner extends StatelessWidget {
  const _VerdictBanner({required this.verdict});

  final PriceVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground, icon) = switch (verdict.standing) {
      PriceStanding.lowest => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        Icons.trending_down_rounded,
      ),
      PriceStanding.below => (
        colors.primaryContainer.withValues(alpha: 0.6),
        colors.onPrimaryContainer,
        Icons.trending_down_rounded,
      ),
      PriceStanding.typical => (
        colors.surfaceContainerHigh,
        colors.onSurface,
        Icons.trending_flat_rounded,
      ),
      PriceStanding.above => (
        colors.errorContainer.withValues(alpha: 0.5),
        colors.onErrorContainer,
        Icons.trending_up_rounded,
      ),
      PriceStanding.highest => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.trending_up_rounded,
      ),
    };

    return Semantics(
      label: '${verdict.headline}. ${verdict.explanation}',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verdict.headline,
                    style: context.text.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    verdict.explanation,
                    style: context.text.bodySmall?.copyWith(color: foreground),
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

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.nutrition});

  final Map<String, dynamic> nutrition;

  String _label(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
        children: [
          for (final entry in nutrition.entries)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(_label(entry.key)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('${entry.value}'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AlternativesSection extends ConsumerWidget {
  const _AlternativesSection({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final altAsync = ref.watch(_alternativesProvider(productId));
    return AsyncValueWidget<List<Product>>(
      value: altAsync,
      onRetry: () => ref.invalidate(_alternativesProvider(productId)),
      data: (alternatives) {
        if (alternatives.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No alternatives found.'),
          );
        }
        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: alternatives.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final alt = alternatives[i];
              return SizedBox(
                width: 140,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/products/${alt.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            color: context.colors.primary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alt.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
