import '../../features/coupons/domain/coupon.dart';
import '../../features/offers/domain/offer.dart';
import '../../features/products/domain/price.dart';
import '../../features/products/domain/product.dart';
import '../../features/stores/domain/store.dart';
import '../geo/countries.dart';

/// Deterministic seed data backing demo mode, generated for the
/// selected [CountryConfig]: that country's chains around its demo
/// city, prices in its currency at its price level, product names in
/// its primary language. Adding a country adds DATA (a registry entry
/// and name translations) — none of this generation logic changes.
abstract final class DemoSeed {
  static const demoUserId = 'demo-user';

  static CountryConfig _country = Countries.fallback;

  static CountryConfig get country => _country;

  /// Switching country invalidates every generated collection; callers
  /// restart the app scope afterwards so providers re-read the seed.
  static set country(CountryConfig value) {
    if (identical(_country, value)) return;
    _country = value;
    _stores = null;
    _products = null;
  }

  // -- Stores -------------------------------------------------------------

  static List<Store>? _stores;

  /// Generic district labels — demo addresses are deliberately not real
  /// street addresses of real shops.
  static const _districts = [
    'City centre',
    'Old town',
    'Riverside',
    'North district',
    'Station quarter',
    'University area',
    'South district',
    'Market square',
    'Harbour side',
    'West end',
    'Park district',
    'East district',
  ];

  /// Deterministic coordinate offsets (~0.5–5 km) around the city
  /// centre; paired with districts by index.
  static const _offsets = [
    (0.0021, -0.0035),
    (-0.0140, 0.0080),
    (0.0090, 0.0180),
    (0.0260, -0.0120),
    (-0.0230, -0.0260),
    (0.0170, 0.0310),
    (-0.0360, 0.0140),
    (0.0330, 0.0220),
    (-0.0080, -0.0410),
    (0.0440, 0.0050),
    (-0.0290, 0.0370),
    (0.0120, -0.0480),
  ];

  static List<Store> get stores => _stores ??= _generateStores();

  static List<Store> _generateStores() {
    final c = _country;
    final out = <Store>[];
    var slot = 0;
    for (final (i, chain) in c.chains.indexed) {
      // Bigger chains (listed first) get two demo branches.
      final branches = i < 3 ? 2 : 1;
      for (var n = 1; n <= branches && slot < _offsets.length; n++) {
        final (dLat, dLng) = _offsets[slot];
        out.add(
          Store(
            id: '${c.code.toLowerCase()}-${chain.id}-$n',
            name: branches > 1
                ? '${chain.name} ${_districts[slot]}'
                : chain.name,
            chain: chain.id,
            address: '${_districts[slot]}, ${c.city}',
            lat: c.lat + dLat,
            lng: c.lng + dLng,
            country: c.code,
            city: c.city,
            openingHours: {
              for (var d = 1; d <= 6; d++) '$d': '08:00-21:00',
              // Sunday hours are shorter across European chains; some
              // German stores close — kept open-but-short for a
              // friendlier demo.
              '7': '09:00-20:00',
            },
          ),
        );
        slot++;
      }
    }
    return out;
  }

  static double _chainMultiplier(String storeId) {
    for (final chain in _country.chains) {
      if (storeId.contains('-${chain.id}-')) {
        // Small per-branch jitter keeps two branches from being twins.
        final branchJitter = storeId.endsWith('-2') ? 0.015 : 0.0;
        return chain.priceMultiplier + branchJitter;
      }
    }
    return 1.0;
  }

  // -- Products -----------------------------------------------------------

