import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon.freezed.dart';
part 'coupon.g.dart';

@freezed
abstract class Coupon with _$Coupon {
  const Coupon._();

  const factory Coupon({
    required String id,

    /// Null = valid at any store.
    String? storeId,

    /// Null = order-level coupon.
    String? productId,
    required String title,
    String? code,
    String? description,

    /// Exactly one of amount / percent is set.
    double? discountAmount,
    double? discountPercent,

    /// Minimum basket value to apply.
    double? minSpend,
    required DateTime expiresAt,
    @Default(true) bool isDigital,

    /// User has added it to their wallet.
    @Default(false) bool clipped,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get expiresSoon =>
      !isExpired && expiresAt.difference(DateTime.now()).inDays <= 3;

  /// Discount this coupon yields on [price] (single item application).
  double valueOn(double price) {
    if (isExpired) return 0;
    if (discountAmount != null) return discountAmount!.clamp(0, price);
    if (discountPercent != null) return price * discountPercent! / 100;
    return 0;
  }
}
