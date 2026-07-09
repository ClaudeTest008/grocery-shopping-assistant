// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Receipt {

 String get id; String get userId; String? get storeId; String? get storeName; double get total; String get currency; DateTime get purchasedAt; String? get imageUrl; List<ReceiptItem> get items;
/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptCopyWith<Receipt> get copyWith => _$ReceiptCopyWithImpl<Receipt>(this as Receipt, _$identity);

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,storeName,total,currency,purchasedAt,imageUrl,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Receipt(id: $id, userId: $userId, storeId: $storeId, storeName: $storeName, total: $total, currency: $currency, purchasedAt: $purchasedAt, imageUrl: $imageUrl, items: $items)';
}


}

/// @nodoc
abstract mixin class $ReceiptCopyWith<$Res>  {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) _then) = _$ReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? storeId, String? storeName, double total, String currency, DateTime purchasedAt, String? imageUrl, List<ReceiptItem> items
});




}
/// @nodoc
class _$ReceiptCopyWithImpl<$Res>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._self, this._then);

  final Receipt _self;
  final $Res Function(Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? storeId = freezed,Object? storeName = freezed,Object? total = null,Object? currency = null,Object? purchasedAt = null,Object? imageUrl = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,purchasedAt: null == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Receipt].
extension ReceiptPatterns on Receipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Receipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Receipt value)  $default,){
final _that = this;
switch (_that) {
case _Receipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Receipt value)?  $default,){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? storeId,  String? storeName,  double total,  String currency,  DateTime purchasedAt,  String? imageUrl,  List<ReceiptItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.storeName,_that.total,_that.currency,_that.purchasedAt,_that.imageUrl,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? storeId,  String? storeName,  double total,  String currency,  DateTime purchasedAt,  String? imageUrl,  List<ReceiptItem> items)  $default,) {final _that = this;
switch (_that) {
case _Receipt():
return $default(_that.id,_that.userId,_that.storeId,_that.storeName,_that.total,_that.currency,_that.purchasedAt,_that.imageUrl,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? storeId,  String? storeName,  double total,  String currency,  DateTime purchasedAt,  String? imageUrl,  List<ReceiptItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.storeName,_that.total,_that.currency,_that.purchasedAt,_that.imageUrl,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receipt implements Receipt {
  const _Receipt({required this.id, required this.userId, this.storeId, this.storeName, required this.total, this.currency = 'USD', required this.purchasedAt, this.imageUrl, final  List<ReceiptItem> items = const <ReceiptItem>[]}): _items = items;
  factory _Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? storeId;
@override final  String? storeName;
@override final  double total;
@override@JsonKey() final  String currency;
@override final  DateTime purchasedAt;
@override final  String? imageUrl;
 final  List<ReceiptItem> _items;
@override@JsonKey() List<ReceiptItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptCopyWith<_Receipt> get copyWith => __$ReceiptCopyWithImpl<_Receipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,storeName,total,currency,purchasedAt,imageUrl,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Receipt(id: $id, userId: $userId, storeId: $storeId, storeName: $storeName, total: $total, currency: $currency, purchasedAt: $purchasedAt, imageUrl: $imageUrl, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ReceiptCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$ReceiptCopyWith(_Receipt value, $Res Function(_Receipt) _then) = __$ReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? storeId, String? storeName, double total, String currency, DateTime purchasedAt, String? imageUrl, List<ReceiptItem> items
});




}
/// @nodoc
class __$ReceiptCopyWithImpl<$Res>
    implements _$ReceiptCopyWith<$Res> {
  __$ReceiptCopyWithImpl(this._self, this._then);

  final _Receipt _self;
  final $Res Function(_Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? storeId = freezed,Object? storeName = freezed,Object? total = null,Object? currency = null,Object? purchasedAt = null,Object? imageUrl = freezed,Object? items = null,}) {
  return _then(_Receipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,purchasedAt: null == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,
  ));
}


}


/// @nodoc
mixin _$ReceiptItem {

 String get id; String get receiptId; String get name; double get quantity; double get price; String? get category;
/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptItemCopyWith<ReceiptItem> get copyWith => _$ReceiptItemCopyWithImpl<ReceiptItem>(this as ReceiptItem, _$identity);

  /// Serializes this ReceiptItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptItem&&(identical(other.id, id) || other.id == id)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,receiptId,name,quantity,price,category);

@override
String toString() {
  return 'ReceiptItem(id: $id, receiptId: $receiptId, name: $name, quantity: $quantity, price: $price, category: $category)';
}


}

/// @nodoc
abstract mixin class $ReceiptItemCopyWith<$Res>  {
  factory $ReceiptItemCopyWith(ReceiptItem value, $Res Function(ReceiptItem) _then) = _$ReceiptItemCopyWithImpl;
@useResult
$Res call({
 String id, String receiptId, String name, double quantity, double price, String? category
});




}
/// @nodoc
class _$ReceiptItemCopyWithImpl<$Res>
    implements $ReceiptItemCopyWith<$Res> {
  _$ReceiptItemCopyWithImpl(this._self, this._then);

  final ReceiptItem _self;
  final $Res Function(ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? receiptId = null,Object? name = null,Object? quantity = null,Object? price = null,Object? category = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptItem].
extension ReceiptItemPatterns on ReceiptItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptItem value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String receiptId,  String name,  double quantity,  double price,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.id,_that.receiptId,_that.name,_that.quantity,_that.price,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String receiptId,  String name,  double quantity,  double price,  String? category)  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem():
return $default(_that.id,_that.receiptId,_that.name,_that.quantity,_that.price,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String receiptId,  String name,  double quantity,  double price,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.id,_that.receiptId,_that.name,_that.quantity,_that.price,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiptItem implements ReceiptItem {
  const _ReceiptItem({required this.id, required this.receiptId, required this.name, this.quantity = 1.0, required this.price, this.category});
  factory _ReceiptItem.fromJson(Map<String, dynamic> json) => _$ReceiptItemFromJson(json);

@override final  String id;
@override final  String receiptId;
@override final  String name;
@override@JsonKey() final  double quantity;
@override final  double price;
@override final  String? category;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptItemCopyWith<_ReceiptItem> get copyWith => __$ReceiptItemCopyWithImpl<_ReceiptItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptItem&&(identical(other.id, id) || other.id == id)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,receiptId,name,quantity,price,category);

@override
String toString() {
  return 'ReceiptItem(id: $id, receiptId: $receiptId, name: $name, quantity: $quantity, price: $price, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ReceiptItemCopyWith<$Res> implements $ReceiptItemCopyWith<$Res> {
  factory _$ReceiptItemCopyWith(_ReceiptItem value, $Res Function(_ReceiptItem) _then) = __$ReceiptItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String receiptId, String name, double quantity, double price, String? category
});




}
/// @nodoc
class __$ReceiptItemCopyWithImpl<$Res>
    implements _$ReceiptItemCopyWith<$Res> {
  __$ReceiptItemCopyWithImpl(this._self, this._then);

  final _ReceiptItem _self;
  final $Res Function(_ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? receiptId = null,Object? name = null,Object? quantity = null,Object? price = null,Object? category = freezed,}) {
  return _then(_ReceiptItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
