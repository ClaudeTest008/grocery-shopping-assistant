// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Coupon {

 String get id;/// Null = valid at any store.
 String? get storeId;/// Null = order-level coupon.
 String? get productId; String get title; String? get code; String? get description;/// Exactly one of amount / percent is set.
 double? get discountAmount; double? get discountPercent;/// Minimum basket value to apply.
 double? get minSpend; DateTime get expiresAt; bool get isDigital;/// User has added it to their wallet.
 bool get clipped;
/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponCopyWith<Coupon> get copyWith => _$CouponCopyWithImpl<Coupon>(this as Coupon, _$identity);

  /// Serializes this Coupon to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coupon&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.title, title) || other.title == title)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.minSpend, minSpend) || other.minSpend == minSpend)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isDigital, isDigital) || other.isDigital == isDigital)&&(identical(other.clipped, clipped) || other.clipped == clipped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,productId,title,code,description,discountAmount,discountPercent,minSpend,expiresAt,isDigital,clipped);

@override
String toString() {
  return 'Coupon(id: $id, storeId: $storeId, productId: $productId, title: $title, code: $code, description: $description, discountAmount: $discountAmount, discountPercent: $discountPercent, minSpend: $minSpend, expiresAt: $expiresAt, isDigital: $isDigital, clipped: $clipped)';
}


}

/// @nodoc
abstract mixin class $CouponCopyWith<$Res>  {
  factory $CouponCopyWith(Coupon value, $Res Function(Coupon) _then) = _$CouponCopyWithImpl;
@useResult
$Res call({
 String id, String? storeId, String? productId, String title, String? code, String? description, double? discountAmount, double? discountPercent, double? minSpend, DateTime expiresAt, bool isDigital, bool clipped
});




}
/// @nodoc
class _$CouponCopyWithImpl<$Res>
    implements $CouponCopyWith<$Res> {
  _$CouponCopyWithImpl(this._self, this._then);

  final Coupon _self;
  final $Res Function(Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? title = null,Object? code = freezed,Object? description = freezed,Object? discountAmount = freezed,Object? discountPercent = freezed,Object? minSpend = freezed,Object? expiresAt = null,Object? isDigital = null,Object? clipped = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,minSpend: freezed == minSpend ? _self.minSpend : minSpend // ignore: cast_nullable_to_non_nullable
as double?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDigital: null == isDigital ? _self.isDigital : isDigital // ignore: cast_nullable_to_non_nullable
as bool,clipped: null == clipped ? _self.clipped : clipped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Coupon].
extension CouponPatterns on Coupon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Coupon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Coupon value)  $default,){
final _that = this;
switch (_that) {
case _Coupon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Coupon value)?  $default,){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? storeId,  String? productId,  String title,  String? code,  String? description,  double? discountAmount,  double? discountPercent,  double? minSpend,  DateTime expiresAt,  bool isDigital,  bool clipped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.title,_that.code,_that.description,_that.discountAmount,_that.discountPercent,_that.minSpend,_that.expiresAt,_that.isDigital,_that.clipped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? storeId,  String? productId,  String title,  String? code,  String? description,  double? discountAmount,  double? discountPercent,  double? minSpend,  DateTime expiresAt,  bool isDigital,  bool clipped)  $default,) {final _that = this;
switch (_that) {
case _Coupon():
return $default(_that.id,_that.storeId,_that.productId,_that.title,_that.code,_that.description,_that.discountAmount,_that.discountPercent,_that.minSpend,_that.expiresAt,_that.isDigital,_that.clipped);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? storeId,  String? productId,  String title,  String? code,  String? description,  double? discountAmount,  double? discountPercent,  double? minSpend,  DateTime expiresAt,  bool isDigital,  bool clipped)?  $default,) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.id,_that.storeId,_that.productId,_that.title,_that.code,_that.description,_that.discountAmount,_that.discountPercent,_that.minSpend,_that.expiresAt,_that.isDigital,_that.clipped);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Coupon extends Coupon {
  const _Coupon({required this.id, this.storeId, this.productId, required this.title, this.code, this.description, this.discountAmount, this.discountPercent, this.minSpend, required this.expiresAt, this.isDigital = true, this.clipped = false}): super._();
  factory _Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

@override final  String id;
/// Null = valid at any store.
@override final  String? storeId;
/// Null = order-level coupon.
@override final  String? productId;
@override final  String title;
@override final  String? code;
@override final  String? description;
/// Exactly one of amount / percent is set.
@override final  double? discountAmount;
@override final  double? discountPercent;
/// Minimum basket value to apply.
@override final  double? minSpend;
@override final  DateTime expiresAt;
@override@JsonKey() final  bool isDigital;
/// User has added it to their wallet.
@override@JsonKey() final  bool clipped;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponCopyWith<_Coupon> get copyWith => __$CouponCopyWithImpl<_Coupon>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CouponToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coupon&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.title, title) || other.title == title)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.minSpend, minSpend) || other.minSpend == minSpend)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isDigital, isDigital) || other.isDigital == isDigital)&&(identical(other.clipped, clipped) || other.clipped == clipped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,productId,title,code,description,discountAmount,discountPercent,minSpend,expiresAt,isDigital,clipped);

@override
String toString() {
  return 'Coupon(id: $id, storeId: $storeId, productId: $productId, title: $title, code: $code, description: $description, discountAmount: $discountAmount, discountPercent: $discountPercent, minSpend: $minSpend, expiresAt: $expiresAt, isDigital: $isDigital, clipped: $clipped)';
}


}

/// @nodoc
abstract mixin class _$CouponCopyWith<$Res> implements $CouponCopyWith<$Res> {
  factory _$CouponCopyWith(_Coupon value, $Res Function(_Coupon) _then) = __$CouponCopyWithImpl;
@override @useResult
$Res call({
 String id, String? storeId, String? productId, String title, String? code, String? description, double? discountAmount, double? discountPercent, double? minSpend, DateTime expiresAt, bool isDigital, bool clipped
});




}
/// @nodoc
class __$CouponCopyWithImpl<$Res>
    implements _$CouponCopyWith<$Res> {
  __$CouponCopyWithImpl(this._self, this._then);

  final _Coupon _self;
  final $Res Function(_Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = freezed,Object? productId = freezed,Object? title = null,Object? code = freezed,Object? description = freezed,Object? discountAmount = freezed,Object? discountPercent = freezed,Object? minSpend = freezed,Object? expiresAt = null,Object? isDigital = null,Object? clipped = null,}) {
  return _then(_Coupon(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,minSpend: freezed == minSpend ? _self.minSpend : minSpend // ignore: cast_nullable_to_non_nullable
as double?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDigital: null == isDigital ? _self.isDigital : isDigital // ignore: cast_nullable_to_non_nullable
as bool,clipped: null == clipped ? _self.clipped : clipped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