  /// (id, English name, category, US unit, US size, tags)
  static const _baseSpecs = [
    ('milk', 'Whole Milk', 'dairy', 'gal', 1.0, <String>[]),
    ('eggs', 'Large Eggs, Dozen', 'dairy', 'ct', 12.0, <String>[]),
    ('butter', 'Salted Butter', 'dairy', 'oz', 16.0, <String>[]),
    ('cheddar', 'Shredded Cheddar', 'dairy', 'oz', 8.0, <String>[]),
    ('yogurt', 'Greek Yogurt', 'dairy', 'oz', 32.0, <String>[]),
    ('bananas', 'Bananas', 'produce', 'lb', 1.0, ['vegan']),
    ('apples', 'Gala Apples', 'produce', 'lb', 1.0, ['vegan']),
    ('lettuce', 'Romaine Lettuce', 'produce', 'ea', 1.0, ['vegan']),
    ('tomatoes', 'Roma Tomatoes', 'produce', 'lb', 1.0, ['vegan']),
    ('broccoli', 'Broccoli Crowns', 'produce', 'lb', 1.0, ['vegan']),
    ('chicken', 'Chicken Breast', 'meat', 'lb', 1.0, <String>[]),
    ('gbeef', 'Ground Beef', 'meat', 'lb', 1.0, <String>[]),
    ('turkey', 'Ground Turkey', 'meat', 'lb', 1.0, <String>[]),
    ('bread', 'Whole Wheat Bread', 'bakery', 'loaf', 1.0, <String>[]),
    ('tortillas', 'Flour Tortillas', 'bakery', 'ct', 10.0, <String>[]),
    ('rice', 'Long Grain Rice', 'pantry', 'lb', 2.0, ['vegan']),
    ('pasta', 'Spaghetti', 'pantry', 'oz', 16.0, ['vegan']),
    ('beans', 'Black Beans', 'pantry', 'can', 1.0, ['vegan']),
    ('tomsauce', 'Canned Tomatoes', 'pantry', 'can', 1.0, ['vegan']),
    ('pb', 'Peanut Butter', 'pantry', 'oz', 16.0, ['vegan']),
    ('cereal', 'Honey Cereal', 'pantry', 'oz', 18.0, <String>[]),
    ('coffee', 'Ground Coffee', 'beverages', 'oz', 24.0, ['vegan']),
    ('oj', 'Orange Juice', 'beverages', 'oz', 52.0, ['vegan']),
    ('frbroccoli', 'Frozen Broccoli', 'frozen', 'oz', 12.0, ['vegan']),
    ('icecream', 'Vanilla Ice Cream', 'frozen', 'oz', 16.0, <String>[]),
    ('tofu', 'Firm Tofu', 'meat', 'oz', 14.0, ['vegan']),
  ];

