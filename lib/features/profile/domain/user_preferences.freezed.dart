// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserPreferences {

 String get currency;/// metric | imperial
 String get units;/// system | light | dark
 String get themeMode; List<String> get dietaryRestrictions; List<String> get favoriteStoreIds;/// Monthly grocery budget.
 double? get monthlyBudget; bool get notificationsEnabled; bool get priceDropAlerts; bool get couponExpiryAlerts;/// Basket optimizer: cost per km driven.
 double get fuelCostPerKm;/// Minimum savings before a multi-store trip is recommended.
 double get multiStoreThreshold;/// Accessibility: scale factor bump for large text.
 double get textScale; bool get highContrast;
/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<UserPreferences> get copyWith => _$UserPreferencesCopyWithImpl<UserPreferences>(this as UserPreferences, _$identity);

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferences&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.units, units) || other.units == units)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&const DeepCollectionEquality().equals(other.dietaryRestrictions, dietaryRestrictions)&&const DeepCollectionEquality().equals(other.favoriteStoreIds, favoriteStoreIds)&&(identical(other.monthlyBudget, monthlyBudget) || other.monthlyBudget == monthlyBudget)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.priceDropAlerts, priceDropAlerts) || other.priceDropAlerts == priceDropAlerts)&&(identical(other.couponExpiryAlerts, couponExpiryAlerts) || other.couponExpiryAlerts == couponExpiryAlerts)&&(identical(other.fuelCostPerKm, fuelCostPerKm) || other.fuelCostPerKm == fuelCostPerKm)&&(identical(other.multiStoreThreshold, multiStoreThreshold) || other.multiStoreThreshold == multiStoreThreshold)&&(identical(other.textScale, textScale) || other.textScale == textScale)&&(identical(other.highContrast, highContrast) || other.highContrast == highContrast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,units,themeMode,const DeepCollectionEquality().hash(dietaryRestrictions),const DeepCollectionEquality().hash(favoriteStoreIds),monthlyBudget,notificationsEnabled,priceDropAlerts,couponExpiryAlerts,fuelCostPerKm,multiStoreThreshold,textScale,highContrast);

