// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Price _$PriceFromJson(Map<String, dynamic> json) => _Price(
  id: json['id'] as String,
  productId: json['product_id'] as String,
  storeId: json['store_id'] as String,
  price: (json['price'] as num).toDouble(),
  unitPrice: (json['unit_price'] as num?)?.toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  regularPrice: (json['regular_price'] as num?)?.toDouble(),
  validFrom: json['valid_from'] == null
      ? null
      : DateTime.parse(json['valid_from'] as String),
  validTo: json['valid_to'] == null
      ? null
      : DateTime.parse(json['valid_to'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PriceToJson(_Price instance) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'store_id': instance.storeId,
  'price': instance.price,
  'unit_price': instance.unitPrice,
  'currency': instance.currency,
  'regular_price': instance.regularPrice,
  'valid_from': instance.validFrom?.toIso8601String(),
  'valid_to': instance.validTo?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_PricePoint _$PricePointFromJson(Map<String, dynamic> json) => _PricePoint(
  recordedAt: DateTime.parse(json['recorded_at'] as String),
  price: (json['price'] as num).toDouble(),
  storeId: json['store_id'] as String?,
);

Map<String, dynamic> _$PricePointToJson(_PricePoint instance) =>
    <String, dynamic>{
      'recorded_at': instance.recordedAt.toIso8601String(),
      'price': instance.price,
      'store_id': instance.storeId,
    };
