// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_observation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceObservation _$PriceObservationFromJson(Map<String, dynamic> json) =>
    _PriceObservation(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      storeId: json['store_id'] as String?,
      price: (json['price'] as num).toDouble(),
      source: json['source'] as String,
      observedAt: DateTime.parse(json['observed_at'] as String),
    );

Map<String, dynamic> _$PriceObservationToJson(_PriceObservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'store_id': instance.storeId,
      'price': instance.price,
      'source': instance.source,
      'observed_at': instance.observedAt.toIso8601String(),
    };
