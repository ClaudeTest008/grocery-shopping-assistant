import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/services/location_service.dart';
import 'package:grocery_shopping_assistant/features/coupons/domain/coupon.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/basket_optimizer.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list.dart';
import 'package:grocery_shopping_assistant/features/stores/domain/store.dart';

void main() {
  const home = GeoPoint(30.0, -97.0);

  Store store(String id, double latOffset) => Store(
    id: id,
    name: id,
    chain: id,
    address: 'x',
    lat: 30.0 + latOffset,
    lng: -97.0,
    distanceKm: latOffset * 111,
  );

  ShoppingItem item(String productId, {double qty = 1}) => ShoppingItem(
    id: 'i-$productId',
    listId: 'l1',
    productId: productId,
    name: productId,
    quantity: qty,
  );

  Price price(String productId, String storeId, double value) => Price(
    id: '$storeId-$productId',
    productId: productId,
    storeId: storeId,
    price: value,
  );

  group('BasketOptimizer', () {
    // Store A is close and slightly pricier; store B further but cheaper
    // on half the items.
    final storeA = store('A', 0.01); // ~1.1 km
    final storeB = store('B', 0.02); // ~2.2 km

    test('single store wins when multi-store savings are below threshold', () {
      final result = const BasketOptimizer(multiStoreThreshold: 2.0).optimize(
        items: [item('milk'), item('eggs')],
        stores: [storeA, storeB],
        pricesByProduct: {
          'milk': [price('milk', 'A', 3.00), price('milk', 'B', 2.90)],
          'eggs': [price('eggs', 'A', 2.50), price('eggs', 'B', 2.45)],
        },
        home: home,
      );

      expect(result.recommended, isNotNull);
      expect(result.recommended!.visits, hasLength(1));
      // 15c savings never justifies a second stop.
      expect(result.recommended!.visits.single.store.id, anyOf('A', 'B'));
    });

    test('two stores recommended when the split genuinely pays off', () {
      final result =
          const BasketOptimizer(
            multiStoreThreshold: 2.0,
            fuelCostPerKm: 0.1,
          ).optimize(
            items: [item('milk'), item('steak')],
            stores: [storeA, storeB],
            pricesByProduct: {
              // Milk much cheaper at A, steak much cheaper at B.
              'milk': [price('milk', 'A', 2.00), price('milk', 'B', 6.00)],
              'steak': [price('steak', 'A', 15.00), price('steak', 'B', 8.00)],
            },
            home: home,
          );

      expect(result.recommended!.visits, hasLength(2));
      expect(result.recommended!.explanation, contains('worth it'));
    });

    test('travel cost is part of the total', () {
      final result = const BasketOptimizer(fuelCostPerKm: 0.5).optimize(
        items: [item('milk')],
        stores: [storeB],
        pricesByProduct: {
          'milk': [price('milk', 'B', 3.00)],
        },
        home: home,
      );

      final option = result.recommended!;
      expect(option.travelCost, greaterThan(0));
      expect(
        option.totalCost,
        closeTo(option.itemsTotal + option.travelCost, 0.011),
      );
    });

    test('quantities multiply line totals', () {
      final result = const BasketOptimizer().optimize(
        items: [item('beans', qty: 3)],
        stores: [storeA],
        pricesByProduct: {
          'beans': [price('beans', 'A', 0.89)],
        },
        home: home,
      );

      expect(result.recommended!.itemsTotal, closeTo(2.67, 0.001));
    });

    test('clipped product coupon reduces the total', () {
      final coupon = Coupon(
        id: 'c1',
        productId: 'milk',
        storeId: 'A',
        title: r'$1 off milk',
        discountAmount: 1.0,
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        clipped: true,
      );
      final result = const BasketOptimizer().optimize(
        items: [item('milk')],
        stores: [storeA],
        pricesByProduct: {
          'milk': [price('milk', 'A', 3.00)],
        },
        home: home,
        clippedCoupons: [coupon],
      );

      expect(result.recommended!.couponSavings, 1.0);
    });

    test('basket coupon respects minimum spend', () {
      final coupon = Coupon(
        id: 'c2',
        title: r'$5 off $40',
        discountAmount: 5.0,
        minSpend: 40,
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        clipped: true,
      );
      final below = const BasketOptimizer().optimize(
        items: [item('milk')],
        stores: [storeA],
        pricesByProduct: {
          'milk': [price('milk', 'A', 3.00)],
        },
        home: home,
        clippedCoupons: [coupon],
      );
      expect(below.recommended!.couponSavings, 0);

      final above = const BasketOptimizer().optimize(
        items: [item('milk', qty: 20)], // $60
        stores: [storeA],
        pricesByProduct: {
          'milk': [price('milk', 'A', 3.00)],
        },
        home: home,
        clippedCoupons: [coupon],
      );
      expect(above.recommended!.couponSavings, 5.0);
    });

    test('items nobody carries are reported, not silently dropped', () {
      final result = const BasketOptimizer().optimize(
        items: [item('milk'), item('unicorn-food')],
        stores: [storeA],
        pricesByProduct: {
          'milk': [price('milk', 'A', 3.00)],
        },
        home: home,
      );

      expect(result.recommended!.unavailableItems, ['unicorn-food']);
    });

    test('coverage beats price: an option finding more items ranks first', () {
      final result = const BasketOptimizer().optimize(
        items: [item('milk'), item('tofu')],
        stores: [storeA, storeB],
        pricesByProduct: {
          'milk': [price('milk', 'A', 1.00), price('milk', 'B', 5.00)],
          'tofu': [price('tofu', 'B', 2.00)], // only B carries tofu
        },
        home: home,
      );

      // Best option must include B to cover tofu.
      final ids = result.recommended!.visits.map((v) => v.store.id).toSet();
      expect(ids, contains('B'));
      expect(result.recommended!.unavailableItems, isEmpty);
    });

    test('empty input yields empty result', () {
      final result = const BasketOptimizer().optimize(
        items: [],
        stores: [storeA],
        pricesByProduct: {},
        home: home,
      );
      expect(result.options, isEmpty);
      expect(result.recommended, isNull);
    });
  });
}