  /// Product names in each supported demo language. English entries are
  /// the [_baseSpecs] names; a missing language falls back to English
  /// rather than crashing — worst case the demo reads untranslated.
  static const _localizedNames = <String, Map<String, String>>{
    'es': {
      'milk': 'Leche Entera',
      'eggs': 'Huevos L, Docena',
      'butter': 'Mantequilla con Sal',
      'cheddar': 'Queso Cheddar Rallado',
      'yogurt': 'Yogur Griego',
      'bananas': 'Plátanos',
      'apples': 'Manzanas Gala',
      'lettuce': 'Lechuga Romana',
      'tomatoes': 'Tomates Pera',
      'broccoli': 'Brócoli',
      'chicken': 'Pechuga de Pollo',
      'gbeef': 'Carne Picada de Vacuno',
      'turkey': 'Carne Picada de Pavo',
      'bread': 'Pan Integral',
      'tortillas': 'Tortillas de Trigo',
      'rice': 'Arroz de Grano Largo',
      'pasta': 'Espaguetis',
      'beans': 'Alubias Negras',
      'tomsauce': 'Tomate Triturado',
      'pb': 'Crema de Cacahuete',
      'cereal': 'Cereales con Miel',
      'coffee': 'Café Molido',
      'oj': 'Zumo de Naranja',
      'frbroccoli': 'Brócoli Congelado',
      'icecream': 'Helado de Vainilla',
      'tofu': 'Tofu Firme',
    },
    'pt': {
      'milk': 'Leite Gordo',
      'eggs': 'Ovos L, Dúzia',
      'butter': 'Manteiga com Sal',
      'cheddar': 'Queijo Cheddar Ralado',
      'yogurt': 'Iogurte Grego',
      'bananas': 'Bananas',
      'apples': 'Maçãs Gala',
      'lettuce': 'Alface Romana',
      'tomatoes': 'Tomate Chucha',
      'broccoli': 'Brócolos',
      'chicken': 'Peito de Frango',
      'gbeef': 'Carne Picada de Vaca',
      'turkey': 'Carne Picada de Peru',
      'bread': 'Pão Integral',
      'tortillas': 'Tortilhas de Trigo',
      'rice': 'Arroz Agulha',
      'pasta': 'Esparguete',
      'beans': 'Feijão Preto',
      'tomsauce': 'Tomate Pelado',
      'pb': 'Manteiga de Amendoim',
      'cereal': 'Cereais com Mel',
      'coffee': 'Café Moído',
      'oj': 'Sumo de Laranja',
      'frbroccoli': 'Brócolos Congelados',
      'icecream': 'Gelado de Baunilha',
      'tofu': 'Tofu Firme',
    },
    'fr': {
      'milk': 'Lait Entier',
      'eggs': 'Œufs L, Douzaine',
      'butter': 'Beurre Demi-Sel',
      'cheddar': 'Cheddar Râpé',
      'yogurt': 'Yaourt Grec',
      'bananas': 'Bananes',
      'apples': 'Pommes Gala',
      'lettuce': 'Laitue Romaine',
      'tomatoes': 'Tomates Roma',
      'broccoli': 'Brocoli',
      'chicken': 'Blanc de Poulet',
      'gbeef': 'Bœuf Haché',
      'turkey': 'Dinde Hachée',
      'bread': 'Pain Complet',
      'tortillas': 'Tortillas de Blé',
      'rice': 'Riz Long Grain',
      'pasta': 'Spaghetti',
      'beans': 'Haricots Noirs',
      'tomsauce': 'Tomates Concassées',
      'pb': 'Beurre de Cacahuète',
      'cereal': 'Céréales au Miel',
      'coffee': 'Café Moulu',
      'oj': "Jus d'Orange",
      'frbroccoli': 'Brocoli Surgelé',
      'icecream': 'Glace à la Vanille',
      'tofu': 'Tofu Ferme',
    },
    'de': {
      'milk': 'Vollmilch',
      'eggs': 'Eier Gr. L, 12er',
      'butter': 'Gesalzene Butter',
      'cheddar': 'Geriebener Cheddar',
      'yogurt': 'Griechischer Joghurt',
      'bananas': 'Bananen',
      'apples': 'Gala-Äpfel',
      'lettuce': 'Römersalat',
      'tomatoes': 'Roma-Tomaten',
      'broccoli': 'Brokkoli',
      'chicken': 'Hähnchenbrust',
      'gbeef': 'Rinderhackfleisch',
      'turkey': 'Putenhackfleisch',
      'bread': 'Vollkornbrot',
      'tortillas': 'Weizen-Tortillas',
      'rice': 'Langkornreis',
      'pasta': 'Spaghetti',
      'beans': 'Schwarze Bohnen',
      'tomsauce': 'Dosentomaten',
      'pb': 'Erdnussbutter',
      'cereal': 'Honig-Cerealien',
      'coffee': 'Gemahlener Kaffee',
      'oj': 'Orangensaft',
      'frbroccoli': 'TK-Brokkoli',
      'icecream': 'Vanilleeis',
      'tofu': 'Tofu Natur',
    },
    'it': {
      'milk': 'Latte Intero',
      'eggs': 'Uova L, Dozzina',
      'butter': 'Burro Salato',
      'cheddar': 'Cheddar Grattugiato',
      'yogurt': 'Yogurt Greco',
      'bananas': 'Banane',
      'apples': 'Mele Gala',
      'lettuce': 'Lattuga Romana',
      'tomatoes': 'Pomodori Roma',
      'broccoli': 'Broccoli',
      'chicken': 'Petto di Pollo',
      'gbeef': 'Macinato di Manzo',
      'turkey': 'Macinato di Tacchino',
      'bread': 'Pane Integrale',
      'tortillas': 'Tortillas di Grano',
      'rice': 'Riso a Grano Lungo',
      'pasta': 'Spaghetti',
      'beans': 'Fagioli Neri',
      'tomsauce': 'Pomodori Pelati',
      'pb': 'Burro di Arachidi',
      'cereal': 'Cereali al Miele',
      'coffee': 'Caffè Macinato',
      'oj': "Succo d'Arancia",
      'frbroccoli': 'Broccoli Surgelati',
      'icecream': 'Gelato alla Vaniglia',
      'tofu': 'Tofu al Naturale',
    },
    'nl': {
      'milk': 'Volle Melk',
      'eggs': 'Eieren L, Dozijn',
      'butter': 'Gezouten Roomboter',
      'cheddar': 'Geraspte Cheddar',
      'yogurt': 'Griekse Yoghurt',
      'bananas': 'Bananen',
      'apples': 'Gala-appels',
      'lettuce': 'Romaine Sla',
      'tomatoes': 'Roma-tomaten',
      'broccoli': 'Broccoli',
      'chicken': 'Kipfilet',
      'gbeef': 'Rundergehakt',
      'turkey': 'Kalkoengehakt',
      'bread': 'Volkorenbrood',
      'tortillas': 'Tarwe-tortillas',
      'rice': 'Langkorrelrijst',
      'pasta': 'Spaghetti',
      'beans': 'Zwarte Bonen',
      'tomsauce': 'Tomatenblokjes',
      'pb': 'Pindakaas',
      'cereal': 'Honing Cornflakes',
      'coffee': 'Gemalen Koffie',
      'oj': 'Sinaasappelsap',
      'frbroccoli': 'Diepvries Broccoli',
      'icecream': 'Vanille-ijs',
      'tofu': 'Tofu Naturel',
    },
  };

