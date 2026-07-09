import '../../features/coupons/domain/coupon.dart';
import '../../features/offers/domain/offer.dart';
import '../../features/products/domain/price.dart';
import '../../features/products/domain/product.dart';
import '../../features/stores/domain/store.dart';

/// Deterministic seed data backing demo mode. Six stores around the demo
/// home location (Austin, TX), a small realistic catalog, per-store
/// prices with genuine spread so the basket optimizer produces
/// interesting results.
abstract final class DemoSeed {
  static const demoUserId = 'demo-user';

  static final stores = <Store>[
    _store('aldi-1', 'Aldi', 'aldi', '2610 E Riverside Dr', 30.2401, -97.7269),
    _store(
      'walmart-1',
      'Walmart Supercenter',
      'walmart',
      '710 E Ben White Blvd',
      30.2201,
      -97.7570,
    ),
    _store('kroger-1', 'Kroger', 'kroger', '1601 W 38th St', 30.3055, -97.7484),
    _store(
      'target-1',
      'Target',
      'target',
      '5300 S MoPac Expy',
      30.2320,
      -97.8100,
    ),
    _store('heb-1', 'H-E-B', 'heb', '2400 S Congress Ave', 30.2410, -97.7515),
    _store(
      'tj-1',
      "Trader Joe's",
      'traderjoes',
      '211 Walter Seaholm Dr',
      30.2680,
      -97.7530,
    ),
  ];

  static Store _store(
    String id,
    String name,
    String chain,
    String addr,
    double lat,
    double lng,
  ) => Store(
    id: id,
    name: name,
    chain: chain,
    address: '$addr, Austin, TX',
    lat: lat,
    lng: lng,
    openingHours: {
      for (var d = 1; d <= 6; d++) '$d': '08:00-21:00',
      '7': '09:00-20:00',
    },
  );

  /// (id, name, brand, category, unit, unitSize, tags)
  static final products = <Product>[
    _p('milk', 'Whole Milk', 'Great Value', 'dairy', 'gal', 1, []),
    _p('eggs', 'Large Eggs, Dozen', null, 'dairy', 'ct', 12, []),
    _p('butter', 'Salted Butter', 'Land O Lakes', 'dairy', 'oz', 16, []),
    _p('cheddar', 'Shredded Cheddar', null, 'dairy', 'oz', 8, []),
    _p('yogurt', 'Greek Yogurt', 'Chobani', 'dairy', 'oz', 32, []),
    _p('bananas', 'Bananas', null, 'produce', 'lb', 1, ['vegan']),
    _p('apples', 'Gala Apples', null, 'produce', 'lb', 1, ['vegan']),
    _p('lettuce', 'Romaine Lettuce', null, 'produce', 'ea', 1, ['vegan']),
    _p('tomatoes', 'Roma Tomatoes', null, 'produce', 'lb', 1, ['vegan']),
    _p('broccoli', 'Broccoli Crowns', null, 'produce', 'lb', 1, ['vegan']),
    _p('chicken', 'Chicken Breast', null, 'meat', 'lb', 1, []),
    _p('gbeef', 'Ground Beef 80/20', null, 'meat', 'lb', 1, []),
    _p('turkey', 'Ground Turkey', null, 'meat', 'lb', 1, []),
    _p('bread', 'Whole Wheat Bread', 'Nature\'s Own', 'bakery', 'loaf', 1, []),
    _p('tortillas', 'Flour Tortillas', 'Mission', 'bakery', 'ct', 10, []),
    _p('rice', 'Long Grain Rice', null, 'pantry', 'lb', 2, ['vegan']),
    _p('pasta', 'Spaghetti', 'Barilla', 'pantry', 'oz', 16, ['vegan']),
    _p('beans', 'Black Beans', 'Goya', 'pantry', 'can', 1, ['vegan']),
    _p('tomsauce', 'Canned Tomatoes', 'Hunt\'s', 'pantry', 'can', 1, ['vegan']),
    _p('pb', 'Peanut Butter', 'Jif', 'pantry', 'oz', 16, ['vegan']),
    _p('cereal', 'Honey Nut Cereal', 'General Mills', 'pantry', 'oz', 18, []),
    _p('coffee', 'Ground Coffee', 'Folgers', 'beverages', 'oz', 24, ['vegan']),
    _p('oj', 'Orange Juice', 'Tropicana', 'beverages', 'oz', 52, ['vegan']),
    _p('frbroccoli', 'Frozen Broccoli', null, 'frozen', 'oz', 12, ['vegan']),
    _p('icecream', 'Vanilla Ice Cream', 'Blue Bell', 'frozen', 'oz', 16, []),
    _p('tofu', 'Firm Tofu', null, 'meat', 'oz', 14, ['vegan']),
  ];

