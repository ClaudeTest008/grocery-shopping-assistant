import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer.freezed.dart';
part 'offer.g.dart';

enum OfferType { weeklyAd, discount, bogo, cashback, loyalty }

@freezed
abstract class Offer with _$Offer {
  const Offer._();

  const factory Offer({
    required String id,
    required String storeId,
    String? productId,
    required String title,
    String? description,
    @Default(OfferType.discount) OfferType type,

    /// Percent off (0-100) when applicable.
    double? discountPercent,

    /// Absolute discount when applicable.
    double? discountAmount,
    DateTime? validFrom,
    required DateTime validTo,
    String? imageUrl,
  }) = _Offer;

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  bool get isActive {
    final now = DateTime.now();
    return (validFrom == null || now.isAfter(validFrom!)) &&
        now.isBefore(validTo);
  }

  bool get expiresSoon =>
      isActive && validTo.difference(DateTime.now()).inDays <= 2;
}
