// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryItem _$PantryItemFromJson(Map<String, dynamic> json) => _PantryItem(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  productId: json['product_id'] as String?,
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
  unit: json['unit'] as String? ?? 'ea',
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  location: json['location'] as String? ?? 'pantry',
  addedAt: json['added_at'] == null
      ? null
      : DateTime.parse(json['added_at'] as String),
);

Map<String, dynamic> _$PantryItemToJson(_PantryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'product_id': instance.productId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'location': instance.location,
      'added_at': instance.addedAt?.toIso8601String(),
    };
