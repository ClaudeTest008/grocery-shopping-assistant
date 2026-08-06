import 'package:uuid/uuid.dart';

import '../../products/data/price_observation_repository.dart';
import '../../products/domain/price_observation.dart';
import '../../products/domain/product.dart';
import '../../products/domain/product_matcher.dart';
import '../../products/domain/product_repository.dart';
import 'receipt.dart';

/// Turns a saved receipt into real price-history points: every line that
/// confidently matches a catalog product becomes a [PriceObservation].
/// This is the app's primary live-data source — actual shelf prices from
/// actual shopping trips, recorded as a side effect of a feature users
/// already run for their budget.
abstract final class ReceiptPriceRecorder {
  static const _uuid = Uuid();

  /// Records observations for matchable line items; returns how many.
  /// Never throws: a failed lookup skips the line — losing one price
  /// point is cheaper than failing the receipt save around it.
  static Future<int> record(
    Receipt receipt, {
    required ProductRepository products,
    required PriceObservationRepository observations,
  }) async {
    var recorded = 0;
    for (final item in receipt.items) {
      if (item.price <= 0) continue;
      try {
        final match = ProductMatcher.confidentMatch(
          await _candidates(products, item.name),
          item.name,
        );
        if (match == null) continue;
        await observations.record(
          PriceObservation(
            id: _uuid.v4(),
            productId: match.id,
            storeId: receipt.storeId,
            // Per-unit price when the line has a quantity.
            price: item.quantity > 1 ? item.price / item.quantity : item.price,
            source: 'receipt',
            observedAt: receipt.purchasedAt,
          ),
        );
        recorded++;
      } catch (_) {
        // Skip the line; the receipt itself is already saved.
      }
    }
    return recorded;
  }

  /// Receipt lines are noisy ("GV WHOLE MILK 1GAL"), so a search for the
  /// full line usually finds nothing. Search per word instead and let
  /// [ProductMatcher] decide whether exactly one candidate fits.
  static Future<List<Product>> _candidates(
    ProductRepository products,
    String rawName,
  ) async {
    final words = rawName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 4)
        .take(4);
    final seen = <String>{};
    final candidates = <Product>[];
    for (final word in words) {
      for (final product in await products.search(query: word)) {
        if (seen.add(product.id)) candidates.add(product);
      }
    }
    return candidates;
  }
}
