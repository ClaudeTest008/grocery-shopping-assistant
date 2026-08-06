// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: json['id'] as String,
  name: json['name'] as String,
  chain: json['chain'] as String,
  address: json['address'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  country: json['country'] as String?,
  city: json['city'] as String?,
  logoUrl: json['logo_url'] as String?,
  phone: json['phone'] as String?,
  openingHours: (json['opening_hours'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'chain': instance.chain,
  'address': instance.address,
  'lat': instance.lat,
  'lng': instance.lng,
  'country': instance.country,
  'city': instance.city,
  'logo_url': instance.logoUrl,
  'phone': instance.phone,
  'opening_hours': instance.openingHours,
  'distance_km': instance.distanceKm,
};
