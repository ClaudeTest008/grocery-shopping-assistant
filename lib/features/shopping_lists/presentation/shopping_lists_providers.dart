import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/location_service.dart';
import '../../coupons/data/coupon_repositories.dart';
import '../../products/data/product_repositories.dart';
import '../../profile/data/preferences_repository.dart';
import '../../stores/data/store_repositories.dart';
import '../data/shopping_list_repositories.dart';
import '../domain/basket_optimizer.dart';
import '../domain/shopping_list.dart';

final shoppingListsProvider = FutureProvider<List<ShoppingList>>(
  (ref) => ref.watch(shoppingListRepositoryProvider).lists(),
);

final shoppingListProvider = FutureProvider.family<ShoppingList?, String>(
  (ref, id) => ref.watch(shoppingListRepositoryProvider).byId(id),
);

/// Runs the basket optimizer for a list against nearby stores, live
/// prices, clipped coupons, and the user's trip-cost preferences.
final optimizationProvider = FutureProvider.family<OptimizationResult, String>((
  ref,
  listId,
) async {
  final list = await ref.watch(shoppingListProvider(listId).future);
  if (list == null) {
    return const OptimizationResult(options: [], recommended: null);
  }

  final stores = await ref.watch(nearbyStoresProvider.future);
  final home = await ref.watch(currentLocationProvider.future);
  final prefs = ref.watch(preferencesProvider);

  final pending = list.items.where((i) => !i.checked).toList();
  final productIds = pending
      .map((i) => i.productId)
      .whereType<String>()
      .toSet()
      .toList();
  final prices = await ref
      .watch(productRepositoryProvider)
      .pricesForProducts(productIds);
  final coupons = await ref.watch(couponRepositoryProvider).available();

  return BasketOptimizer(
    fuelCostPerKm: prefs.fuelCostPerKm,
    multiStoreThreshold: prefs.multiStoreThreshold,
  ).optimize(
    items: pending,
    stores: stores,
    pricesByProduct: prices,
    home: home,
    clippedCoupons: coupons.where((c) => c.clipped).toList(),
  );
});
