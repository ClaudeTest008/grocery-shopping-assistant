import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/meal_planner/domain/meal_plan.dart';
import '../../features/pantry/domain/pantry_item.dart';
import '../../features/shopping_lists/domain/shopping_list.dart';
import '../errors/failures.dart';
import 'llm_client.dart';
import 'llm_provider.dart';

/// Typed AI use cases built on the provider-agnostic [LlmClient].
/// Prompts embed `[intent:...]` markers that the mock client keys off,
/// so every feature works in demo mode; real providers simply ignore
/// the marker.
class AiServices {
  AiServices(this._llm);

  final LlmClient _llm;
  static const _uuid = Uuid();

  Future<MealPlan> generateMealPlan({
    required String userId,
    required DateTime weekStart,
    required List<PantryItem> pantry,
    List<String> dietaryRestrictions = const [],
    List<String> discountedProducts = const [],
    double? weeklyBudget,
  }) async {
    final response = await _llm.complete(
      LlmRequest(
        system:
            'You are a budget meal planner. [intent:meal_plan] Reply with ONLY '
            'a JSON object: {"meals":[{"day","type","name","usesPantry":[],'
            '"ingredients":[],"estimatedCost"}]}. 5 dinners, Monday-Friday.',
        messages: [
          LlmMessage.user(
            jsonEncode({
              'pantry': [
                for (final p in pantry) '${p.name} (${p.quantity} ${p.unit})',
              ],
              'dietary_restrictions': dietaryRestrictions,
              'currently_discounted': discountedProducts,
              'weekly_budget': weeklyBudget,
            }),
          ),
        ],
        jsonMode: true,
        maxTokens: 1500,
      ),
    );
    final json = _decodeMap(response);
    final meals = (json['meals'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(
          (m) => PlannedMeal(
            day: m['day'] as String? ?? 'Monday',
            type: m['type'] as String? ?? 'dinner',
            name: m['name'] as String? ?? 'Meal',
            ingredients: (m['ingredients'] as List? ?? const []).cast<String>(),
            usesPantry: (m['usesPantry'] as List? ?? const []).cast<String>(),
            estimatedCost: (m['estimatedCost'] as num?)?.toDouble(),
          ),
        )
        .toList();
    if (meals.isEmpty) throw const AiFailure('No meals generated');
    return MealPlan(
      id: _uuid.v4(),
      userId: userId,
      weekStart: weekStart,
      meals: meals,
      createdAt: DateTime.now(),
    );
  }

  /// Generates shopping list items from a natural-language goal,
  /// e.g. "healthy breakfasts for two under $25".
  Future<(String name, List<ShoppingItem> items)> generateShoppingList({
    required String goal,
    required String listId,
    double? budget,
    List<String> dietaryRestrictions = const [],
  }) async {
    final response = await _llm.complete(
      LlmRequest(
        system:
            'You build grocery lists. [intent:generate_list] Reply with '
            'ONLY JSON: {"name","items":[{"name","quantity","unit",'
            '"estimatedPrice"}],"estimatedTotal","notes"}.',
        messages: [
          LlmMessage.user(
            jsonEncode({
              'goal': goal,
              'budget': budget,
              'dietary_restrictions': dietaryRestrictions,
            }),
          ),
        ],
        jsonMode: true,
        maxTokens: 1200,
      ),
    );
    final json = _decodeMap(response);
    final items = (json['items'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(
          (i) => ShoppingItem(
            id: _uuid.v4(),
            listId: listId,
            name: i['name'] as String? ?? 'Item',
            quantity: (i['quantity'] as num?)?.toDouble() ?? 1,
            unit: i['unit'] as String? ?? 'ea',
            estimatedPrice: (i['estimatedPrice'] as num?)?.toDouble(),
          ),
        )
        .toList();
    if (items.isEmpty) throw const AiFailure('No items generated');
    return (json['name'] as String? ?? goal, items);
  }

  /// Cheaper / dietary-compatible substitutions for expensive items.
  Future<List<Map<String, dynamic>>> suggestSubstitutions(
    List<String> itemNames, {
    List<String> dietaryRestrictions = const [],
  }) async {
    final response = await _llm.complete(
      LlmRequest(
        system:
            'You suggest cheaper grocery substitutions. '
            '[intent:substitute] Reply with ONLY JSON: {"substitutions":'
            '[{"original","replacement","savings","reason"}]}.',
        messages: [
          LlmMessage.user(
            jsonEncode({
              'items': itemNames,
              'dietary_restrictions': dietaryRestrictions,
            }),
          ),
        ],
        jsonMode: true,
      ),
    );
    return (_decodeMap(response)['substitutions'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
  }

  /// Conversational rationale for a basket-optimizer option.
  Future<String> explainTrip({
    required List<String> storeNames,
    required double itemsTotal,
    required double couponSavings,
    required double travelCost,
    required int travelMinutes,
    required double totalCost,
    required bool recommended,
  }) => _llm.complete(
    LlmRequest(
      system:
          'You explain grocery trip recommendations in 2-3 friendly, '
          'concrete sentences with dollar amounts. [intent:explain_trip]',
      messages: [
        LlmMessage.user(
          jsonEncode({
            'stores': storeNames,
            'items_total': itemsTotal,
            'coupon_savings': couponSavings,
            'travel_cost': travelCost,
            'travel_minutes': travelMinutes,
            'total_cost': totalCost,
            'is_recommended': recommended,
          }),
        ),
      ],
      maxTokens: 300,
    ),
  );

  Future<String> summarizeReceipt(Map<String, dynamic> receiptJson) =>
      _llm.complete(
        LlmRequest(
          system:
              'Summarize this grocery receipt for the shopper in 2-3 '
              'sentences, noting anything priced above its usual range. '
              '[intent:receipt_summary]',
          messages: [LlmMessage.user(jsonEncode(receiptJson))],
          maxTokens: 300,
        ),
      );

  /// Free-form assistant chat with app context injected.
  Future<String> chat(List<LlmMessage> history, {String? contextSummary}) =>
      _llm.complete(
        LlmRequest(
          system:
              'You are a grocery shopping assistant inside a mobile app. '
              'You help with budgets, meal plans, price timing, and cheaper '
              'alternatives. Be concise and concrete with dollar amounts. '
              '${contextSummary ?? ''}',
          messages: history,
          maxTokens: 800,
        ),
      );

  Map<String, dynamic> _decodeMap(String raw) {
    try {
      return jsonDecode(extractJson(raw)) as Map<String, dynamic>;
    } catch (e) {
      throw AiFailure('Model returned malformed JSON', e);
    }
  }
}

final aiServicesProvider = Provider<AiServices>(
  (ref) => AiServices(ref.watch(llmClientProvider)),
);
