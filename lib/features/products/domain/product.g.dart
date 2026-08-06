// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String?,
  barcode: json['barcode'] as String?,
  barcodes: (json['barcodes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  countries: (json['countries'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  category: json['category'] as String,
  unit: json['unit'] as String? ?? 'ea',
  unitSize: (json['unit_size'] as num?)?.toDouble() ?? 1.0,
  imageUrl: json['image_url'] as String?,
  nutrition: json['nutrition'] as Map<String, dynamic>?,
  allergens: (json['allergens'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ingredients: json['ingredients'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'brand': instance.brand,
  'barcode': instance.barcode,
  'barcodes': instance.barcodes,
  'countries': instance.countries,
  'category': instance.category,
  'unit': instance.unit,
  'unit_size': instance.unitSize,
  'image_url': instance.imageUrl,
  'nutrition': instance.nutrition,
  'allergens': instance.allergens,
  'ingredients': instance.ingredients,
  'tags': instance.tags,
};
