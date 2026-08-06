import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_observation.freezed.dart';
part 'price_observation.g.dart';

/// A real price a user actually saw — from a scanned receipt line or a
/// manual "report a price". This is the app's first-party live data:
/// unlike the seeded catalog it records observations, so it is honest by
/// construction. Kept separate from the curated catalog until reviewed;
/// the observer always sees their own observations immediately.
@freezed
abstract class PriceObservation with _$PriceObservation {
  const factory PriceObservation({
    required String id,
    required String productId,

    /// Null when the receipt or report didn't identify the store.
    String? storeId,
    required double price,

    /// 'receipt' (parsed from a scanned receipt) or 'community'
    /// (typed in via "Report a price").
    required String source,
    required DateTime observedAt,
  }) = _PriceObservation;

  factory PriceObservation.fromJson(Map<String, dynamic> json) =>
      _$PriceObservationFromJson(json);
}
