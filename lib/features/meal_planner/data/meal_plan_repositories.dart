import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_collection.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/meal_plan.dart';
import '../domain/meal_plan_repository.dart';

class DemoMealPlanRepository implements MealPlanRepository {
  DemoMealPlanRepository(LocalStore store)
    : _plans = DemoCollection(
        store,
        'demo_meal_plans',
        fromJson: MealPlan.fromJson,
        toJson: (p) => p.toJson(),
      );

  final DemoCollection<MealPlan> _plans;

  @override
  Future<MealPlan?> forWeek(DateTime weekStart) async => _plans
      .load()
      .where(
        (p) =>
            p.weekStart.year == weekStart.year &&
            p.weekStart.month == weekStart.month &&
            p.weekStart.day == weekStart.day,
      )
      .firstOrNull;

  @override
  Future<void> save(MealPlan plan) =>
      _plans.upsert(plan, (p) => p.id == plan.id);
}

class SupabaseMealPlanRepository implements MealPlanRepository {
  SupabaseMealPlanRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<MealPlan?> forWeek(DateTime weekStart) async {
    final row = await _client
        .from('meal_plans')
        .select()
        .eq('user_id', _userId)
        .eq('week_start', weekStart.toIso8601String().substring(0, 10))
        .maybeSingle();
    if (row == null) return null;
    // meals stored as jsonb column.
    final meals = (row['meals'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PlannedMeal.fromJson)
        .toList();
    row['meals'] = <dynamic>[];
    return MealPlan.fromJson(row).copyWith(meals: meals);
  }

  @override
  Future<void> save(MealPlan plan) => _client.from('meal_plans').upsert({
    'id': plan.id,
    'user_id': _userId,
    'week_start': plan.weekStart.toIso8601String().substring(0, 10),
    'meals': [for (final m in plan.meals) m.toJson()],
  });
}

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  if (AppConfig.isDemoMode) {
    return DemoMealPlanRepository(ref.watch(localStoreProvider));
  }
  return SupabaseMealPlanRepository(ref.watch(supabaseClientProvider));
});
