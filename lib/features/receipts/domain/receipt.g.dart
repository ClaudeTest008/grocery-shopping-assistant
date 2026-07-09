// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Receipt _$ReceiptFromJson(Map<String, dynamic> json) => _Receipt(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  storeId: json['store_id'] as String?,
  storeName: json['store_name'] as String?,
  total: (json['total'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  purchasedAt: DateTime.parse(json['purchased_at'] as String),
  imageUrl: json['image_url'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ReceiptItem>[],
);

Map<String, dynamic> _$ReceiptToJson(_Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'store_id': instance.storeId,
  'store_name': instance.storeName,
  'total': instance.total,
  'currency': instance.currency,
  'purchased_at': instance.purchasedAt.toIso8601String(),
  'image_url': instance.imageUrl,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

_ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => _ReceiptItem(
  id: json['id'] as String,
  receiptId: json['receipt_id'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
  price: (json['price'] as num).toDouble(),
  category: json['category'] as String?,
);

Map<String, dynamic> _$ReceiptItemToJson(_ReceiptItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'receipt_id': instance.receiptId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
      'category': instance.category,
    };
