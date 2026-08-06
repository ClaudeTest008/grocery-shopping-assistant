// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Store {

 String get id; String get name;/// Chain identifier: mercadona, lidl, kroger... — meaningful only
/// within a country (Carrefour ES and Carrefour FR are separate
/// datasets that happen to share an id).
 String get chain; String get address; double get lat; double get lng;/// ISO 3166-1 alpha-2; null on rows created before countries existed
/// (treated as the legacy US dataset).
 String? get country; String? get city; String? get logoUrl; String? get phone;/// Weekday (1=Mon..7=Sun, as strings) -> "08:00-21:00" or "closed".
 Map<String, String>? get openingHours;/// Customer parking on site.
 bool? get hasParking;/// Step-free access; null = unknown, shown as such.
 bool? get wheelchairAccessible;/// In-store services: bakery, pharmacy, click_collect, fuel,
/// butcher, fish_counter... free-form data, rendered title-cased.
 List<String>? get services;/// Filled in client-side from user location; not persisted.
 double? get distanceKm;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.chain, chain) || other.chain == chain)&&(identical(other.address, address) || other.address == address)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other.openingHours, openingHours)&&(identical(other.hasParking, hasParking) || other.hasParking == hasParking)&&(identical(other.wheelchairAccessible, wheelchairAccessible) || other.wheelchairAccessible == wheelchairAccessible)&&const DeepCollectionEquality().equals(other.services, services)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,chain,address,lat,lng,country,city,logoUrl,phone,const DeepCollectionEquality().hash(openingHours),hasParking,wheelchairAccessible,const DeepCollectionEquality().hash(services),distanceKm);

