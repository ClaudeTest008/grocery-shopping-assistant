// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => _MealPlan(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  weekStart: DateTime.parse(json['week_start'] as String),
  meals:
      (json['meals'] as List<dynamic>?)
          ?.map((e) => PlannedMeal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PlannedMeal>[],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MealPlanToJson(_MealPlan instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'week_start': instance.weekStart.toIso8601String(),
  'meals': instance.meals.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt?.toIso8601String(),
};

_PlannedMeal _$PlannedMealFromJson(Map<String, dynamic> json) => _PlannedMeal(
  day: json['day'] as String,
  type: json['type'] as String? ?? 'dinner',
  name: json['name'] as String,
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  usesPantry:
      (json['uses_pantry'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PlannedMealToJson(_PlannedMeal instance) =>
    <String, dynamic>{
      'day': instance.day,
      'type': instance.type,
      'name': instance.name,
      'ingredients': instance.ingredients,
      'uses_pantry': instance.usesPantry,
      'estimated_cost': instance.estimatedCost,
    };
