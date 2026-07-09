import '../../../core/services/location_service.dart';
import '../../coupons/domain/coupon.dart';
import '../../products/domain/price.dart';
import '../../stores/domain/store.dart';
import 'shopping_list.dart';

/// The app's core engine: given a shopping list and nearby stores with
/// prices, finds the cheapest way to complete the whole trip — including
/// whether splitting across 2-3 stores is actually worth the extra
/// driving.
///
/// Pure Dart, no I/O: fully unit-testable.
class BasketOptimizer {
  const BasketOptimizer({
    this.fuelCostPerKm = 0.12,
    this.multiStoreThreshold = 2.0,
    this.maxStoresConsidered = 6,
    this.urbanSpeedKmh = 35,
  });

  /// Marginal driving cost per km (fuel + wear).
  final double fuelCostPerKm;

  /// Minimum net savings before recommending an extra store stop.
  final double multiStoreThreshold;

  /// Only the N nearest stores enter combination search.
  final int maxStoresConsidered;

  final double urbanSpeedKmh;

  OptimizationResult optimize({
    required List<ShoppingItem> items,
    required List<Store> stores,
    required Map<String, List<Price>> pricesByProduct,
    required GeoPoint home,
    List<Coupon> clippedCoupons = const [],
  }) {
    final candidates = stores.take(maxStoresConsidered).toList();
    if (items.isEmpty || candidates.isEmpty) {
      return const OptimizationResult(options: [], recommended: null);
    }

    final options = <BasketOption>[];
    // All store combinations of size 1..3.
    for (var size = 1; size <= 3 && size <= candidates.length; size++) {
      for (final combo in _combinations(candidates, size)) {
        final option = _evaluate(combo, items, pricesByProduct, home,
            clippedCoupons);
        if (option != null) options.add(option);
      }
    }
    if (options.isEmpty) {
      return const OptimizationResult(options: [], recommended: null);
    }

    // Maximize coverage first, then minimize total cost.
    options.sort((a, b) {
      final cov = a.unavailableItems.length - b.unavailableItems.length;
      if (cov != 0) return cov;
      return a.totalCost.compareTo(b.totalCost);
    });

    final bestSingle = options.where((o) => o.visits.length == 1).firstOrNull;
    final best = options.first;

    // Multi-store must beat the best single store by the threshold,
    // otherwise the errand isn't worth it.
    BasketOption recommended = best;
    if (best.visits.length > 1 && bestSingle != null) {
      final sameCoverage = bestSingle.unavailableItems.length ==
          best.unavailableItems.length;
      final savings = bestSingle.totalCost - best.totalCost;
      if (sameCoverage && savings < multiStoreThreshold) {
        recommended = bestSingle;
      }
    }

    final annotated = [
      for (final o in options.take(6))
        o.copyWith(
          recommended: identical(o, recommended),
          explanation: _explain(o, bestSingle, recommended),
        ),
    ];

    return OptimizationResult(
      options: annotated,
      recommended:
          annotated.firstWhere((o) => o.recommended, orElse: () => annotated.first),
    );
  }

  BasketOption? _evaluate(
    List<Store> combo,
    List<ShoppingItem> items,
    Map<String, List<Price>> pricesByProduct,
    GeoPoint home,
    List<Coupon> coupons,
  ) {
    final comboIds = {for (final s in combo) s.id};
    final assignments = <String, List<ItemAssignment>>{}; // storeId -> items
    final unavailable = <ShoppingItem>[];

    for (final item in items) {
      final prices = item.productId == null
          ? const <Price>[]
          : (pricesByProduct[item.productId!] ?? const <Price>[])
              .where((p) => comboIds.contains(p.storeId))
              .toList();
      if (prices.isEmpty) {
        unavailable.add(item);
        continue;
      }
      prices.sort((a, b) => a.price.compareTo(b.price));
      final cheapest = prices.first;
      assignments.putIfAbsent(cheapest.storeId, () => []).add(ItemAssignment(
            item: item,
            price: cheapest,
            lineTotal: cheapest.price * item.quantity,
          ));
    }

    // A combo where some store gets nothing is strictly worse than the
    // smaller combo — skip to avoid recommending pointless stops.
    if (assignments.length < combo.length) return null;

    final visits = [
      for (final store in combo)
        StoreVisit(
          store: store,
          items: assignments[store.id]!,
          subtotal: assignments[store.id]!
              .fold(0.0, (sum, a) => sum + a.lineTotal),
        ),
    ];
    final itemsTotal = visits.fold(0.0, (sum, v) => sum + v.subtotal);

    final couponSavings =
        _couponSavings(coupons, visits, comboIds, itemsTotal);

    final travelKm = _bestTourKm(home, combo);
    final travelCost = travelKm * fuelCostPerKm;
    final travelTime =
        Duration(minutes: (travelKm / urbanSpeedKmh * 60).round() +
            8 * combo.length); // ~8 min in-store overhead per extra stop

    return BasketOption(
      visits: visits,
      itemsTotal: _r(itemsTotal),
      couponSavings: _r(couponSavings),
      travelKm: _r(travelKm),
      travelCost: _r(travelCost),
      travelTime: travelTime,
      totalCost: _r(itemsTotal - couponSavings + travelCost),
      unavailableItems: [for (final i in unavailable) i.name],
    );
  }

