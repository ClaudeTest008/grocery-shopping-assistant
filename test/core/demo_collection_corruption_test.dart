import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/demo/demo_collection.dart';
import 'package:grocery_shopping_assistant/core/storage/local_store.dart';
import 'package:grocery_shopping_assistant/features/shopping_lists/domain/shopping_list.dart';
import 'package:hive/hive.dart';

/// Corrupted-local-storage resilience: a bad row (partial write,
/// entity-shape drift across app versions) must cost that row, never
/// the whole collection — the reliability failure mode is "my lists
/// vanished", and it must not exist.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('demo_corruption_test');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(LocalStore.cacheBox);
    await Hive.openBox<dynamic>(LocalStore.prefsBox);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  DemoCollection<ShoppingList> collection() => DemoCollection(
    LocalStore.instance,
    'corruption_test_lists',
    fromJson: ShoppingList.fromJson,
    toJson: (l) => l.toJson(),
  );

  test(
    'a corrupt row is skipped, the rest of the collection survives',
    () async {
      final good = ShoppingList(
        id: 'ok',
        userId: 'u1',
        name: 'Survivor',
        createdAt: DateTime(2026, 8, 1),
      );
      // Store one valid document and one that decodes but cannot parse
      // (missing required fields) — as a partial write would leave it.
      await LocalStore.instance.putJsonList('corruption_test_lists', [
        good.toJson(),
        {'id': 'broken'},
      ]);

      final loaded = collection().load();

      expect(loaded, hasLength(1));
      expect(loaded.single.name, 'Survivor');
    },
  );

  test('an entirely non-map cache value degrades to the seed path', () async {
    await LocalStore.instance.cache.put('corruption_test_lists', 'garbage');
    expect(collection().load(), isEmpty, reason: 'no seed configured');
  });
}
