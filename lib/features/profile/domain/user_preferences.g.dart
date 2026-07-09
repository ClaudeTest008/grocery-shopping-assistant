// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    _UserPreferences(
      currency: json['currency'] as String? ?? 'USD',
      units: json['units'] as String? ?? 'imperial',
      themeMode: json['theme_mode'] as String? ?? 'system',
      dietaryRestrictions:
          (json['dietary_restrictions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      favoriteStoreIds:
          (json['favorite_store_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble(),
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      priceDropAlerts: json['price_drop_alerts'] as bool? ?? true,
      couponExpiryAlerts: json['coupon_expiry_alerts'] as bool? ?? true,
      fuelCostPerKm: (json['fuel_cost_per_km'] as num?)?.toDouble() ?? 0.12,
      multiStoreThreshold:
          (json['multi_store_threshold'] as num?)?.toDouble() ?? 2.0,
      textScale: (json['text_scale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['high_contrast'] as bool? ?? false,
    );

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'units': instance.units,
      'theme_mode': instance.themeMode,
      'dietary_restrictions': instance.dietaryRestrictions,
      'favorite_store_ids': instance.favoriteStoreIds,
      'monthly_budget': instance.monthlyBudget,
      'notifications_enabled': instance.notificationsEnabled,
      'price_drop_alerts': instance.priceDropAlerts,
      'coupon_expiry_alerts': instance.couponExpiryAlerts,
      'fuel_cost_per_km': instance.fuelCostPerKm,
      'multi_store_threshold': instance.multiStoreThreshold,
      'text_scale': instance.textScale,
      'high_contrast': instance.highContrast,
    };
