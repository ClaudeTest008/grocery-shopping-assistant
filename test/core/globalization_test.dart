import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/demo/demo_seed.dart';
import 'package:grocery_shopping_assistant/core/geo/countries.dart';
import 'package:grocery_shopping_assistant/core/utils/formatters.dart';
import 'package:grocery_shopping_assistant/features/products/data/product_repositories.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price_verdict.dart';
import 'package:grocery_shopping_assistant/features/receipts/domain/receipt_parser.dart';

/// The globalization contract: countries are data, the generators are
/// shared, and nothing US-specific survives outside the US entry.
void main() {
  tearDown(() {
    DemoSeed.country = Countries.byCode('US');
    Formatters.defaultCurrency = 'USD';
  });

  group('country registry', () {
    test('supports the eight European launch countries plus the US', () {
      final codes = Countries.all.map((c) => c.code).toList();
      expect(
        codes,
        containsAll(['ES', 'PT', 'FR', 'DE', 'IT', 'NL', 'BE', 'IE', 'US']),
      );
      expect(codes.toSet().length, codes.length, reason: 'unique codes');
    });

    test('every EU entry is eurozone, metric, VAT-inclusive, DD/MM', () {
      for (final c in Countries.all.where((c) => c.code != 'US')) {
        expect(c.currency, 'EUR', reason: c.code);
        expect(c.units, 'metric', reason: c.code);
        expect(c.pricesIncludeVat, isTrue, reason: c.code);
        expect(c.dmyDates, isTrue, reason: c.code);
        expect(c.chains, isNotEmpty, reason: c.code);
        // Plausible European coordinates.
        expect(c.lat, inInclusiveRange(35, 60), reason: c.code);
        expect(c.lng, inInclusiveRange(-10, 15), reason: c.code);
      }
    });

    test('the specified chains exist per country', () {
      List<String> chains(String code) =>
          Countries.byCode(code).chains.map((s) => s.name).toList();
      expect(
        chains('ES'),
        containsAll(['Mercadona', 'Lidl', 'Dia', 'Hipercor']),
      );
      expect(
        chains('PT'),
        containsAll(['Continente', 'Pingo Doce', 'Minipreço']),
      );
      expect(
        chains('FR'),
        containsAll(['Carrefour', 'E.Leclerc', 'Casino', 'Super U']),
      );
      expect(
        chains('DE'),
        containsAll(['Edeka', 'Rewe', 'Aldi Nord', 'Netto', 'Penny']),
      );
      expect(
        chains('IT'),
        containsAll(['Esselunga', 'Eurospin', 'Pam', 'Carrefour Italia']),
      );
      expect(chains('NL'), containsAll(['Albert Heijn', 'Jumbo', 'Dirk']));
      expect(chains('BE'), containsAll(['Colruyt', 'Delhaize', 'Okay']));
      expect(chains('IE'), containsAll(['Tesco', 'Dunnes Stores']));
    });

    test('private labels are data on the chain, never hardcoded', () {
      final mercadona = Countries.byCode(
        'ES',
      ).chains.firstWhere((c) => c.id == 'mercadona');
      expect(mercadona.privateLabel, 'Hacendado');
    });

    test('unsupported codes fall back instead of throwing', () {
      expect(Countries.byCode('XX').code, 'US');
      expect(Countries.supports('es'), isTrue, reason: 'case-insensitive');
    });
  });

  group('per-country demo generation', () {
    test('Spain: Spanish stores, Spanish names, euro prices', () {
      DemoSeed.country = Countries.byCode('ES');

      expect(DemoSeed.stores, isNotEmpty);
      for (final store in DemoSeed.stores) {
        expect(store.country, 'ES');
        expect(store.id, startsWith('es-'));
        expect(store.city, 'Madrid');
        // Within a few dozen km of the Madrid centre.
        expect((store.lat - 40.4168).abs(), lessThan(0.2));
      }
      expect(
        DemoSeed.stores.map((s) => s.chain).toSet(),
        containsAll(['mercadona', 'lidl', 'carrefour']),
      );

      final milk = DemoSeed.products.firstWhere((p) => p.id == 'milk');
      expect(milk.name, 'Leche Entera');
      expect(milk.unit, 'l', reason: 'metric units in metric countries');

      final prices = DemoSeed.prices;
      expect(prices, isNotEmpty);
      expect(prices.every((p) => p.currency == 'EUR'), isTrue);
    });

    test('US stays exactly one country among many', () {
      DemoSeed.country = Countries.byCode('US');
      final milk = DemoSeed.products.firstWhere((p) => p.id == 'milk');
      expect(milk.name, 'Whole Milk');
      expect(milk.unit, 'gal');
      expect(DemoSeed.stores.first.country, 'US');
      expect(DemoSeed.prices.first.currency, 'USD');
    });

    test('every country generates a working optimizer dataset', () {
      for (final c in Countries.all) {
        DemoSeed.country = c;
        expect(DemoSeed.stores.length, greaterThanOrEqualTo(4), reason: c.code);
        expect(
          DemoSeed.stores.map((s) => s.id).toSet().length,
          DemoSeed.stores.length,
          reason: '${c.code}: unique store ids',
        );
        expect(DemoSeed.prices.length, greaterThan(200), reason: c.code);
        expect(DemoSeed.offers, isNotEmpty, reason: c.code);
        expect(DemoSeed.coupons, isNotEmpty, reason: c.code);
        // Offers/coupons must reference this country's stores.
        for (final offer in DemoSeed.offers) {
          expect(
            DemoSeed.stores.any((s) => s.id == offer.storeId),
            isTrue,
            reason: '${c.code}: ${offer.storeId}',
          );
        }
      }
    });

    test('European store realism: hours, parking, services', () {
      DemoSeed.country = Countries.byCode('DE');
      // Sunday trading closed in Germany — a real market fact the
      // open-now logic must respect.
      expect(
        DemoSeed.stores.every((s) => s.openingHours?['7'] == 'closed'),
        isTrue,
      );
      DemoSeed.country = Countries.byCode('ES');
      for (final store in DemoSeed.stores) {
        expect(store.hasParking, isNotNull);
        expect(store.services, isNotEmpty);
      }
      // City-centre branches have no car park; out-of-town ones do.
      expect(DemoSeed.stores.first.hasParking, isFalse);
      expect(DemoSeed.stores.last.hasParking, isTrue);
    });

    test('the catalog covers European household categories', () {
      DemoSeed.country = Countries.byCode('ES');
      final categories = DemoSeed.products.map((p) => p.category).toSet();
      expect(
        categories,
        containsAll(['health', 'baby', 'pet', 'household', 'drinks']),
      );
      // Localized names extend to the new categories.
      expect(
        DemoSeed.products.firstWhere((p) => p.id == 'detergent').name,
        'Detergente para Ropa',
      );
      // EU allergen declarations ride on the product.
      expect(
        DemoSeed.products.firstWhere((p) => p.id == 'milk').allergens,
        contains('milk'),
      );
      // Non-food carries no nutrition panel.
      expect(
        DemoSeed.products.firstWhere((p) => p.id == 'paper').nutrition,
        isNull,
      );
    });

    test('search is accent-insensitive in every language', () async {
      DemoSeed.country = Countries.byCode('ES');
      final repo = DemoProductRepository();
      final unaccented = await repo.search(query: 'platano');
      expect(unaccented.map((p) => p.id), contains('bananas'));
      final accented = await repo.search(query: 'plátano');
      expect(accented.map((p) => p.id), contains('bananas'));
    });

    test('price level scales with the country', () {
      double milkAt(String code) {
        DemoSeed.country = Countries.byCode(code);
        return DemoSeed.priceHistory('milk').last.price;
      }

      // Ireland (1.12) must be dearer than Portugal (0.88) for the same
      // product on the same day.
      expect(milkAt('IE'), greaterThan(milkAt('PT')));
    });
  });

  group('localization plumbing', () {
    test('price verdicts speak the selected currency', () {
      Formatters.defaultCurrency = 'EUR';
      final now = DateTime.now();
      final points = [
        for (var d = 30; d >= 0; d -= 5)
          PricePoint(
            recordedAt: now.subtract(Duration(days: d)),
            price: 2.0 + (d % 3) * 0.2,
          ),
      ];
      final verdict = points.verdictFor(1.9)!;
      expect(verdict.explanation, contains('€'));
      expect(verdict.explanation, isNot(contains(r'$')));
    });

    test('receipt parser reads European receipts', () {
      final receipt = ReceiptParser(dmyDates: true).parse(
        'MERCADONA\n'
        '05/03/2026\n'
        'Leche Entera  €1,05\n'
        'Plátanos  €0,99\n'
        'TOTAL  €2,04\n',
        userId: 'u1',
      );
      expect(receipt.storeName, 'Mercadona');
      expect(receipt.purchasedAt.month, 3, reason: 'DD/MM order');
      expect(receipt.purchasedAt.day, 5);
      expect(receipt.items, hasLength(2));
      expect(receipt.total, closeTo(2.04, 0.001));
    });

    test('US date order still parses as MM/DD', () {
      final receipt = ReceiptParser().parse(
        'KROGER\n05/03/2026\nMilk  \$3.49\nTOTAL \$3.49\n',
        userId: 'u1',
      );
      expect(receipt.purchasedAt.month, 5);
      expect(receipt.purchasedAt.day, 3);
    });
  });
}
