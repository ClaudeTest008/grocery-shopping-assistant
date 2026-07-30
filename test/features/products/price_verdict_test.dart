import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price_verdict.dart';

/// The verdict is the app's answer to "is this a good price right now",
/// so it has to be right at the boundaries and silent when it does not
/// have enough evidence.
void main() {
  List<PricePoint> history(List<double> prices) {
    final start = DateTime(2026, 4, 1);
    return [
      for (var i = 0; i < prices.length; i++)
        PricePoint(
          recordedAt: start.add(Duration(days: i * 3)),
          price: prices[i],
        ),
    ];
  }

  group('evidence threshold', () {
    test('says nothing with too few observations', () {
      expect(history([3.0, 3.1, 3.2, 3.1]).verdictFor(3.0), isNull);
    });

    test('speaks once there are enough', () {
      expect(history([3.0, 3.1, 3.2, 3.1, 3.0]).verdictFor(3.0), isNotNull);
    });
  });

  group('standing', () {
    final series = history([3.00, 3.20, 3.40, 3.20, 3.00, 3.20]);
    // average = 3.1667, lowest = 3.00, highest = 3.40

    test('at or below the floor reads as the lowest', () {
      expect(series.verdictFor(3.00)!.standing, PriceStanding.lowest);
      expect(series.verdictFor(2.80)!.standing, PriceStanding.lowest);
    });

    test('at the ceiling reads as the highest', () {
      expect(series.verdictFor(3.40)!.standing, PriceStanding.highest);
    });

    test('near the mean reads as typical', () {
      expect(series.verdictFor(3.17)!.standing, PriceStanding.typical);
    });

    test('meaningfully under the mean reads as below', () {
      final v = series.verdictFor(3.02)!;
      expect(v.standing, PriceStanding.below);
      expect(v.percentVsAverage, lessThan(0));
    });

    test('meaningfully over the mean reads as above', () {
      final v = series.verdictFor(3.35)!;
      expect(v.standing, PriceStanding.above);
      expect(v.percentVsAverage, greaterThan(0));
    });
  });

  group('derived numbers', () {
    final series = history([2.00, 4.00, 3.00, 3.00, 3.00, 3.00]);
    // average = 3.00

    test('reports the saving only when actually cheaper', () {
      expect(series.verdictFor(2.70)!.savingVsAverage, closeTo(0.30, 0.001));
      expect(series.verdictFor(3.50)!.savingVsAverage, 0);
    });

    test('flags a good time to buy only when cheap', () {
      expect(series.verdictFor(2.00)!.isGoodTime, isTrue);
      expect(series.verdictFor(3.00)!.isGoodTime, isFalse);
      expect(series.verdictFor(4.00)!.isGoodTime, isFalse);
    });

    test('measures the window from the observations themselves', () {
      // 6 points, 3 days apart => 15 days end to end.
      expect(series.verdictFor(3.00)!.windowDays, 15);
    });

    test('every standing produces a non-empty headline and explanation', () {
      for (final probe in [2.00, 2.70, 3.00, 3.50, 4.00]) {
        final v = series.verdictFor(probe)!;
        expect(v.headline, isNotEmpty);
        expect(v.explanation, isNotEmpty);
      }
    });
  });

  test('degenerate history never divides by zero', () {
    expect(history([0, 0, 0, 0, 0]).verdictFor(0), isNull);
  });
}
