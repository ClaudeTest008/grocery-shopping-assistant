import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default('USD') String currency,

    /// metric | imperial
    @Default('imperial') String units,

    /// system | light | dark
    @Default('system') String themeMode,
    @Default(<String>[]) List<String> dietaryRestrictions,
    @Default(<String>[]) List<String> favoriteStoreIds,

    /// Monthly grocery budget.
    double? monthlyBudget,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool priceDropAlerts,
    @Default(true) bool couponExpiryAlerts,

    /// Basket optimizer: cost per km driven.
    @Default(0.12) double fuelCostPerKm,

    /// Minimum savings before a multi-store trip is recommended.
    @Default(2.0) double multiStoreThreshold,

    /// Accessibility: scale factor bump for large text.
    @Default(1.0) double textScale,
    @Default(false) bool highContrast,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
