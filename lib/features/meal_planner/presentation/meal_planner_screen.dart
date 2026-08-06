import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/ai_services.dart';
import '../../../core/observability/telemetry.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../authentication/data/auth_repositories.dart';
import '../../pantry/data/pantry_repositories.dart';
import '../../profile/data/preferences_repository.dart';
import '../../shopping_lists/data/shopping_list_repositories.dart';
import '../../shopping_lists/domain/shopping_list.dart';
import '../data/meal_plan_repositories.dart';
import '../domain/meal_plan.dart';

DateTime _mondayOf(DateTime d) {
  final monday = d.subtract(Duration(days: d.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  late final DateTime _weekStart = _mondayOf(DateTime.now());
  MealPlan? _plan;
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final plan = await ref.read(mealPlanRepositoryProvider).forWeek(_weekStart);
    if (mounted) {
      setState(() {
        _plan = plan;
        _loading = false;
      });
    }
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final pantry = await ref.read(pantryRepositoryProvider).items();
      final prefs = ref.read(preferencesProvider);
      final user = ref.read(currentUserProvider);
      final weeklyBudget = prefs.monthlyBudget != null
          ? prefs.monthlyBudget! / 4
          : null;
      final plan = await ref
          .read(aiServicesProvider)
          .generateMealPlan(
            userId: user?.id ?? 'demo-user',
            weekStart: _weekStart,
            pantry: pantry,
            dietaryRestrictions: prefs.dietaryRestrictions,
            weeklyBudget: weeklyBudget,
          );
      await ref.read(mealPlanRepositoryProvider).save(plan);
      Telemetry.logEvent('meal_plan_generated', {
        'meals': plan.meals.length,
        'had_budget': weeklyBudget != null,
      });
      if (mounted) {
        setState(() {
          _plan = plan;
          _generating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _generating = false);
        context.showSnack('Could not generate a meal plan', error: true);
      }
    }
  }

  Future<void> _addMissingToList(PlannedMeal meal) async {
    final missing = meal.ingredients
        .where((i) => !meal.usesPantry.contains(i))
        .toList();
    if (missing.isEmpty) {
      context.showSnack('Pantry already covers this meal');
      return;
    }
    final repository = ref.read(shoppingListRepositoryProvider);
    final lists = await repository.lists();
    // ponytail: no list picker — first list, or auto-create one for the week.
    final list = lists.isNotEmpty
        ? lists.first
        : await repository.create(
            'Meal plan — ${Formatters.shortDate(_weekStart)}',
          );
    const uuid = Uuid();
    for (final name in missing) {
      await ref
          .read(shoppingListRepositoryProvider)
          .addItem(
            list.id,
            ShoppingItem(id: uuid.v4(), listId: list.id, name: name),
          );
    }
    if (mounted) {
      context.showSnack('Added ${missing.length} item(s) to ${list.name}');
    }
  }

  Future<void> _confirmRegenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          "Replace this week's plan? The current plan will be overwritten.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _generate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal planner'),
        actions: [
          if (_plan != null)
            IconButton(
              tooltip: 'Generate new plan',
              onPressed: _generating ? null : _confirmRegenerate,
              icon: const Icon(Icons.auto_awesome_rounded),
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const ListSkeleton();
    if (_generating && _plan == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Building your meal plan…'),
          ],
        ),
      );
    }
    final plan = _plan;
    if (plan == null) {
      return EmptyState(
        icon: Icons.restaurant_menu_rounded,
        title: 'No meal plan yet',
        message:
            'Generate a plan based on your pantry, dietary '
            'preferences, and budget.',
        actionLabel: 'Generate plan',
        onAction: _generate,
      );
    }
    final weekEnd = _weekStart.add(const Duration(days: 6));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Formatters.shortDate(_weekStart)} – ${Formatters.shortDate(weekEnd)}',
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.meals.length} meals planned',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.currency(plan.estimatedCost),
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final meal in plan.meals)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MealCard(
              meal: meal,
              onAddMissing: () => _addMissingToList(meal),
            ),
          ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onAddMissing});

  final PlannedMeal meal;
  final VoidCallback onAddMissing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  meal.day,
                  style: context.text.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meal.type,
                    style: context.text.labelSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                if (meal.estimatedCost != null)
                  Text(
                    Formatters.currency(meal.estimatedCost!),
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              meal.name,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (meal.ingredients.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final ingredient in meal.ingredients)
                    _IngredientChip(
                      name: ingredient,
                      covered: meal.usesPantry.contains(ingredient),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAddMissing,
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                label: const Text('Add missing to list'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.name, required this.covered});

  final String name;
  final bool covered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: covered ? colors.primaryContainer : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (covered) ...[
            Icon(
              Icons.check_rounded,
              size: 14,
              color: colors.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            name,
            style: context.text.labelMedium?.copyWith(
              color: covered
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
