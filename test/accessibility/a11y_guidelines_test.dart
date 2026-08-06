import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/storage/local_store.dart';
import 'package:grocery_shopping_assistant/core/theme/app_theme.dart';
import 'package:grocery_shopping_assistant/features/authentication/presentation/sign_in_screen.dart';
import 'package:grocery_shopping_assistant/features/home/presentation/onboarding_screen.dart';
import 'package:grocery_shopping_assistant/features/settings/presentation/settings_screen.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/data/shopping_list_repositories.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list_repository.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/presentation/shopping_lists_screen.dart';
import 'package:hive/hive.dart';

/// Runs Flutter's built-in accessibility guidelines — minimum tap-target
/// sizes, labelled tappables, and text contrast — against real screens.
/// This is a measured audit, not a code-reading one: a regression in any
/// screen's semantics fails CI.
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

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  ShoppingListRepository? listRepository,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (listRepository != null)
          shoppingListRepositoryProvider.overrideWithValue(listRepository),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

void main() {
  // Settings (preferences) and onboarding (first-run flag) read Hive.
  late Directory tempDir;
  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('a11y_test');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(LocalStore.cacheBox);
    await Hive.openBox<dynamic>(LocalStore.prefsBox);
    await Hive.openBox<dynamic>(LocalStore.pendingOpsBox);
  });
  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  testWidgets('sign-in screen meets a11y guidelines', (tester) async {
    await _pump(tester, const SignInScreen());
    await _expectGuidelines(tester);
  });

  testWidgets('onboarding meets a11y guidelines', (tester) async {
    await _pump(tester, const OnboardingScreen());
    await _expectGuidelines(tester);
  });

  testWidgets('settings meets a11y guidelines', (tester) async {
    await _pump(tester, const SettingsScreen());
    await _expectGuidelines(tester);
  });

  testWidgets('shopping lists meets a11y guidelines', (tester) async {
    await _pump(
      tester,
      const ShoppingListsScreen(),
      listRepository: _FakeListRepository([
        ShoppingList(
          id: '1',
          userId: 'u',
          name: 'Weekly groceries',
          createdAt: DateTime(2026, 7, 1),
          items: const [ShoppingItem(id: 'a', listId: '1', name: 'Milk')],
        ),
      ]),
    );
    await _expectGuidelines(tester);
  });
}
