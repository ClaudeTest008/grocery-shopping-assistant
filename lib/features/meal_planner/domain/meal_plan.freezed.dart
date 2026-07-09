// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealPlan {

 String get id; String get userId;/// Monday of the plan week.
 DateTime get weekStart; List<PlannedMeal> get meals; DateTime? get createdAt;
/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanCopyWith<MealPlan> get copyWith => _$MealPlanCopyWithImpl<MealPlan>(this as MealPlan, _$identity);

  /// Serializes this MealPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&const DeepCollectionEquality().equals(other.meals, meals)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,weekStart,const DeepCollectionEquality().hash(meals),createdAt);

@override
String toString() {
  return 'MealPlan(id: $id, userId: $userId, weekStart: $weekStart, meals: $meals, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MealPlanCopyWith<$Res>  {
  factory $MealPlanCopyWith(MealPlan value, $Res Function(MealPlan) _then) = _$MealPlanCopyWithImpl;
@useResult
$Res call({
 String id, String userId, DateTime weekStart, List<PlannedMeal> meals, DateTime? createdAt
});




}
/// @nodoc
class _$MealPlanCopyWithImpl<$Res>
    implements $MealPlanCopyWith<$Res> {
  _$MealPlanCopyWithImpl(this._self, this._then);

  final MealPlan _self;
  final $Res Function(MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? weekStart = null,Object? meals = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,meals: null == meals ? _self.meals : meals // ignore: cast_nullable_to_non_nullable
as List<PlannedMeal>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MealPlan].
extension MealPlanPatterns on MealPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealPlan value)  $default,){
final _that = this;
switch (_that) {
case _MealPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealPlan value)?  $default,){
final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  DateTime weekStart,  List<PlannedMeal> meals,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
return $default(_that.id,_that.userId,_that.weekStart,_that.meals,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  DateTime weekStart,  List<PlannedMeal> meals,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MealPlan():
return $default(_that.id,_that.userId,_that.weekStart,_that.meals,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  DateTime weekStart,  List<PlannedMeal> meals,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
return $default(_that.id,_that.userId,_that.weekStart,_that.meals,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealPlan extends MealPlan {
  const _MealPlan({required this.id, required this.userId, required this.weekStart, final  List<PlannedMeal> meals = const <PlannedMeal>[], this.createdAt}): _meals = meals,super._();
  factory _MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);

@override final  String id;
@override final  String userId;
/// Monday of the plan week.
@override final  DateTime weekStart;
 final  List<PlannedMeal> _meals;
@override@JsonKey() List<PlannedMeal> get meals {
  if (_meals is EqualUnmodifiableListView) return _meals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meals);
}

@override final  DateTime? createdAt;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealPlanCopyWith<_MealPlan> get copyWith => __$MealPlanCopyWithImpl<_MealPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&const DeepCollectionEquality().equals(other._meals, _meals)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,weekStart,const DeepCollectionEquality().hash(_meals),createdAt);

@override
String toString() {
  return 'MealPlan(id: $id, userId: $userId, weekStart: $weekStart, meals: $meals, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MealPlanCopyWith<$Res> implements $MealPlanCopyWith<$Res> {
  factory _$MealPlanCopyWith(_MealPlan value, $Res Function(_MealPlan) _then) = __$MealPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, DateTime weekStart, List<PlannedMeal> meals, DateTime? createdAt
});




}
/// @nodoc
class __$MealPlanCopyWithImpl<$Res>
    implements _$MealPlanCopyWith<$Res> {
  __$MealPlanCopyWithImpl(this._self, this._then);

  final _MealPlan _self;
  final $Res Function(_MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? weekStart = null,Object? meals = null,Object? createdAt = freezed,}) {
  return _then(_MealPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,meals: null == meals ? _self._meals : meals // ignore: cast_nullable_to_non_nullable
as List<PlannedMeal>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PlannedMeal {

/// Monday, Tuesday...
 String get day;/// breakfast, lunch, dinner.
 String get type; String get name; List<String> get ingredients;/// Ingredients already covered by the pantry.
 List<String> get usesPantry; double? get estimatedCost;
/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedMealCopyWith<PlannedMeal> get copyWith => _$PlannedMealCopyWithImpl<PlannedMeal>(this as PlannedMeal, _$identity);

  /// Serializes this PlannedMeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedMeal&&(identical(other.day, day) || other.day == day)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&const DeepCollectionEquality().equals(other.usesPantry, usesPantry)&&(identical(other.estimatedCost, estimatedCost) || other.estimatedCost == estimatedCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,type,name,const DeepCollectionEquality().hash(ingredients),const DeepCollectionEquality().hash(usesPantry),estimatedCost);

@override
String toString() {
  return 'PlannedMeal(day: $day, type: $type, name: $name, ingredients: $ingredients, usesPantry: $usesPantry, estimatedCost: $estimatedCost)';
}


}

/// @nodoc
abstract mixin class $PlannedMealCopyWith<$Res>  {
  factory $PlannedMealCopyWith(PlannedMeal value, $Res Function(PlannedMeal) _then) = _$PlannedMealCopyWithImpl;
@useResult
$Res call({
 String day, String type, String name, List<String> ingredients, List<String> usesPantry, double? estimatedCost
});




}
/// @nodoc
class _$PlannedMealCopyWithImpl<$Res>
    implements $PlannedMealCopyWith<$Res> {
  _$PlannedMealCopyWithImpl(this._self, this._then);

  final PlannedMeal _self;
  final $Res Function(PlannedMeal) _then;

/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? type = null,Object? name = null,Object? ingredients = null,Object? usesPantry = null,Object? estimatedCost = freezed,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,usesPantry: null == usesPantry ? _self.usesPantry : usesPantry // ignore: cast_nullable_to_non_nullable
as List<String>,estimatedCost: freezed == estimatedCost ? _self.estimatedCost : estimatedCost // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlannedMeal].
extension PlannedMealPatterns on PlannedMeal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannedMeal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannedMeal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannedMeal value)  $default,){
final _that = this;
switch (_that) {
case _PlannedMeal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannedMeal value)?  $default,){
final _that = this;
switch (_that) {
case _PlannedMeal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  String type,  String name,  List<String> ingredients,  List<String> usesPantry,  double? estimatedCost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedMeal() when $default != null:
return $default(_that.day,_that.type,_that.name,_that.ingredients,_that.usesPantry,_that.estimatedCost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  String type,  String name,  List<String> ingredients,  List<String> usesPantry,  double? estimatedCost)  $default,) {final _that = this;
switch (_that) {
case _PlannedMeal():
return $default(_that.day,_that.type,_that.name,_that.ingredients,_that.usesPantry,_that.estimatedCost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  String type,  String name,  List<String> ingredients,  List<String> usesPantry,  double? estimatedCost)?  $default,) {final _that = this;
switch (_that) {
case _PlannedMeal() when $default != null:
return $default(_that.day,_that.type,_that.name,_that.ingredients,_that.usesPantry,_that.estimatedCost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlannedMeal implements PlannedMeal {
  const _PlannedMeal({required this.day, this.type = 'dinner', required this.name, final  List<String> ingredients = const <String>[], final  List<String> usesPantry = const <String>[], this.estimatedCost}): _ingredients = ingredients,_usesPantry = usesPantry;
  factory _PlannedMeal.fromJson(Map<String, dynamic> json) => _$PlannedMealFromJson(json);

/// Monday, Tuesday...
@override final  String day;
/// breakfast, lunch, dinner.
@override@JsonKey() final  String type;
@override final  String name;
 final  List<String> _ingredients;
@override@JsonKey() List<String> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

/// Ingredients already covered by the pantry.
 final  List<String> _usesPantry;
/// Ingredients already covered by the pantry.
@override@JsonKey() List<String> get usesPantry {
  if (_usesPantry is EqualUnmodifiableListView) return _usesPantry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usesPantry);
}

@override final  double? estimatedCost;

/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedMealCopyWith<_PlannedMeal> get copyWith => __$PlannedMealCopyWithImpl<_PlannedMeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlannedMealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedMeal&&(identical(other.day, day) || other.day == day)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&const DeepCollectionEquality().equals(other._usesPantry, _usesPantry)&&(identical(other.estimatedCost, estimatedCost) || other.estimatedCost == estimatedCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,type,name,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_usesPantry),estimatedCost);

@override
String toString() {
  return 'PlannedMeal(day: $day, type: $type, name: $name, ingredients: $ingredients, usesPantry: $usesPantry, estimatedCost: $estimatedCost)';
}


}

/// @nodoc
abstract mixin class _$PlannedMealCopyWith<$Res> implements $PlannedMealCopyWith<$Res> {
  factory _$PlannedMealCopyWith(_PlannedMeal value, $Res Function(_PlannedMeal) _then) = __$PlannedMealCopyWithImpl;
@override @useResult
$Res call({
 String day, String type, String name, List<String> ingredients, List<String> usesPantry, double? estimatedCost
});




}
/// @nodoc
class __$PlannedMealCopyWithImpl<$Res>
    implements _$PlannedMealCopyWith<$Res> {
  __$PlannedMealCopyWithImpl(this._self, this._then);

  final _PlannedMeal _self;
  final $Res Function(_PlannedMeal) _then;

/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? type = null,Object? name = null,Object? ingredients = null,Object? usesPantry = null,Object? estimatedCost = freezed,}) {
  return _then(_PlannedMeal(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,usesPantry: null == usesPantry ? _self._usesPantry : usesPantry // ignore: cast_nullable_to_non_nullable
as List<String>,estimatedCost: freezed == estimatedCost ? _self.estimatedCost : estimatedCost // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