@override
String toString() {
  return 'UserPreferences(currency: $currency, units: $units, themeMode: $themeMode, dietaryRestrictions: $dietaryRestrictions, favoriteStoreIds: $favoriteStoreIds, monthlyBudget: $monthlyBudget, notificationsEnabled: $notificationsEnabled, priceDropAlerts: $priceDropAlerts, couponExpiryAlerts: $couponExpiryAlerts, fuelCostPerKm: $fuelCostPerKm, multiStoreThreshold: $multiStoreThreshold, textScale: $textScale, highContrast: $highContrast)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesCopyWith<$Res>  {
  factory $UserPreferencesCopyWith(UserPreferences value, $Res Function(UserPreferences) _then) = _$UserPreferencesCopyWithImpl;
@useResult
$Res call({
 String currency, String units, String themeMode, List<String> dietaryRestrictions, List<String> favoriteStoreIds, double? monthlyBudget, bool notificationsEnabled, bool priceDropAlerts, bool couponExpiryAlerts, double fuelCostPerKm, double multiStoreThreshold, double textScale, bool highContrast
});




}
/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._self, this._then);

  final UserPreferences _self;
  final $Res Function(UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? units = null,Object? themeMode = null,Object? dietaryRestrictions = null,Object? favoriteStoreIds = null,Object? monthlyBudget = freezed,Object? notificationsEnabled = null,Object? priceDropAlerts = null,Object? couponExpiryAlerts = null,Object? fuelCostPerKm = null,Object? multiStoreThreshold = null,Object? textScale = null,Object? highContrast = null,}) {
  return _then(_self.copyWith(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as String,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,dietaryRestrictions: null == dietaryRestrictions ? _self.dietaryRestrictions : dietaryRestrictions // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteStoreIds: null == favoriteStoreIds ? _self.favoriteStoreIds : favoriteStoreIds // ignore: cast_nullable_to_non_nullable
as List<String>,monthlyBudget: freezed == monthlyBudget ? _self.monthlyBudget : monthlyBudget // ignore: cast_nullable_to_non_nullable
as double?,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,priceDropAlerts: null == priceDropAlerts ? _self.priceDropAlerts : priceDropAlerts // ignore: cast_nullable_to_non_nullable
as bool,couponExpiryAlerts: null == couponExpiryAlerts ? _self.couponExpiryAlerts : couponExpiryAlerts // ignore: cast_nullable_to_non_nullable
as bool,fuelCostPerKm: null == fuelCostPerKm ? _self.fuelCostPerKm : fuelCostPerKm // ignore: cast_nullable_to_non_nullable
as double,multiStoreThreshold: null == multiStoreThreshold ? _self.multiStoreThreshold : multiStoreThreshold // ignore: cast_nullable_to_non_nullable
as double,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as double,highContrast: null == highContrast ? _self.highContrast : highContrast // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPreferences].
extension UserPreferencesPatterns on UserPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreferences value)  $default,){
final _that = this;
switch (_that) {
case _UserPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currency,  String units,  String themeMode,  List<String> dietaryRestrictions,  List<String> favoriteStoreIds,  double? monthlyBudget,  bool notificationsEnabled,  bool priceDropAlerts,  bool couponExpiryAlerts,  double fuelCostPerKm,  double multiStoreThreshold,  double textScale,  bool highContrast)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.currency,_that.units,_that.themeMode,_that.dietaryRestrictions,_that.favoriteStoreIds,_that.monthlyBudget,_that.notificationsEnabled,_that.priceDropAlerts,_that.couponExpiryAlerts,_that.fuelCostPerKm,_that.multiStoreThreshold,_that.textScale,_that.highContrast);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currency,  String units,  String themeMode,  List<String> dietaryRestrictions,  List<String> favoriteStoreIds,  double? monthlyBudget,  bool notificationsEnabled,  bool priceDropAlerts,  bool couponExpiryAlerts,  double fuelCostPerKm,  double multiStoreThreshold,  double textScale,  bool highContrast)  $default,) {final _that = this;
switch (_that) {
case _UserPreferences():
return $default(_that.currency,_that.units,_that.themeMode,_that.dietaryRestrictions,_that.favoriteStoreIds,_that.monthlyBudget,_that.notificationsEnabled,_that.priceDropAlerts,_that.couponExpiryAlerts,_that.fuelCostPerKm,_that.multiStoreThreshold,_that.textScale,_that.highContrast);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currency,  String units,  String themeMode,  List<String> dietaryRestrictions,  List<String> favoriteStoreIds,  double? monthlyBudget,  bool notificationsEnabled,  bool priceDropAlerts,  bool couponExpiryAlerts,  double fuelCostPerKm,  double multiStoreThreshold,  double textScale,  bool highContrast)?  $default,) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.currency,_that.units,_that.themeMode,_that.dietaryRestrictions,_that.favoriteStoreIds,_that.monthlyBudget,_that.notificationsEnabled,_that.priceDropAlerts,_that.couponExpiryAlerts,_that.fuelCostPerKm,_that.multiStoreThreshold,_that.textScale,_that.highContrast);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreferences implements UserPreferences {
  const _UserPreferences({this.currency = 'USD', this.units = 'imperial', this.themeMode = 'system', final  List<String> dietaryRestrictions = const <String>[], final  List<String> favoriteStoreIds = const <String>[], this.monthlyBudget, this.notificationsEnabled = true, this.priceDropAlerts = true, this.couponExpiryAlerts = true, this.fuelCostPerKm = 0.12, this.multiStoreThreshold = 2.0, this.textScale = 1.0, this.highContrast = false}): _dietaryRestrictions = dietaryRestrictions,_favoriteStoreIds = favoriteStoreIds;
  factory _UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);

@override@JsonKey() final  String currency;
/// metric | imperial
@override@JsonKey() final  String units;
/// system | light | dark
@override@JsonKey() final  String themeMode;
 final  List<String> _dietaryRestrictions;
@override@JsonKey() List<String> get dietaryRestrictions {
  if (_dietaryRestrictions is EqualUnmodifiableListView) return _dietaryRestrictions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryRestrictions);
}

 final  List<String> _favoriteStoreIds;
@override@JsonKey() List<String> get favoriteStoreIds {
  if (_favoriteStoreIds is EqualUnmodifiableListView) return _favoriteStoreIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteStoreIds);
}