  static Product _p(
    String id,
    String name,
    String? brand,
    String category,
    String unit,
    double size,
    List<String> tags,
  ) => Product(
    id: id,
    name: name,
    brand: brand,
    barcode: '0000${id.hashCode.abs()}',
    category: category,
    unit: unit,
    unitSize: size,
    tags: tags,
    nutrition: const {'calories': 120, 'protein_g': 4, 'fat_g': 3},
  );

  /// Base price per product; per-store multipliers create honest spread.
  static const _basePrices = <String, double>{
    'milk': 3.49,
    'eggs': 2.89,
    'butter': 4.29,
    'cheddar': 2.49,
    'yogurt': 5.49,
    'bananas': 0.58,
    'apples': 1.49,
    'lettuce': 2.29,
    'tomatoes': 1.39,
    'broccoli': 1.99,
    'chicken': 3.29,
    'gbeef': 4.49,
    'turkey': 3.99,
    'bread': 2.49,
    'tortillas': 2.89,
    'rice': 2.19,
    'pasta': 1.39,
    'beans': 0.89,
    'tomsauce': 1.09,
    'pb': 2.79,
    'cereal': 3.99,
    'coffee': 8.99,
    'oj': 3.89,
    'frbroccoli': 1.79,
    'icecream': 4.99,
    'tofu': 1.99,
  };

  static const _storeMultiplier = <String, double>{
    'aldi-1': 0.86,
    'walmart-1': 0.92,
    'kroger-1': 1.02,
    'target-1': 1.06,
    'heb-1': 0.95,
    'tj-1': 1.10,
  };

  /// Items a store does NOT carry — forces the optimizer to handle
  /// partial availability.
  static const _notCarried = <String, Set<String>>{
    'aldi-1': {'coffee', 'icecream', 'tofu'},
    'tj-1': {'cereal', 'oj', 'gbeef'},
    'walmart-1': {'tofu'},
  };

  /// A few promo prices to make offers meaningful.
  static const _promos = <String, Set<String>>{
    'kroger-1': {'chicken', 'cereal'},
    'heb-1': {'gbeef', 'oj'},
    'walmart-1': {'pasta'},
    'target-1': {'coffee'},
  };

  static List<Price> get prices {
    final now = DateTime.now();
    final out = <Price>[];
    for (final store in stores) {
      final mult = _storeMultiplier[store.id]!;
      for (final entry in _basePrices.entries) {
        if (_notCarried[store.id]?.contains(entry.key) ?? false) continue;
        // Deterministic per-pair jitter of +-4%.
        final jitter =
            1 + (((entry.key.hashCode ^ store.id.hashCode) % 9) - 4) / 100;
        var price = _round(entry.value * mult * jitter);
        double? regular;
        if (_promos[store.id]?.contains(entry.key) ?? false) {
          regular = price;
          price = _round(price * 0.78);
        }
        final product = products.firstWhere((p) => p.id == entry.key);
        out.add(
          Price(
            id: '${store.id}-${entry.key}',
            productId: entry.key,
            storeId: store.id,
            price: price,
            regularPrice: regular,
            unitPrice: _round(price / product.unitSize),
            validTo: now.add(const Duration(days: 6)),
            updatedAt: now,
          ),
        );
      }
    }
    return out;
  }