  /// US package units to metric: (unit, factor applied to size).
  static const _metricUnits = <String, (String, double)>{
    'gal': ('l', 3.8),
    'oz': ('g', 28.0),
    'lb': ('kg', 0.45),
  };

  /// (id suffix, brand, price factor, extra tags) — value / premium /
  /// organic variants; brands are fictional private labels on purpose.
  static const _variantSpecs = [
    ('value', 'Field Day', 0.85, <String>[]),
    ('premium', 'Harvest Reserve', 1.30, <String>[]),
    ('organic', 'Simply Organic', 1.45, ['organic']),
  ];

  static List<Product>? _products;

  static List<Product> get products => _products ??= _generateProducts();

  static List<Product> _generateProducts() {
    final language = _country.primaryLanguage;
    final names = _localizedNames[language] ?? const <String, String>{};
    final metric = _country.units == 'metric';

    Product base(
      String id,
      String english,
      String category,
      String unit,
      double size,
      List<String> tags,
    ) {
      var u = unit;
      var s = size;
      if (metric && _metricUnits.containsKey(unit)) {
        final (mu, factor) = _metricUnits[unit]!;
        u = mu;
        s = _round(size * factor);
      }
      return Product(
        id: id,
        name: names[id] ?? english,
        // Base products are unbranded outside the US demo; the US
        // dataset's real-brand feel comes from the variants either way.
        category: category,
        unit: u,
        unitSize: s,
        barcode: '0000${id.hashCode.abs()}',
        tags: tags,
        nutrition: const {'calories': 120, 'protein_g': 4, 'fat_g': 3},
      );
    }

    final bases = [
      for (final (id, name, cat, unit, size, tags) in _baseSpecs)
        base(id, name, cat, unit, size, tags),
    ];
    return [
      ...bases,
      for (final b in bases)
        for (final (suffix, brand, _, extraTags) in _variantSpecs)
          b.copyWith(
            id: '${b.id}-$suffix',
            brand: brand,
            barcode: '0000${'${b.id}-$suffix'.hashCode.abs()}',
            tags: [...b.tags, ...extraTags],
          ),
    ];
  }

  /// Price factor for a (possibly variant) product id.
  static double _variantFactor(String productId) {
    final dash = productId.indexOf('-');
    if (dash < 0) return 1;
    final suffix = productId.substring(dash + 1);
    for (final (s, _, factor, _) in _variantSpecs) {
      if (s == suffix) return factor;
    }
    return 1;
  }

  /// Base product id for a variant ('milk-organic' -> 'milk').
  static String _baseId(String productId) {
    final dash = productId.indexOf('-');
    return dash < 0 ? productId : productId.substring(0, dash);
  }

  /// Baseline prices (US price level 1.0); each country scales them by
  /// its [CountryConfig.priceLevel] and shows its own currency.
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

  /// Items a store does NOT carry — deterministic per store so the
  /// optimizer's partial-availability handling stays demoable in every
  /// country.
  static Set<String> _notCarried(String storeId) {
    final ids = _basePrices.keys.toList();
    final h = storeId.hashCode.abs();
    return {ids[h % ids.length], ids[(h ~/ 7) % ids.length]};
  }

  static bool _isPromo(String storeId, String baseId) {
    final index = stores.indexWhere((s) => s.id == storeId);
    if (index < 0 || index > 3) return false;
    final ids = _basePrices.keys.toList();
    final h = (storeId.hashCode ^ baseId.hashCode).abs();
    return ids[h % ids.length] == baseId ||
        ids[(h ~/ 11) % ids.length] == baseId;
  }

