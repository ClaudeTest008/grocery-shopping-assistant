// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_observation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceObservation {

 String get id; String get productId;/// Null when the receipt or report didn't identify the store.
 String? get storeId; double get price;/// 'receipt' (parsed from a scanned receipt) or 'community'
/// (typed in via "Report a price").
 String get source; DateTime get observedAt;
/// Create a copy of PriceObservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceObservationCopyWith<PriceObservation> get copyWith => _$PriceObservationCopyWithImpl<PriceObservation>(this as PriceObservation, _$identity);

  /// Serializes this PriceObservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceObservation&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.price, price) || other.price == price)&&(identical(other.source, source) || other.source == source)&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,storeId,price,source,observedAt);

@override
String toString() {
  return 'PriceObservation(id: $id, productId: $productId, storeId: $storeId, price: $price, source: $source, observedAt: $observedAt)';
}


}

/// @nodoc
abstract mixin class $PriceObservationCopyWith<$Res>  {
  factory $PriceObservationCopyWith(PriceObservation value, $Res Function(PriceObservation) _then) = _$PriceObservationCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String? storeId, double price, String source, DateTime observedAt
});




}
/// @nodoc
class _$PriceObservationCopyWithImpl<$Res>
    implements $PriceObservationCopyWith<$Res> {
  _$PriceObservationCopyWithImpl(this._self, this._then);

  final PriceObservation _self;
  final $Res Function(PriceObservation) _then;

/// Create a copy of PriceObservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? storeId = freezed,Object? price = null,Object? source = null,Object? observedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,observedAt: null == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceObservation].
extension PriceObservationPatterns on PriceObservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceObservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceObservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceObservation value)  $default,){
final _that = this;
switch (_that) {
case _PriceObservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceObservation value)?  $default,){
final _that = this;
switch (_that) {
case _PriceObservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String? storeId,  double price,  String source,  DateTime observedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceObservation() when $default != null:
return $default(_that.id,_that.productId,_that.storeId,_that.price,_that.source,_that.observedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String? storeId,  double price,  String source,  DateTime observedAt)  $default,) {final _that = this;
switch (_that) {
case _PriceObservation():
return $default(_that.id,_that.productId,_that.storeId,_that.price,_that.source,_that.observedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String? storeId,  double price,  String source,  DateTime observedAt)?  $default,) {final _that = this;
switch (_that) {
case _PriceObservation() when $default != null:
return $default(_that.id,_that.productId,_that.storeId,_that.price,_that.source,_that.observedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceObservation implements PriceObservation {
  const _PriceObservation({required this.id, required this.productId, this.storeId, required this.price, required this.source, required this.observedAt});
  factory _PriceObservation.fromJson(Map<String, dynamic> json) => _$PriceObservationFromJson(json);

@override final  String id;
@override final  String productId;
/// Null when the receipt or report didn't identify the store.
@override final  String? storeId;
@override final  double price;
/// 'receipt' (parsed from a scanned receipt) or 'community'
/// (typed in via "Report a price").
@override final  String source;
@override final  DateTime observedAt;

/// Create a copy of PriceObservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceObservationCopyWith<_PriceObservation> get copyWith => __$PriceObservationCopyWithImpl<_PriceObservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceObservationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceObservation&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.price, price) || other.price == price)&&(identical(other.source, source) || other.source == source)&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,storeId,price,source,observedAt);

@override
String toString() {
  return 'PriceObservation(id: $id, productId: $productId, storeId: $storeId, price: $price, source: $source, observedAt: $observedAt)';
}


}

/// @nodoc
abstract mixin class _$PriceObservationCopyWith<$Res> implements $PriceObservationCopyWith<$Res> {
  factory _$PriceObservationCopyWith(_PriceObservation value, $Res Function(_PriceObservation) _then) = __$PriceObservationCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String? storeId, double price, String source, DateTime observedAt
});




}
/// @nodoc
class __$PriceObservationCopyWithImpl<$Res>
    implements _$PriceObservationCopyWith<$Res> {
  __$PriceObservationCopyWithImpl(this._self, this._then);

  final _PriceObservation _self;
  final $Res Function(_PriceObservation) _then;

/// Create a copy of PriceObservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? storeId = freezed,Object? price = null,Object? source = null,Object? observedAt = null,}) {
  return _then(_PriceObservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,observedAt: null == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
