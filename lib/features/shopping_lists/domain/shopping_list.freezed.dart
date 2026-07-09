// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShoppingList {

 String get id; String get userId; String get name;/// Optional spending cap for this trip.
 double? get budget; List<ShoppingItem> get items; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of ShoppingList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingListCopyWith<ShoppingList> get copyWith => _$ShoppingListCopyWithImpl<ShoppingList>(this as ShoppingList, _$identity);

  /// Serializes this ShoppingList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingList&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,budget,const DeepCollectionEquality().hash(items),createdAt,updatedAt);

@override
String toString() {
  return 'ShoppingList(id: $id, userId: $userId, name: $name, budget: $budget, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ShoppingListCopyWith<$Res>  {
  factory $ShoppingListCopyWith(ShoppingList value, $Res Function(ShoppingList) _then) = _$ShoppingListCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, double? budget, List<ShoppingItem> items, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ShoppingListCopyWithImpl<$Res>
    implements $ShoppingListCopyWith<$Res> {
  _$ShoppingListCopyWithImpl(this._self, this._then);

  final ShoppingList _self;
  final $Res Function(ShoppingList) _then;

/// Create a copy of ShoppingList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? budget = freezed,Object? items = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ShoppingItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingList].
extension ShoppingListPatterns on ShoppingList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingList value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingList value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  double? budget,  List<ShoppingItem> items,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingList() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.budget,_that.items,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  double? budget,  List<ShoppingItem> items,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ShoppingList():
return $default(_that.id,_that.userId,_that.name,_that.budget,_that.items,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  double? budget,  List<ShoppingItem> items,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingList() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.budget,_that.items,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShoppingList extends ShoppingList {
  const _ShoppingList({required this.id, required this.userId, required this.name, this.budget, final  List<ShoppingItem> items = const <ShoppingItem>[], required this.createdAt, this.updatedAt}): _items = items,super._();
  factory _ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
/// Optional spending cap for this trip.
@override final  double? budget;
 final  List<ShoppingItem> _items;
@override@JsonKey() List<ShoppingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ShoppingList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingListCopyWith<_ShoppingList> get copyWith => __$ShoppingListCopyWithImpl<_ShoppingList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShoppingListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingList&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,budget,const DeepCollectionEquality().hash(_items),createdAt,updatedAt);

@override
String toString() {
  return 'ShoppingList(id: $id, userId: $userId, name: $name, budget: $budget, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ShoppingListCopyWith<$Res> implements $ShoppingListCopyWith<$Res> {
  factory _$ShoppingListCopyWith(_ShoppingList value, $Res Function(_ShoppingList) _then) = __$ShoppingListCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, double? budget, List<ShoppingItem> items, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ShoppingListCopyWithImpl<$Res>
    implements _$ShoppingListCopyWith<$Res> {
  __$ShoppingListCopyWithImpl(this._self, this._then);

  final _ShoppingList _self;
  final $Res Function(_ShoppingList) _then;

/// Create a copy of ShoppingList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? budget = freezed,Object? items = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_ShoppingList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ShoppingItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ShoppingItem {

 String get id; String get listId;/// Linked catalog product when known; free-text items have null.
 String? get productId; String get name; double get quantity; String get unit; bool get checked; String? get notes;/// Estimated price used before optimization resolves real prices.
 double? get estimatedPrice;
/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingItemCopyWith<ShoppingItem> get copyWith => _$ShoppingItemCopyWithImpl<ShoppingItem>(this as ShoppingItem, _$identity);

  /// Serializes this ShoppingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.estimatedPrice, estimatedPrice) || other.estimatedPrice == estimatedPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listId,productId,name,quantity,unit,checked,notes,estimatedPrice);

@override
String toString() {
  return 'ShoppingItem(id: $id, listId: $listId, productId: $productId, name: $name, quantity: $quantity, unit: $unit, checked: $checked, notes: $notes, estimatedPrice: $estimatedPrice)';
}


}

/// @nodoc
abstract mixin class $ShoppingItemCopyWith<$Res>  {
  factory $ShoppingItemCopyWith(ShoppingItem value, $Res Function(ShoppingItem) _then) = _$ShoppingItemCopyWithImpl;
@useResult
$Res call({
 String id, String listId, String? productId, String name, double quantity, String unit, bool checked, String? notes, double? estimatedPrice
});




}
/// @nodoc
class _$ShoppingItemCopyWithImpl<$Res>
    implements $ShoppingItemCopyWith<$Res> {
  _$ShoppingItemCopyWithImpl(this._self, this._then);

  final ShoppingItem _self;
  final $Res Function(ShoppingItem) _then;

/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listId = null,Object? productId = freezed,Object? name = null,Object? quantity = null,Object? unit = null,Object? checked = null,Object? notes = freezed,Object? estimatedPrice = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,checked: null == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,estimatedPrice: freezed == estimatedPrice ? _self.estimatedPrice : estimatedPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingItem].
extension ShoppingItemPatterns on ShoppingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingItem value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingItem value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String listId,  String? productId,  String name,  double quantity,  String unit,  bool checked,  String? notes,  double? estimatedPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
return $default(_that.id,_that.listId,_that.productId,_that.name,_that.quantity,_that.unit,_that.checked,_that.notes,_that.estimatedPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String listId,  String? productId,  String name,  double quantity,  String unit,  bool checked,  String? notes,  double? estimatedPrice)  $default,) {final _that = this;
switch (_that) {
case _ShoppingItem():
return $default(_that.id,_that.listId,_that.productId,_that.name,_that.quantity,_that.unit,_that.checked,_that.notes,_that.estimatedPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String listId,  String? productId,  String name,  double quantity,  String unit,  bool checked,  String? notes,  double? estimatedPrice)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
return $default(_that.id,_that.listId,_that.productId,_that.name,_that.quantity,_that.unit,_that.checked,_that.notes,_that.estimatedPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShoppingItem implements ShoppingItem {
  const _ShoppingItem({required this.id, required this.listId, this.productId, required this.name, this.quantity = 1.0, this.unit = 'ea', this.checked = false, this.notes, this.estimatedPrice});
  factory _ShoppingItem.fromJson(Map<String, dynamic> json) => _$ShoppingItemFromJson(json);

@override final  String id;
@override final  String listId;
/// Linked catalog product when known; free-text items have null.
@override final  String? productId;
@override final  String name;
@override@JsonKey() final  double quantity;
@override@JsonKey() final  String unit;
@override@JsonKey() final  bool checked;
@override final  String? notes;
/// Estimated price used before optimization resolves real prices.
@override final  double? estimatedPrice;

/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingItemCopyWith<_ShoppingItem> get copyWith => __$ShoppingItemCopyWithImpl<_ShoppingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShoppingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.estimatedPrice, estimatedPrice) || other.estimatedPrice == estimatedPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listId,productId,name,quantity,unit,checked,notes,estimatedPrice);

@override
String toString() {
  return 'ShoppingItem(id: $id, listId: $listId, productId: $productId, name: $name, quantity: $quantity, unit: $unit, checked: $checked, notes: $notes, estimatedPrice: $estimatedPrice)';
}


}

/// @nodoc
abstract mixin class _$ShoppingItemCopyWith<$Res> implements $ShoppingItemCopyWith<$Res> {
  factory _$ShoppingItemCopyWith(_ShoppingItem value, $Res Function(_ShoppingItem) _then) = __$ShoppingItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String listId, String? productId, String name, double quantity, String unit, bool checked, String? notes, double? estimatedPrice
});




}
/// @nodoc
class __$ShoppingItemCopyWithImpl<$Res>
    implements _$ShoppingItemCopyWith<$Res> {
  __$ShoppingItemCopyWithImpl(this._self, this._then);

  final _ShoppingItem _self;
  final $Res Function(_ShoppingItem) _then;

/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listId = null,Object? productId = freezed,Object? name = null,Object? quantity = null,Object? unit = null,Object? checked = null,Object? notes = freezed,Object? estimatedPrice = freezed,}) {
  return _then(_ShoppingItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,checked: null == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,estimatedPrice: freezed == estimatedPrice ? _self.estimatedPrice : estimatedPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