  static List<Price> get prices {
    final now = DateTime.now();
    final out = <Price>[];
    for (final store in stores) {
      final mult = _chainMultiplier(store.id) * _country.priceLevel;
      final skip = _notCarried(store.id);
      for (final product in products) {
        final baseId = _baseId(product.id);
        if (skip.contains(baseId)) continue;
        final basePrice =
            (_basePrices[baseId] ?? 2.99) * _variantFactor(product.id);
        // Deterministic per-pair jitter of +-4%.
        final jitter =
            1 + (((product.id.hashCode ^ store.id.hashCode) % 9) - 4) / 100;
        var price = _round(basePrice * mult * jitter);
        double? regular;
        if (product.id == baseId && _isPromo(store.id, baseId)) {
          regular = price;
          price = _round(price * 0.78);
        }
        // ~4% of pairs are deterministically out of stock so inventory
        // awareness is demoable.
        final inStock = (product.id.hashCode ^ store.id.hashCode) % 23 != 0;
        out.add(
          Price(
            id: '${store.id}-${product.id}',
            productId: product.id,
            storeId: store.id,
            price: price,
            currency: _country.currency,
            regularPrice: regular,
            inStock: inStock,
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

  /// Synthetic but plausible 90-day price history, scaled like [prices].
  static List<PricePoint> priceHistory(String productId) {
    final base =
        (_basePrices[_baseId(productId)] ?? 2.99) *
        _variantFactor(productId) *
        _country.priceLevel;
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
          source: 'seed',
        ),
    ];
  }

  // Cheap sine substitute avoiding dart:math import noise: triangle wave.
  static double _wave(double t) {
    final f = t - t.floorToDouble();
    return f < 0.5 ? 4 * f - 1 : 3 - 4 * f;
  }

  static String get _symbol => switch (_country.currency) {
    'EUR' => '€',
    'GBP' => '£',
    _ => r'$',
  };

  /// Localized display name for a base product in the current country.
  static String _name(String baseId) {
    final names = _localizedNames[_country.primaryLanguage];
    if (names != null && names.containsKey(baseId)) return names[baseId]!;
    for (final (id, english, _, _, _, _) in _baseSpecs) {
      if (id == baseId) return english;
    }
    return baseId;
  }

  static List<Offer> get offers {
    final now = DateTime.now();
    final s = stores;
    if (s.length < 5) return const [];
    return [
      Offer(
        id: 'of-1',
        storeId: s[0].id,
        productId: 'chicken',
        title: '${_name('chicken')} 22% off',
        description: 'Weekly ad — fresh value pack.',
        discountPercent: 22,
        validTo: now.add(const Duration(days: 4)),
        type: OfferType.weeklyAd,
      ),
      Offer(
        id: 'of-2',
        storeId: s[1].id,
        productId: 'gbeef',
        title: '${_name('gbeef')} sale',
        discountPercent: 22,
        validTo: now.add(const Duration(days: 2)),
        type: OfferType.weeklyAd,
      ),
      Offer(
        id: 'of-3',
        storeId: s[2].id,
        title: '5% cashback on ${_symbol}50+ baskets',
        description: 'Loyalty members earn cashback this week.',
        discountPercent: 5,
        validTo: now.add(const Duration(days: 6)),
        type: OfferType.cashback,
      ),
      Offer(
        id: 'of-4',
        storeId: s[3].id,
        productId: 'coffee',
        title: '${_name('coffee')} BOGO 50% off',
        validTo: now.add(const Duration(days: 5)),
        type: OfferType.bogo,
        discountPercent: 25,
      ),
      Offer(
        id: 'of-5',
        storeId: s[4].id,
        title: 'Produce day: extra 10% off produce',
        discountPercent: 10,
        validTo: now.add(const Duration(days: 3)),
        type: OfferType.discount,
      ),
    ];
  }

  static List<Coupon> get coupons {
    final now = DateTime.now();
    final s = stores;
    if (s.length < 4) return const [];
    return [
      Coupon(
        id: 'cp-1',
        storeId: s[0].id,
        productId: 'cereal',
        title: '${_symbol}1 off ${_name('cereal')}',
        code: 'CEREAL1',
        discountAmount: 1.00,
        expiresAt: now.add(const Duration(days: 2)),
      ),
      Coupon(
        id: 'cp-2',
        storeId: null,
        productId: null,
        title: '${_symbol}5 off any ${_symbol}40 basket',
        code: 'SAVE5',
        discountAmount: 5.00,
        minSpend: 40,
        expiresAt: now.add(const Duration(days: 10)),
      ),
      Coupon(
        id: 'cp-3',
        storeId: s[1].id,
        productId: 'yogurt',
        title: '20% off ${_name('yogurt')}',
        discountPercent: 20,
        expiresAt: now.add(const Duration(days: 5)),
      ),
      Coupon(
        id: 'cp-4',
        storeId: s[2].id,
        productId: 'pb',
        title: '${_symbol}0.50 off ${_name('pb')}',
        discountAmount: 0.50,
        expiresAt: now.add(const Duration(days: 1)),
      ),
    ];
  }
}