/// Monthly grocery budget.
@override final  double? monthlyBudget;
@override@JsonKey() final  bool notificationsEnabled;
@override@JsonKey() final  bool priceDropAlerts;
@override@JsonKey() final  bool couponExpiryAlerts;
/// Basket optimizer: cost per km driven.
@override@JsonKey() final  double fuelCostPerKm;
/// Minimum savings before a multi-store trip is recommended.
@override@JsonKey() final  double multiStoreThreshold;
/// Accessibility: scale factor bump for large text.
@override@JsonKey() final  double textScale;
@override@JsonKey() final  bool highContrast;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesCopyWith<_UserPreferences> get copyWith => __$UserPreferencesCopyWithImpl<_UserPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferences&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.units, units) || other.units == units)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&const DeepCollectionEquality().equals(other._dietaryRestrictions, _dietaryRestrictions)&&const DeepCollectionEquality().equals(other._favoriteStoreIds, _favoriteStoreIds)&&(identical(other.monthlyBudget, monthlyBudget) || other.monthlyBudget == monthlyBudget)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.priceDropAlerts, priceDropAlerts) || other.priceDropAlerts == priceDropAlerts)&&(identical(other.couponExpiryAlerts, couponExpiryAlerts) || other.couponExpiryAlerts == couponExpiryAlerts)&&(identical(other.fuelCostPerKm, fuelCostPerKm) || other.fuelCostPerKm == fuelCostPerKm)&&(identical(other.multiStoreThreshold, multiStoreThreshold) || other.multiStoreThreshold == multiStoreThreshold)&&(identical(other.textScale, textScale) || other.textScale == textScale)&&(identical(other.highContrast, highContrast) || other.highContrast == highContrast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,units,themeMode,const DeepCollectionEquality().hash(_dietaryRestrictions),const DeepCollectionEquality().hash(_favoriteStoreIds),monthlyBudget,notificationsEnabled,priceDropAlerts,couponExpiryAlerts,fuelCostPerKm,multiStoreThreshold,textScale,highContrast);

@override
String toString() {
  return 'UserPreferences(currency: $currency, units: $units, themeMode: $themeMode, dietaryRestrictions: $dietaryRestrictions, favoriteStoreIds: $favoriteStoreIds, monthlyBudget: $monthlyBudget, notificationsEnabled: $notificationsEnabled, priceDropAlerts: $priceDropAlerts, couponExpiryAlerts: $couponExpiryAlerts, fuelCostPerKm: $fuelCostPerKm, multiStoreThreshold: $multiStoreThreshold, textScale: $textScale, highContrast: $highContrast)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesCopyWith<$Res> implements $UserPreferencesCopyWith<$Res> {
  factory _$UserPreferencesCopyWith(_UserPreferences value, $Res Function(_UserPreferences) _then) = __$UserPreferencesCopyWithImpl;
@override @useResult
$Res call({
 String currency, String units, String themeMode, List<String> dietaryRestrictions, List<String> favoriteStoreIds, double? monthlyBudget, bool notificationsEnabled, bool priceDropAlerts, bool couponExpiryAlerts, double fuelCostPerKm, double multiStoreThreshold, double textScale, bool highContrast
});




}
/// @nodoc
class __$UserPreferencesCopyWithImpl<$Res>
    implements _$UserPreferencesCopyWith<$Res> {
  __$UserPreferencesCopyWithImpl(this._self, this._then);

  final _UserPreferences _self;
  final $Res Function(_UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? units = null,Object? themeMode = null,Object? dietaryRestrictions = null,Object? favoriteStoreIds = null,Object? monthlyBudget = freezed,Object? notificationsEnabled = null,Object? priceDropAlerts = null,Object? couponExpiryAlerts = null,Object? fuelCostPerKm = null,Object? multiStoreThreshold = null,Object? textScale = null,Object? highContrast = null,}) {
  return _then(_UserPreferences(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as String,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,dietaryRestrictions: null == dietaryRestrictions ? _self._dietaryRestrictions : dietaryRestrictions // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteStoreIds: null == favoriteStoreIds ? _self._favoriteStoreIds : favoriteStoreIds // ignore: cast_nullable_to_non_nullable
as List<String>,monthlyBudget: freezed == monthlyBudget ? _self.monthlyBudget : monthlyBudget // ignore: cast_nullable_to_non_nullable
as double?,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,priceDropAlerts: null == priceDropAlerts ? _self.priceDropAlerts : priceDropAlerts // ignore: cast_nullable_to_non_nullable
as bool,couponExpiryAlerts: null == couponExpiryAlerts ? _self.couponExpiryAlerts : couponExpiryAlerts // ignore: cast_nullable_to_non_nullable
as bool,fuelCostPerKm: null == fuelCostPerKm ? _self.fuelCostPerKm : fuelCostPerKm // ignore: cast_nullable_to_non_nullable
as double,multiStoreThreshold: null == multiStoreThreshold ? _self.multiStoreThreshold : multiStoreThreshold // ignore: cast_nullable_to_non_nullable
as double,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as double,highContrast: null == highContrast ? _self.highContrast : highContrast // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
