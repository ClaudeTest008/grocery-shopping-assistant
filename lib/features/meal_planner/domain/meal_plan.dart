import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_plan.freezed.dart';
part 'meal_plan.g.dart';

@freezed
abstract class MealPlan with _$MealPlan {
  const MealPlan._();

  const factory MealPlan({
    required String id,
    required String userId,

    /// Monday of the plan week.
    required DateTime weekStart,
    @Default(<PlannedMeal>[]) List<PlannedMeal> meals,
    DateTime? createdAt,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);

  double get estimatedCost =>
      meals.fold(0, (sum, m) => sum + (m.estimatedCost ?? 0));
}

@freezed
abstract class PlannedMeal with _$PlannedMeal {
  const factory PlannedMeal({
    /// Monday, Tuesday...
    required String day,

    /// breakfast, lunch, dinner.
    @Default('dinner') String type,
    required String name,
    @Default(<String>[]) List<String> ingredients,

    /// Ingredients already covered by the pantry.
    @Default(<String>[]) List<String> usesPantry,
    double? estimatedCost,
  }) = _PlannedMeal;

  factory PlannedMeal.fromJson(Map<String, dynamic> json) =>
      _$PlannedMealFromJson(json);
}
