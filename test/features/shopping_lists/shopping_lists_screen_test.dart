import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/theme/app_theme.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/data/shopping_list_repositories.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list_repository.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/presentation/shopping_lists_screen.dart';

class _FakeListRepository implements ShoppingListRepository {
  _FakeListRepository(this._lists);

  final List<ShoppingList> _lists;

  @override
  Future<List<ShoppingList>> lists() async => _lists;

  @override
  Future<ShoppingList?> byId(String id) async =>
      _lists.where((l) => l.id == id).firstOrNull;

  @override
  Future<ShoppingList> create(String name, {double? budget}) =>
      throw UnimplementedError();

  @override
  Future<void> rename(String id, String name, {double? budget}) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<ShoppingList> duplicate(String id) => throw UnimplementedError();

  @override
  Future<void> addItem(String listId, ShoppingItem item) async {}

  @override
  Future<void> updateItem(ShoppingItem item, {bool fieldsEdit = false}) async {}

  @override
  Future<void> removeItem(String listId, String itemId) async {}
}

void main() {
  testWidgets('renders lists with progress', (tester) async {
    final lists = [
      ShoppingList(
        id: '1',
        userId: 'u',
        name: 'Weekly groceries',
        budget: 60,
        createdAt: DateTime(2026, 7, 1),
        items: const [
          ShoppingItem(id: 'a', listId: '1', name: 'Milk', checked: true),
          ShoppingItem(id: 'b', listId: '1', name: 'Eggs'),
        ],
      ),
      ShoppingList(
        id: '2',
        userId: 'u',
        name: 'BBQ party',
        createdAt: DateTime(2026, 7, 2),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            _FakeListRepository(lists),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ShoppingListsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weekly groceries'), findsOneWidget);
    expect(find.text('BBQ party'), findsOneWidget);
    expect(find.textContaining('1/2 items'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });

  testWidgets('shows empty state when no lists', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            _FakeListRepository([]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ShoppingListsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No lists yet'), findsOneWidget);
  });
}
