import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/features/receipts/domain/receipt_parser.dart';

void main() {
  const parser = ReceiptParser();

  test('parses a typical US grocery receipt', () {
    const ocr = '''
WALMART SUPERCENTER
710 E BEN WHITE BLVD
AUSTIN TX 78704
07/02/2026 18:42
GV WHOLE MILK 3.21 F
LARGE EGGS DOZEN 2.66 F
BANANAS 1.16 F
SUBTOTAL 7.03
TAX 0.00
TOTAL 7.03
DEBIT TEND 7.03
''';

    final receipt = parser.parse(ocr, userId: 'u1');

    expect(receipt.storeName, 'Walmart');
    expect(receipt.total, 7.03);
    expect(receipt.items, hasLength(3));
    expect(receipt.items.first.name, 'Gv Whole Milk');
    expect(receipt.items.first.price, 3.21);
    expect(receipt.purchasedAt.year, 2026);
    expect(receipt.purchasedAt.month, 7);
    expect(receipt.purchasedAt.day, 2);
    expect(receipt.userId, 'u1');
  });

  test('falls back to item sum when no total line found', () {
    const ocr = '''
CORNER MARKET
APPLES 2.50
BREAD 2.00
''';
    final receipt = parser.parse(ocr, userId: 'u1');
    expect(receipt.total, 4.50);
    expect(receipt.storeName, 'CORNER MARKET');
  });

  test('skips subtotal/tax/payment lines as items', () {
    const ocr = '''
KROGER
MILK 3.56
SUBTOTAL 3.56
TAX 0.29
TOTAL 3.85
CREDIT 3.85
''';
    final receipt = parser.parse(ocr, userId: 'u1');
    expect(receipt.items, hasLength(1));
    expect(receipt.total, 3.85);
  });

  test('handles empty input without crashing', () {
    final receipt = parser.parse('', userId: 'u1');
    expect(receipt.items, isEmpty);
    expect(receipt.total, 0);
  });
}
