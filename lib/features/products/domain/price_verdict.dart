import 'price.dart';

/// Where a price sits against its own recent history.
enum PriceStanding { lowest, below, typical, above, highest }

/// Answers the question a shopper actually has in the aisle: not "what
/// does this cost" — the label says that — but "is this a good price
/// *right now*".
///
/// Deliberately descriptive, never predictive. It reports what the
/// recorded history says; it does not forecast the next sale, because
/// inferring a sale cycle from a short, noisy series would be inventing
/// a number.
class PriceVerdict {
  const PriceVerdict({
    required this.standing,
    required this.current,
    required this.lowest,
    required this.average,
    required this.highest,
    required this.windowDays,
  });

  final PriceStanding standing;
  final double current;
  final double lowest;
  final double average;
  final double highest;
  final int windowDays;

  /// Negative means cheaper than usual.
  double get percentVsAverage =>
      average == 0 ? 0 : (current - average) / average * 100;

  /// How much less than usual you pay right now, per unit. Zero when the
  /// price is at or above average.
  double get savingVsAverage => current < average ? average - current : 0;

  bool get isGoodTime =>
      standing == PriceStanding.lowest || standing == PriceStanding.below;

  /// One short sentence, safe to show as a chip label.
  String get headline => switch (standing) {
    PriceStanding.lowest => 'Lowest in $windowDays days',
    PriceStanding.below => '${percentVsAverage.abs().round()}% below usual',
    PriceStanding.typical => 'Around its usual price',
    PriceStanding.above => '${percentVsAverage.round()}% above usual',
    PriceStanding.highest => 'Highest in $windowDays days',
  };

  /// A fuller explanation for the detail screen — every recommendation
  /// in this app has to be able to say why.
  String get explanation => switch (standing) {
    PriceStanding.lowest =>
      'This is the cheapest it has been in the last $windowDays days '
          '(usually around ${_money(average)}). A good time to stock up.',
    PriceStanding.below =>
      'Cheaper than usual — it has averaged ${_money(average)} over the '
          'last $windowDays days, ranging ${_money(lowest)} to '
          '${_money(highest)}.',
    PriceStanding.typical =>
      'This is about what it normally costs: ${_money(average)} on '
          'average over the last $windowDays days.',
    PriceStanding.above =>
      'Pricier than usual — it has averaged ${_money(average)} over the '
          'last $windowDays days and has been as low as ${_money(lowest)}.',
    PriceStanding.highest =>
      'This is the most it has cost in $windowDays days. It has been as '
          'low as ${_money(lowest)}, so it may be worth waiting.',
  };

  static String _money(double v) => '\$${v.toStringAsFixed(2)}';
}

extension PriceHistoryStats on List<PricePoint> {
  /// Needs a few observations before any claim is honest.
  static const minimumPoints = 5;

  /// A price within this fraction of the extreme counts as touching it,
  /// so a cent of rounding noise does not hide "lowest in 90 days".
  static const _epsilon = 0.005;

  /// Prices within this percentage of the mean read as "normal".
  static const _typicalBand = 4.0;

  PriceVerdict? verdictFor(double currentPrice) {
    if (length < minimumPoints) return null;

    final prices = map((p) => p.price).toList();
    final lowest = prices.reduce((a, b) => a < b ? a : b);
    final highest = prices.reduce((a, b) => a > b ? a : b);
    final average = prices.reduce((a, b) => a + b) / prices.length;
    if (average <= 0) return null;

    final dates = map((p) => p.recordedAt).toList()..sort();
    final windowDays = dates.last.difference(dates.first).inDays;

    final percent = (currentPrice - average) / average * 100;
    final standing = switch (currentPrice) {
      _ when currentPrice <= lowest * (1 + _epsilon) => PriceStanding.lowest,
      _ when currentPrice >= highest * (1 - _epsilon) => PriceStanding.highest,
      _ when percent <= -_typicalBand => PriceStanding.below,
      _ when percent >= _typicalBand => PriceStanding.above,
      _ => PriceStanding.typical,
    };

    return PriceVerdict(
      standing: standing,
      current: currentPrice,
      lowest: lowest,
      average: average,
      highest: highest,
      windowDays: windowDays == 0 ? 1 : windowDays,
    );
  }
}
