import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/features/coupons/domain/coupon.dart';

void main() {
  final future = DateTime.now().add(const Duration(days: 5));
  final past = DateTime.now().subtract(const Duration(days: 1));

  group('Coupon.valueOn', () {
    test('amount coupon clamps to price', () {
      final coupon = Coupon(
        id: 'c',
        title: r'$2 off',
        discountAmount: 2,
        expiresAt: future,
      );
      expect(coupon.valueOn(5.00), 2.00);
      expect(coupon.valueOn(1.50), 1.50); // never negative price
    });

    test('percent coupon scales with price', () {
      final coupon = Coupon(
        id: 'c',
        title: '20% off',
        discountPercent: 20,
        expiresAt: future,
      );
      expect(coupon.valueOn(10.00), closeTo(2.00, 0.001));
    });

    test('expired coupon is worthless', () {
      final coupon = Coupon(
        id: 'c',
        title: r'$2 off',
        discountAmount: 2,
        expiresAt: past,
      );
      expect(coupon.isExpired, isTrue);
      expect(coupon.valueOn(10.00), 0);
    });
  });
}
