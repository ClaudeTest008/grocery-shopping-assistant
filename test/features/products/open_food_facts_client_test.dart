import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/features/products/data/open_food_facts_client.dart';

/// Pins the parse contract against the real OFF v2 response shape —
/// the network call itself is a thin Dio GET around this.
void main() {
  test('parses a found product', () {
    final external = ExternalProduct.fromOffJson(const {
      'status': 1,
      'code': '737628064502',
      'product': {
        'product_name': 'Rice Noodles',
        'brands': 'Thai Kitchen,Simply Asia',
        'image_front_small_url': 'https://images.openfoodfacts.org/x.jpg',
      },
    });

    expect(external, isNotNull);
    expect(external!.name, 'Rice Noodles');
    expect(external.brand, 'Thai Kitchen', reason: 'first brand wins');
    expect(external.imageUrl, contains('openfoodfacts'));
    expect(external.label, 'Rice Noodles — Thai Kitchen');
  });

  test('unknown barcode (status 0) returns null', () {
    expect(
      ExternalProduct.fromOffJson(const {'status': 0, 'code': '000'}),
      isNull,
    );
  });

  test('found but nameless product returns null', () {
    expect(
      ExternalProduct.fromOffJson(const {
        'status': 1,
        'product': {'product_name': '  ', 'brands': 'X'},
      }),
      isNull,
    );
  });

  test('missing or malformed product payload returns null', () {
    expect(ExternalProduct.fromOffJson(const {'status': 1}), isNull);
    expect(
      ExternalProduct.fromOffJson(const {'status': 1, 'product': 'nope'}),
      isNull,
    );
  });

  test('label without brand is just the name', () {
    final external = ExternalProduct.fromOffJson(const {
      'status': 1,
      'product': {'product_name': 'Oat Milk', 'brands': ''},
    });
    expect(external!.brand, isNull);
    expect(external.label, 'Oat Milk');
  });
}
