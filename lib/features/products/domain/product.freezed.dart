// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id;/// Display name in the catalog's language — per-country demo seeds
/// (and per-country connected catalogs) localize at the data layer,
/// so business logic never branches on language.
 String get name; String? get brand; String? get barcode;/// Additional barcodes for the same product (regional EAN/UPC
/// variants); [barcode] stays the primary for compatibility.
 List<String>? get barcodes;/// ISO country codes where this product is sold; null = everywhere
/// (the shared demo catalog).
 List<String>? get countries; String get category;/// Base unit for unit-price comparison: oz, lb, ct, gal, l, kg...
 String get unit;/// Package size in [unit], e.g. 16 (oz).
 double get unitSize; String? get imageUrl;/// Per-serving nutrition facts, free-form keys (calories, protein_g...).
 Map<String, dynamic>? get nutrition;/// Dietary tags: vegan, gluten_free, organic...
 List<String> get tags;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&const DeepCollectionEquality().equals(other.barcodes, barcodes)&&const DeepCollectionEquality().equals(other.countries, countries)&&(identical(other.category, category) || other.category == category)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitSize, unitSize) || other.unitSize == unitSize)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.nutrition, nutrition)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,barcode,const DeepCollectionEquality().hash(barcodes),const DeepCollectionEquality().hash(countries),category,unit,unitSize,imageUrl,const DeepCollectionEquality().hash(nutrition),const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'Product(id: $id, name: $name, brand: $brand, barcode: $barcode, barcodes: $barcodes, countries: $countries, category: $category, unit: $unit, unitSize: $unitSize, imageUrl: $imageUrl, nutrition: $nutrition, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? brand, String? barcode, List<String>? barcodes, List<String>? countries, String category, String unit, double unitSize, String? imageUrl, Map<String, dynamic>? nutrition, List<String> tags
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = freezed,Object? barcode = freezed,Object? barcodes = freezed,Object? countries = freezed,Object? category = null,Object? unit = null,Object? unitSize = null,Object? imageUrl = freezed,Object? nutrition = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,barcodes: freezed == barcodes ? _self.barcodes : barcodes // ignore: cast_nullable_to_non_nullable
as List<String>?,countries: freezed == countries ? _self.countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitSize: null == unitSize ? _self.unitSize : unitSize // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,nutrition: freezed == nutrition ? _self.nutrition : nutrition // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? brand,  String? barcode,  List<String>? barcodes,  List<String>? countries,  String category,  String unit,  double unitSize,  String? imageUrl,  Map<String, dynamic>? nutrition,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.barcode,_that.barcodes,_that.countries,_that.category,_that.unit,_that.unitSize,_that.imageUrl,_that.nutrition,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? brand,  String? barcode,  List<String>? barcodes,  List<String>? countries,  String category,  String unit,  double unitSize,  String? imageUrl,  Map<String, dynamic>? nutrition,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.brand,_that.barcode,_that.barcodes,_that.countries,_that.category,_that.unit,_that.unitSize,_that.imageUrl,_that.nutrition,_that.tags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? brand,  String? barcode,  List<String>? barcodes,  List<String>? countries,  String category,  String unit,  double unitSize,  String? imageUrl,  Map<String, dynamic>? nutrition,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.barcode,_that.barcodes,_that.countries,_that.category,_that.unit,_that.unitSize,_that.imageUrl,_that.nutrition,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.name, this.brand, this.barcode, final  List<String>? barcodes, final  List<String>? countries, required this.category, this.unit = 'ea', this.unitSize = 1.0, this.imageUrl, final  Map<String, dynamic>? nutrition, final  List<String> tags = const <String>[]}): _barcodes = barcodes,_countries = countries,_nutrition = nutrition,_tags = tags;
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
/// Display name in the catalog's language — per-country demo seeds
/// (and per-country connected catalogs) localize at the data layer,
/// so business logic never branches on language.
@override final  String name;
@override final  String? brand;
@override final  String? barcode;
/// Additional barcodes for the same product (regional EAN/UPC
/// variants); [barcode] stays the primary for compatibility.
 final  List<String>? _barcodes;
/// Additional barcodes for the same product (regional EAN/UPC
/// variants); [barcode] stays the primary for compatibility.
@override List<String>? get barcodes {
  final value = _barcodes;
  if (value == null) return null;
  if (_barcodes is EqualUnmodifiableListView) return _barcodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// ISO country codes where this product is sold; null = everywhere
/// (the shared demo catalog).
 final  List<String>? _countries;
/// ISO country codes where this product is sold; null = everywhere
/// (the shared demo catalog).
@override List<String>? get countries {
  final value = _countries;
  if (value == null) return null;
  if (_countries is EqualUnmodifiableListView) return _countries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String category;
/// Base unit for unit-price comparison: oz, lb, ct, gal, l, kg...
@override@JsonKey() final  String unit;
/// Package size in [unit], e.g. 16 (oz).
@override@JsonKey() final  double unitSize;
@override final  String? imageUrl;
/// Per-serving nutrition facts, free-form keys (calories, protein_g...).
 final  Map<String, dynamic>? _nutrition;
/// Per-serving nutrition facts, free-form keys (calories, protein_g...).
@override Map<String, dynamic>? get nutrition {
  final value = _nutrition;
  if (value == null) return null;
  if (_nutrition is EqualUnmodifiableMapView) return _nutrition;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Dietary tags: vegan, gluten_free, organic...
 final  List<String> _tags;
/// Dietary tags: vegan, gluten_free, organic...
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&const DeepCollectionEquality().equals(other._barcodes, _barcodes)&&const DeepCollectionEquality().equals(other._countries, _countries)&&(identical(other.category, category) || other.category == category)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitSize, unitSize) || other.unitSize == unitSize)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._nutrition, _nutrition)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,barcode,const DeepCollectionEquality().hash(_barcodes),const DeepCollectionEquality().hash(_countries),category,unit,unitSize,imageUrl,const DeepCollectionEquality().hash(_nutrition),const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'Product(id: $id, name: $name, brand: $brand, barcode: $barcode, barcodes: $barcodes, countries: $countries, category: $category, unit: $unit, unitSize: $unitSize, imageUrl: $imageUrl, nutrition: $nutrition, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? brand, String? barcode, List<String>? barcodes, List<String>? countries, String category, String unit, double unitSize, String? imageUrl, Map<String, dynamic>? nutrition, List<String> tags
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = freezed,Object? barcode = freezed,Object? barcodes = freezed,Object? countries = freezed,Object? category = null,Object? unit = null,Object? unitSize = null,Object? imageUrl = freezed,Object? nutrition = freezed,Object? tags = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,barcodes: freezed == barcodes ? _self._barcodes : barcodes // ignore: cast_nullable_to_non_nullable
as List<String>?,countries: freezed == countries ? _self._countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitSize: null == unitSize ? _self.unitSize : unitSize // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,nutrition: freezed == nutrition ? _self._nutrition : nutrition // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
