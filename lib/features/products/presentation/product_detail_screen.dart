import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/price_tag.dart';
import '../../../shared/widgets/section_header.dart';
import '../../stores/data/store_repositories.dart';
import '../../stores/domain/store.dart';
import '../data/product_repositories.dart';
import '../domain/price.dart';
import '../domain/product.dart';

final _productProvider = FutureProvider.family<Product?, String>(
  (ref, id) => ref.watch(productRepositoryProvider).byId(id),
);
final _pricesProvider = FutureProvider.family<List<Price>, String>(
  (ref, id) => ref.watch(productRepositoryProvider).pricesFor(id),
);
final _priceHistoryProvider = FutureProvider.family<List<PricePoint>, String>(
  (ref, id) => ref.watch(productRepositoryProvider).priceHistory(id),
);
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
              const SectionHeader(title: 'Price history'),
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
              Chip(label: Text(product.category)),
              for (final tag in product.tags)
                Chip(
                  label: Text(tag),
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
        final sorted = [...prices]..sort((a, b) => a.price.compareTo(b.price));
        return Column(
          children: [
            for (var i = 0; i < sorted.length; i++)
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(storeNames[sorted[i].storeId] ?? sorted[i].storeId),
                subtitle: sorted[i].unitPrice != null
                    ? Text(
                        Formatters.unitPrice(
                          sorted[i].unitPrice!,
                          product.unit,
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (i == 0)
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
                    PriceTag(
                      price: sorted[i].price,
                      originalPrice: sorted[i].regularPrice,
                      currency: sorted[i].currency,
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