  static double _round(double v) => (v * 100).roundToDouble() / 100;

  /// Synthetic but plausible 90-day price history.
  static List<PricePoint> priceHistory(String productId) {
    final base = _basePrices[productId] ?? 2.99;
    final now = DateTime.now();
    return [
      for (var d = 90; d >= 0; d -= 3)
        PricePoint(
          recordedAt: now.subtract(Duration(days: d)),
          // Slow seasonal drift + periodic sale dip every ~28 days.
          price: _round(
            base *
                (1 +
                    0.06 * _wave(d / 45) -
                    (d % 28 < 4 ? 0.18 : 0) +
                    ((productId.hashCode + d) % 7 - 3) / 200),
          ),
        ),
    ];
  }

  // Cheap sine substitute avoiding dart:math import noise: triangle wave.
  static double _wave(double t) {
    final f = t - t.floorToDouble();
    return f < 0.5 ? 4 * f - 1 : 3 - 4 * f;
  }

  static List<Offer> get offers {
    final now = DateTime.now();
    return [
      Offer(
        id: 'of-1',
        storeId: 'kroger-1',
        productId: 'chicken',
        title: 'Chicken Breast 22% off',
        description: 'Weekly ad — fresh chicken breast value pack.',
        discountPercent: 22,
        validTo: now.add(const Duration(days: 4)),
        type: OfferType.weeklyAd,
      ),
      Offer(
        id: 'of-2',
        storeId: 'heb-1',
        productId: 'gbeef',
        title: 'Ground Beef sale',
        discountPercent: 22,
        validTo: now.add(const Duration(days: 2)),
        type: OfferType.weeklyAd,
      ),
      Offer(
        id: 'of-3',
        storeId: 'walmart-1',
        title: '5% cashback on \$50+ baskets',
        description: 'Walmart+ members earn cashback this week.',
        discountPercent: 5,
        validTo: now.add(const Duration(days: 6)),
        type: OfferType.cashback,
      ),
      Offer(
        id: 'of-4',
        storeId: 'target-1',
        productId: 'coffee',
        title: 'Coffee BOGO 50% off',
        validTo: now.add(const Duration(days: 5)),
        type: OfferType.bogo,
        discountPercent: 25,
      ),
      Offer(
        id: 'of-5',
        storeId: 'aldi-1',
        title: 'Produce Wednesday: extra 10% off produce',
        discountPercent: 10,
        validTo: now.add(const Duration(days: 3)),
        type: OfferType.discount,
      ),
    ];
  }

  static List<Coupon> get coupons {
    final now = DateTime.now();
    return [
      Coupon(
        id: 'cp-1',
        storeId: 'kroger-1',
        productId: 'cereal',
        title: '\$1 off Honey Nut Cereal',
        code: 'CEREAL1',
        discountAmount: 1.00,
        expiresAt: now.add(const Duration(days: 2)),
      ),
      Coupon(
        id: 'cp-2',
        storeId: null,
        productId: null,
        title: '\$5 off any \$40 basket',
        code: 'SAVE5',
        discountAmount: 5.00,
        minSpend: 40,
        expiresAt: now.add(const Duration(days: 10)),
      ),
      Coupon(
        id: 'cp-3',
        storeId: 'heb-1',
        productId: 'yogurt',
        title: '20% off Greek Yogurt',
        discountPercent: 20,
        expiresAt: now.add(const Duration(days: 5)),
      ),
      Coupon(
        id: 'cp-4',
        storeId: 'walmart-1',
        productId: 'pb',
        title: '50c off Peanut Butter',
        discountAmount: 0.50,
        expiresAt: now.add(const Duration(days: 1)),
      ),
    ];
  }
}
