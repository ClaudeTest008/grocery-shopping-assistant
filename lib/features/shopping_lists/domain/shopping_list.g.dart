// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) =>
    _ShoppingList(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      budget: (json['budget'] as num?)?.toDouble(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ShoppingItem>[],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ShoppingListToJson(_ShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'budget': instance.budget,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) =>
    _ShoppingItem(
      id: json['id'] as String,
      listId: json['list_id'] as String,
      productId: json['product_id'] as String?,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'ea',
      checked: json['checked'] as bool? ?? false,
      notes: json['notes'] as String?,
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ShoppingItemToJson(_ShoppingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'list_id': instance.listId,
      'product_id': instance.productId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'checked': instance.checked,
      'notes': instance.notes,
      'estimated_price': instance.estimatedPrice,
    };