  double _couponSavings(List<Coupon> coupons, List<StoreVisit> visits,
      Set<String> comboIds, double itemsTotal) {
    var savings = 0.0;
    for (final coupon in coupons.where((c) => c.clipped && !c.isExpired)) {
      // Store-bound coupons need that store in the trip.
      if (coupon.storeId != null && !comboIds.contains(coupon.storeId)) {
        continue;
      }
      if (coupon.productId != null) {
        // Product coupon: applies if we buy that product at an eligible
        // store.
        for (final visit in visits) {
          if (coupon.storeId != null && visit.store.id != coupon.storeId) {
            continue;
          }
          final line = visit.items
              .where((a) => a.price.productId == coupon.productId)
              .firstOrNull;
          if (line != null) {
            savings += coupon.valueOn(line.price.price);
            break;
          }
        }
      } else {
        // Basket coupon with optional minimum spend.
        final qualifying = coupon.storeId == null
            ? itemsTotal
            : visits
                .firstWhere((v) => v.store.id == coupon.storeId)
                .subtotal;
        if (coupon.minSpend == null || qualifying >= coupon.minSpend!) {
          savings += coupon.valueOn(qualifying);
        }
      }
    }
    return savings;
  }

  /// Shortest home -> stores -> home tour over all permutations
  /// (max 3 stores => max 6 permutations).
  double _bestTourKm(GeoPoint home, List<Store> stores) {
    double tour(List<Store> order) {
      var km = 0.0;
      var at = home;
      for (final s in order) {
        final p = GeoPoint(s.lat, s.lng);
        km += at.distanceKmTo(p);
        at = p;
      }
      return km + at.distanceKmTo(home);
    }

    var best = double.infinity;
    for (final perm in _permutations(stores)) {
      final km = tour(perm);
      if (km < best) best = km;
    }
    return best;
  }

  String _explain(
      BasketOption o, BasketOption? bestSingle, BasketOption recommended) {
    final storeNames = o.visits.map((v) => v.store.name).join(' + ');
    final buffer = StringBuffer();
    if (o.visits.length == 1) {
      buffer.write('Everything in one stop at $storeNames.');
    } else {
      buffer.write('Split across $storeNames — each item bought where it '
          'is cheapest.');
    }
    if (o.couponSavings > 0) {
      buffer.write(
          ' Includes \$${o.couponSavings.toStringAsFixed(2)} coupon savings.');
    }
    if (bestSingle != null && !identical(o, bestSingle)) {
      final savings = bestSingle.totalCost - o.totalCost;
      final extraMin =
          o.travelTime.inMinutes - bestSingle.travelTime.inMinutes;
      if (savings > 0) {
        buffer.write(' Saves \$${savings.toStringAsFixed(2)} vs the best '
            'single store for about $extraMin extra minutes'
            '${identical(o, recommended) ? ' — worth it.' : ', which is not worth the trip.'}');
      } else {
        buffer.write(' Costs \$${(-savings).toStringAsFixed(2)} more than '
            'the best single store once driving is priced in.');
      }
    }
    if (o.unavailableItems.isNotEmpty) {
      buffer.write(
          ' Unavailable here: ${o.unavailableItems.join(', ')}.');
    }
    return buffer.toString();
  }

  static double _r(double v) => (v * 100).roundToDouble() / 100;

  static Iterable<List<T>> _combinations<T>(List<T> pool, int size) sync* {
    if (size == 0) {
      yield <T>[];
      return;
    }
    for (var i = 0; i <= pool.length - size; i++) {
      for (final rest in _combinations(pool.sublist(i + 1), size - 1)) {
        yield [pool[i], ...rest];
      }
    }
  }

  static Iterable<List<T>> _permutations<T>(List<T> items) sync* {
    if (items.length <= 1) {
      yield List.of(items);
      return;
    }
    for (var i = 0; i < items.length; i++) {
      final rest = [...items]..removeAt(i);
      for (final perm in _permutations(rest)) {
        yield [items[i], ...perm];
      }
    }
  }
}

class ItemAssignment {
  const ItemAssignment({
    required this.item,
    required this.price,
    required this.lineTotal,
  });

  final ShoppingItem item;
  final Price price;
  final double lineTotal;
}

class StoreVisit {
  const StoreVisit({
    required this.store,
    required this.items,
    required this.subtotal,
  });

  final Store store;
  final List<ItemAssignment> items;
  final double subtotal;
}

class BasketOption {
  const BasketOption({
    required this.visits,
    required this.itemsTotal,
    required this.couponSavings,
    required this.travelKm,
    required this.travelCost,
    required this.travelTime,
    required this.totalCost,
    this.unavailableItems = const [],
    this.recommended = false,
    this.explanation = '',
  });

  final List<StoreVisit> visits;
  final double itemsTotal;
  final double couponSavings;
  final double travelKm;
  final double travelCost;
  final Duration travelTime;

  /// itemsTotal - couponSavings + travelCost. The honest number.
  final double totalCost;
  final List<String> unavailableItems;
  final bool recommended;
  final String explanation;

  BasketOption copyWith({bool? recommended, String? explanation}) =>
      BasketOption(
        visits: visits,
        itemsTotal: itemsTotal,
        couponSavings: couponSavings,
        travelKm: travelKm,
        travelCost: travelCost,
        travelTime: travelTime,
        totalCost: totalCost,
        unavailableItems: unavailableItems,
        recommended: recommended ?? this.recommended,
        explanation: explanation ?? this.explanation,
      );
}

class OptimizationResult {
  const OptimizationResult({required this.options, required this.recommended});

  /// Best options (max 6), sorted by coverage then total cost.
  final List<BasketOption> options;
  final BasketOption? recommended;
}
