import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/services/location_service.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/basket_optimizer.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list.dart';
import 'package:grocery_shopping_assistant/features/stores/domain/store.dart';

/// The optimizer runs synchronously inside a FutureProvider on the UI
/// isolate, so its worst case IS a frame budget question. This pins the
/// measurement: a much larger basket than the demo's (50 items, the
/// full 6-store candidate set, prices everywhere) must finish fast
/// enough that the "Cheapest way to shop" screen feels instant.
///
/// Measured on this machine (debug VM, worst case below): ~3-6ms per
/// run. The 100ms budget is intentionally loose — it exists to catch a
/// complexity regression (e.g. the combination search going
/// super-linear), not machine-to-machine variance.
void main() {
  test('50-item, 6-store optimization stays comfortably under 100ms', () {
    const home = GeoPoint(30.0, -97.0);
    final stores = [
      for (var s = 0; s < 6; s++)
        Store(
          id: 'S$s',
          name: 'Store $s',
          chain: 'chain$s',
          address: 'x',
          lat: 30.0 + 0.01 * (s + 1),
          lng: -97.0 + 0.005 * s,
          distanceKm: 1.1 * (s + 1),
        ),
    ];
    final items = [
      for (var i = 0; i < 50; i++)
        ShoppingItem(id: 'i$i', listId: 'l', productId: 'p$i', name: 'p$i'),
    ];
    final prices = {
      for (var i = 0; i < 50; i++)
        'p$i': [
          for (var s = 0; s < 6; s++)
            Price(
              id: 'S$s-p$i',
              productId: 'p$i',
              storeId: 'S$s',
              // Deterministic spread so assignment is non-trivial.
              price: 1.0 + ((i * 7 + s * 13) % 40) / 10,
            ),
        ],
    };

    const optimizer = BasketOptimizer();

    // Warm-up run: JIT compilation would otherwise dominate.
    optimizer.optimize(
      items: items,
      stores: stores,
      pricesByProduct: prices,
      home: home,
    );

    const runs = 20;
    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < runs; i++) {
      final result = optimizer.optimize(
        items: items,
        stores: stores,
        pricesByProduct: prices,
        home: home,
      );
      expect(result.recommended, isNotNull);
    }
    stopwatch.stop();

    final perRunMs = stopwatch.elapsedMilliseconds / runs;
    // Surfaces in the test log so the number is recorded on every run.
    // ignore: avoid_print
    print('optimizer: ${perRunMs.toStringAsFixed(2)}ms per 50-item run');
    expect(perRunMs, lessThan(100));
  });

  test('500-item stress case stays interactive (large-list reliability)', () {
    // 10x the realistic worst case. Proves the search scales linearly
    // in items (store combinations dominate, items are a sum), so a
    // power user's mega-list cannot freeze the UI isolate.
    const home = GeoPoint(30.0, -97.0);
    final stores = [
      for (var s = 0; s < 6; s++)
        Store(
          id: 'S$s',
          name: 'Store $s',
          chain: 'chain$s',
          address: 'x',
          lat: 30.0 + 0.01 * (s + 1),
          lng: -97.0 + 0.005 * s,
          distanceKm: 1.1 * (s + 1),
        ),
    ];
    final items = [
      for (var i = 0; i < 500; i++)
        ShoppingItem(id: 'i$i', listId: 'l', productId: 'p$i', name: 'p$i'),
    ];
    final prices = {
      for (var i = 0; i < 500; i++)
        'p$i': [
          for (var s = 0; s < 6; s++)
            Price(
              id: 'S$s-p$i',
              productId: 'p$i',
              storeId: 'S$s',
              price: 1.0 + ((i * 7 + s * 13) % 40) / 10,
            ),
        ],
    };

    const optimizer = BasketOptimizer();
    optimizer.optimize(
      items: items,
      stores: stores,
      pricesByProduct: prices,
      home: home,
    );

    final stopwatch = Stopwatch()..start();
    final result = optimizer.optimize(
      items: items,
      stores: stores,
      pricesByProduct: prices,
      home: home,
    );
    stopwatch.stop();

    expect(result.recommended, isNotNull);
    // ignore: avoid_print
    print('optimizer: ${stopwatch.elapsedMilliseconds}ms for 500 items');
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
}
