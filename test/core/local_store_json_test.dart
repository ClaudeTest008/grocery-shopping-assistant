import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/storage/local_store.dart';
import 'package:grocery_shopping_assistant/features/profile/domain/user_preferences.dart';
import 'package:grocery_shopping_assistant/features/receipts/domain/receipt.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list.dart';

/// Hive decodes every stored map as `Map<dynamic, dynamic>`, including
/// nested objects and objects inside lists. Freezed's generated
/// `fromJson` casts those with `as Map<String, dynamic>`, which throws
/// unless the whole tree is converted first. This regression suite pins
/// that behaviour: without it, every persisted list/receipt/meal plan
/// fails to load on the second app launch.
void main() {
  group('normalizeJsonMap', () {
    test('converts nested maps and lists of maps', () {
      final hiveShaped = <dynamic, dynamic>{
        'id': 'l1',
        'nested': <dynamic, dynamic>{
          'deep': <dynamic, dynamic>{'k': 'v'},
        },
        'items': <dynamic>[
          <dynamic, dynamic>{'id': 'i1'},
          <dynamic, dynamic>{'id': 'i2'},
        ],
      };

      final normalized = LocalStore.normalizeJsonMap(hiveShaped);

      expect(normalized, isA<Map<String, dynamic>>());
      expect(normalized['nested'], isA<Map<String, dynamic>>());
      expect(
        (normalized['nested'] as Map<String, dynamic>)['deep'],
        isA<Map<String, dynamic>>(),
      );
      final items = normalized['items'] as List<dynamic>;
      expect(items.every((e) => e is Map<String, dynamic>), isTrue);
    });

    test('leaves primitives and nulls untouched', () {
      final normalized = LocalStore.normalizeJsonMap(<dynamic, dynamic>{
        'n': 42,
        'd': 1.5,
        'b': true,
        's': 'text',
        'nothing': null,
        'empty': <dynamic>[],
      });

      expect(normalized['n'], 42);
      expect(normalized['d'], 1.5);
      expect(normalized['b'], isTrue);
      expect(normalized['s'], 'text');
      expect(normalized['nothing'], isNull);
      expect(normalized['empty'], isEmpty);
    });
  });

  group('round-trips a Hive-shaped document back into an entity', () {
    /// Mimics what Hive returns: toJson() re-typed as dynamic maps.
    Map<dynamic, dynamic> asHiveWouldReturn(Map<String, dynamic> json) {
      Object? degrade(Object? value) => switch (value) {
        final Map<String, dynamic> m => <dynamic, dynamic>{
          for (final e in m.entries) e.key: degrade(e.value),
        },
        final List<dynamic> l => <dynamic>[for (final v in l) degrade(v)],
        _ => value,
      };
      return degrade(json)! as Map<dynamic, dynamic>;
    }

    test('ShoppingList with items', () {
      final original = ShoppingList(
        id: 'l1',
        userId: 'u1',
        name: 'Weekly groceries',
        budget: 60,
        createdAt: DateTime(2026, 7, 10),
        items: const [
          ShoppingItem(id: 'a', listId: 'l1', name: 'Milk', quantity: 2),
          ShoppingItem(id: 'b', listId: 'l1', name: 'Eggs', checked: true),
        ],
      );

      final restored = ShoppingList.fromJson(
        LocalStore.normalizeJsonMap(asHiveWouldReturn(original.toJson())),
      );

      expect(restored.name, 'Weekly groceries');
      expect(restored.items, hasLength(2));
      expect(restored.items.first.name, 'Milk');
      expect(restored.items.last.checked, isTrue);
    });

    test('Receipt with line items', () {
      final original = Receipt(
        id: 'r1',
        userId: 'u1',
        storeName: 'Aldi',
        total: 12.5,
        purchasedAt: DateTime(2026, 7, 1),
        items: const [
          ReceiptItem(id: 'ri1', receiptId: 'r1', name: 'Bananas', price: 1.16),
        ],
      );

      final restored = Receipt.fromJson(
        LocalStore.normalizeJsonMap(asHiveWouldReturn(original.toJson())),
      );

      expect(restored.storeName, 'Aldi');
      expect(restored.items.single.name, 'Bananas');
    });

    test('UserPreferences with list fields', () {
      const original = UserPreferences(
        dietaryRestrictions: ['vegan', 'gluten_free'],
        favoriteStoreIds: ['aldi-1'],
        monthlyBudget: 400,
      );

      final restored = UserPreferences.fromJson(
        LocalStore.normalizeJsonMap(asHiveWouldReturn(original.toJson())),
      );

      expect(restored.dietaryRestrictions, ['vegan', 'gluten_free']);
      expect(restored.favoriteStoreIds, ['aldi-1']);
      expect(restored.monthlyBudget, 400);
    });
  });
}
