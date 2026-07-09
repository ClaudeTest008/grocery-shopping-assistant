import 'package:freezed_annotation/freezed_annotation.dart';

part 'price.freezed.dart';
part 'price.g.dart';

/// Current price of a product at a specific store.
@freezed
abstract class Price with _$Price {
  const Price._();

  const factory Price({
    required String id,
    required String productId,
    required String storeId,
    required double price,

    /// Price per base unit of the product (e.g. per oz), for honest
    /// comparison across package sizes.
    double? unitPrice,
    @Default('USD') String currency,

    /// Non-null when the price is promotional.
    double? regularPrice,
    DateTime? validFrom,
    DateTime? validTo,
    DateTime? updatedAt,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

  bool get isPromo => regularPrice != null && regularPrice! > price;

  double get savings => isPromo ? regularPrice! - price : 0;
}

/// One point in a product's price history at a store.
@freezed
abstract class PricePoint with _$PricePoint {
  const factory PricePoint({
    required DateTime recordedAt,
    required double price,
    String? storeId,
  }) = _PricePoint;

  factory PricePoint.fromJson(Map<String, dynamic> json) =>
      _$PricePointFromJson(json);
}
