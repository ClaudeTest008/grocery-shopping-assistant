import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/observability/telemetry.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/open_food_facts_client.dart';
import '../data/product_repositories.dart';
import '../domain/product.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

final _categoriesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(productRepositoryProvider).categories(),
);

final _productResultsProvider = FutureProvider<List<Product>>((ref) {
  final query = ref.watch(_searchQueryProvider);
  final category = ref.watch(_selectedCategoryProvider);
  return ref
      .watch(productRepositoryProvider)
      .search(query: query, category: category);
});

IconData _categoryIcon(String category) => switch (category) {
  'dairy' => Icons.icecream_outlined,
  'produce' => Icons.eco_outlined,
  'meat' => Icons.set_meal_outlined,
  'bakery' => Icons.bakery_dining_outlined,
  'pantry' => Icons.kitchen_outlined,
  'beverages' => Icons.local_cafe_outlined,
  'frozen' => Icons.ac_unit_outlined,
  _ => Icons.shopping_basket_outlined,
};

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(_searchQueryProvider.notifier).state = value.trim();
    });
  }

  Future<void> _scanBarcode() async {
    final barcode = await context.push<String>('/scan');
    if (barcode == null || !mounted) return;
    final product = await ref
        .read(productRepositoryProvider)
        .byBarcode(barcode);
    if (!mounted) return;
    if (product != null) {
      await context.push('/products/${product.id}');
      return;
    }
    // Not in the price catalog — identify it via Open Food Facts so the
    // scan still answers "what is this?" instead of dead-ending.
    final external = await ref
        .read(openFoodFactsClientProvider)
        .byBarcode(barcode);
    Telemetry.logEvent('barcode_external_lookup', {'found': external != null});
    if (!mounted) return;
    if (external == null) {
      context.showSnack('Barcode not in the catalog — try searching by name');
      return;
    }
    final query = external.name;
    context.showSnack(
      '${external.label} — identified via Open Food Facts, '
      'not in the price catalog yet',
    );
    // Prefill the search with the identified name: the closest catalog
    // matches are usually the same product from local chains.
    _searchController.text = query;
    _onSearchChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(_productResultsProvider);
    final categories = ref.watch(_categoriesProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan barcode',
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search products',
              leading: const Icon(Icons.search_rounded),
              onChanged: _onSearchChanged,
            ),
          ),
          categories.maybeWhen(
            data: (cats) => SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cats.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = cats[i];
                  final selected = cat == selectedCategory;
                  return FilterChip(
                    // Display only — providers keep the raw key.
                    label: Text(Formatters.titleCase(cat)),
                    selected: selected,
                    onSelected: (on) =>
                        ref.read(_selectedCategoryProvider.notifier).state = on
                        ? cat
                        : null,
                  );
                },
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AsyncValueWidget<List<Product>>(
              value: results,
              onRetry: () => ref.invalidate(_productResultsProvider),
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No products found',
                    message: 'Try a different search or category.',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  // Column count follows the width, so a desktop window
                  // or tablet fills the space instead of showing two
                  // stretched phone-sized cards.
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) =>
                      _ProductCard(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/products/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    _categoryIcon(product.category),
                    size: 40,
                    color: context.colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (product.brand != null)
                Text(
                  product.brand!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              Text(
                '${product.unitSize % 1 == 0 ? product.unitSize.toInt() : product.unitSize} ${product.unit}',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
