// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Offer _$OfferFromJson(Map<String, dynamic> json) => _Offer(
  id: json['id'] as String,
  storeId: json['store_id'] as String,
  productId: json['product_id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  type:
      $enumDecodeNullable(_$OfferTypeEnumMap, json['type']) ??
      OfferType.discount,
  discountPercent: (json['discount_percent'] as num?)?.toDouble(),
  discountAmount: (json['discount_amount'] as num?)?.toDouble(),
  validFrom: json['valid_from'] == null
      ? null
      : DateTime.parse(json['valid_from'] as String),
  validTo: DateTime.parse(json['valid_to'] as String),
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$OfferToJson(_Offer instance) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'product_id': instance.productId,
  'title': instance.title,
  'description': instance.description,
  'type': _$OfferTypeEnumMap[instance.type]!,
  'discount_percent': instance.discountPercent,
  'discount_amount': instance.discountAmount,
  'valid_from': instance.validFrom?.toIso8601String(),
  'valid_to': instance.validTo.toIso8601String(),
  'image_url': instance.imageUrl,
};

const _$OfferTypeEnumMap = {
  OfferType.weeklyAd: 'weeklyAd',
  OfferType.discount: 'discount',
  OfferType.bogo: 'bogo',
  OfferType.cashback: 'cashback',
  OfferType.loyalty: 'loyalty',
};
