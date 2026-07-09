import 'meal_plan.dart';

abstract interface class MealPlanRepository {
  /// Plan for the week containing [weekStart] (Monday), if any.
  Future<MealPlan?> forWeek(DateTime weekStart);

  Future<void> save(MealPlan plan);
}