@override
String toString() {
  return 'Store(id: $id, name: $name, chain: $chain, address: $address, lat: $lat, lng: $lng, country: $country, city: $city, logoUrl: $logoUrl, phone: $phone, openingHours: $openingHours, hasParking: $hasParking, wheelchairAccessible: $wheelchairAccessible, services: $services, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String id, String name, String chain, String address, double lat, double lng, String? country, String? city, String? logoUrl, String? phone, Map<String, String>? openingHours, bool? hasParking, bool? wheelchairAccessible, List<String>? services, double? distanceKm
});




}
/// @nodoc
class _$StoreCopyWithImpl<$Res>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._self, this._then);

  final Store _self;
  final $Res Function(Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? chain = null,Object? address = null,Object? lat = null,Object? lng = null,Object? country = freezed,Object? city = freezed,Object? logoUrl = freezed,Object? phone = freezed,Object? openingHours = freezed,Object? hasParking = freezed,Object? wheelchairAccessible = freezed,Object? services = freezed,Object? distanceKm = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,chain: null == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,hasParking: freezed == hasParking ? _self.hasParking : hasParking // ignore: cast_nullable_to_non_nullable
as bool?,wheelchairAccessible: freezed == wheelchairAccessible ? _self.wheelchairAccessible : wheelchairAccessible // ignore: cast_nullable_to_non_nullable
as bool?,services: freezed == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<String>?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Store].
extension StorePatterns on Store {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Store value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Store value)  $default,){
final _that = this;
switch (_that) {
case _Store():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Store value)?  $default,){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String chain,  String address,  double lat,  double lng,  String? country,  String? city,  String? logoUrl,  String? phone,  Map<String, String>? openingHours,  bool? hasParking,  bool? wheelchairAccessible,  List<String>? services,  double? distanceKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.chain,_that.address,_that.lat,_that.lng,_that.country,_that.city,_that.logoUrl,_that.phone,_that.openingHours,_that.hasParking,_that.wheelchairAccessible,_that.services,_that.distanceKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String chain,  String address,  double lat,  double lng,  String? country,  String? city,  String? logoUrl,  String? phone,  Map<String, String>? openingHours,  bool? hasParking,  bool? wheelchairAccessible,  List<String>? services,  double? distanceKm)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.id,_that.name,_that.chain,_that.address,_that.lat,_that.lng,_that.country,_that.city,_that.logoUrl,_that.phone,_that.openingHours,_that.hasParking,_that.wheelchairAccessible,_that.services,_that.distanceKm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String chain,  String address,  double lat,  double lng,  String? country,  String? city,  String? logoUrl,  String? phone,  Map<String, String>? openingHours,  bool? hasParking,  bool? wheelchairAccessible,  List<String>? services,  double? distanceKm)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.chain,_that.address,_that.lat,_that.lng,_that.country,_that.city,_that.logoUrl,_that.phone,_that.openingHours,_that.hasParking,_that.wheelchairAccessible,_that.services,_that.distanceKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Store extends Store {
  const _Store({required this.id, required this.name, required this.chain, required this.address, required this.lat, required this.lng, this.country, this.city, this.logoUrl, this.phone, final  Map<String, String>? openingHours, this.hasParking, this.wheelchairAccessible, final  List<String>? services, this.distanceKm}): _openingHours = openingHours,_services = services,super._();
  factory _Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

@override final  String id;
@override final  String name;
/// Chain identifier: mercadona, lidl, kroger... — meaningful only
/// within a country (Carrefour ES and Carrefour FR are separate
/// datasets that happen to share an id).
@override final  String chain;
@override final  String address;
@override final  double lat;
@override final  double lng;
/// ISO 3166-1 alpha-2; null on rows created before countries existed
/// (treated as the legacy US dataset).
@override final  String? country;
@override final  String? city;
@override final  String? logoUrl;
@override final  String? phone;
/// Weekday (1=Mon..7=Sun, as strings) -> "08:00-21:00" or "closed".
 final  Map<String, String>? _openingHours;
/// Weekday (1=Mon..7=Sun, as strings) -> "08:00-21:00" or "closed".
@override Map<String, String>? get openingHours {
  final value = _openingHours;
  if (value == null) return null;
  if (_openingHours is EqualUnmodifiableMapView) return _openingHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Customer parking on site.
@override final  bool? hasParking;
/// Step-free access; null = unknown, shown as such.
@override final  bool? wheelchairAccessible;
/// In-store services: bakery, pharmacy, click_collect, fuel,
/// butcher, fish_counter... free-form data, rendered title-cased.
 final  List<String>? _services;
/// In-store services: bakery, pharmacy, click_collect, fuel,
/// butcher, fish_counter... free-form data, rendered title-cased.
@override List<String>? get services {
  final value = _services;
  if (value == null) return null;
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Filled in client-side from user location; not persisted.
@override final  double? distanceKm;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.chain, chain) || other.chain == chain)&&(identical(other.address, address) || other.address == address)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other._openingHours, _openingHours)&&(identical(other.hasParking, hasParking) || other.hasParking == hasParking)&&(identical(other.wheelchairAccessible, wheelchairAccessible) || other.wheelchairAccessible == wheelchairAccessible)&&const DeepCollectionEquality().equals(other._services, _services)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,chain,address,lat,lng,country,city,logoUrl,phone,const DeepCollectionEquality().hash(_openingHours),hasParking,wheelchairAccessible,const DeepCollectionEquality().hash(_services),distanceKm);

@override
String toString() {
  return 'Store(id: $id, name: $name, chain: $chain, address: $address, lat: $lat, lng: $lng, country: $country, city: $city, logoUrl: $logoUrl, phone: $phone, openingHours: $openingHours, hasParking: $hasParking, wheelchairAccessible: $wheelchairAccessible, services: $services, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String chain, String address, double lat, double lng, String? country, String? city, String? logoUrl, String? phone, Map<String, String>? openingHours, bool? hasParking, bool? wheelchairAccessible, List<String>? services, double? distanceKm
});




}
/// @nodoc
class __$StoreCopyWithImpl<$Res>
    implements _$StoreCopyWith<$Res> {
  __$StoreCopyWithImpl(this._self, this._then);

  final _Store _self;
  final $Res Function(_Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? chain = null,Object? address = null,Object? lat = null,Object? lng = null,Object? country = freezed,Object? city = freezed,Object? logoUrl = freezed,Object? phone = freezed,Object? openingHours = freezed,Object? hasParking = freezed,Object? wheelchairAccessible = freezed,Object? services = freezed,Object? distanceKm = freezed,}) {
  return _then(_Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,chain: null == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self._openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,hasParking: freezed == hasParking ? _self.hasParking : hasParking // ignore: cast_nullable_to_non_nullable
as bool?,wheelchairAccessible: freezed == wheelchairAccessible ? _self.wheelchairAccessible : wheelchairAccessible // ignore: cast_nullable_to_non_nullable
as bool?,services: freezed == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<String>?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
