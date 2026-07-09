import 'coupon.dart';

abstract interface class CouponRepository {
  /// All non-expired coupons, including clip state for the current user.
  Future<List<Coupon>> available();

  Future<void> setClipped(String couponId, bool clipped);
}
