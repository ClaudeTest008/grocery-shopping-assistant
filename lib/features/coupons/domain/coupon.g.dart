// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coupon _$CouponFromJson(Map<String, dynamic> json) => _Coupon(
  id: json['id'] as String,
  storeId: json['store_id'] as String?,
  productId: json['product_id'] as String?,
  title: json['title'] as String,
  code: json['code'] as String?,
  description: json['description'] as String?,
  discountAmount: (json['discount_amount'] as num?)?.toDouble(),
  discountPercent: (json['discount_percent'] as num?)?.toDouble(),
  minSpend: (json['min_spend'] as num?)?.toDouble(),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  isDigital: json['is_digital'] as bool? ?? true,
  clipped: json['clipped'] as bool? ?? false,
);

Map<String, dynamic> _$CouponToJson(_Coupon instance) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'product_id': instance.productId,
  'title': instance.title,
  'code': instance.code,
  'description': instance.description,
  'discount_amount': instance.discountAmount,
  'discount_percent': instance.discountPercent,
  'min_spend': instance.minSpend,
  'expires_at': instance.expiresAt.toIso8601String(),
  'is_digital': instance.isDigital,
  'clipped': instance.clipped,
};
