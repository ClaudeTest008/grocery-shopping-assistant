import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/features/products/domain/product.dart';
import 'package:grocery_shopping_assistant/features/products/domain/product_matcher.dart';

/// The matcher writes real prices into a product's history, so its
/// contract is asymmetric: a miss costs nothing, a wrong hit poisons
/// data. These tests pin the conservative behaviour.
void main() {
  const milk = Product(id: 'milk', name: 'Whole Milk', category: 'dairy');
  const almondMilk = Product(
    id: 'almond-milk',
    name: 'Almond Milk',
    category: 'dairy',
  );
  const eggs = Product(id: 'eggs', name: 'Eggs', category: 'dairy');

  test('exact normalized name matches', () {
    expect(
      ProductMatcher.confidentMatch(const [milk, eggs], 'whole milk')?.id,
      'milk',
    );
    expect(
      ProductMatcher.confidentMatch(const [milk], 'WHOLE  MILK')?.id,
      'milk',
    );
  });

  test('catalog name inside a noisy receipt line matches', () {
    expect(
      ProductMatcher.confidentMatch(const [
        milk,
        eggs,
      ], 'GV WHOLE MILK 1GAL')?.id,
      'milk',
    );
  });

  test('ambiguity refuses to match', () {
    // "almond milk 64oz" contains both "Almond Milk" and... only one
    // catalog name — but a line containing two full catalog names must
    // not pick either.
    expect(
      ProductMatcher.confidentMatch(const [
        milk,
        almondMilk,
      ], 'whole milk and almond milk'),
      isNull,
    );
  });

  test('substring-of-name alone does not match', () {
    // "milk" is a substring of "Whole Milk" but not the full catalog
    // name; guessing here would be wrong half the time.
    expect(
      ProductMatcher.confidentMatch(const [milk, almondMilk], 'milk'),
      isNull,
    );
  });

  test('short or empty text never matches', () {
    expect(ProductMatcher.confidentMatch(const [eggs], 'eg'), isNull);
    expect(ProductMatcher.confidentMatch(const [eggs], '  '), isNull);
  });

  test('punctuation and case are ignored', () {
    expect(ProductMatcher.confidentMatch(const [eggs], 'EGGS*'), isNotNull);
  });
}
