import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/storage/local_store.dart';
import 'package:grocery_shopping_assistant/features/products/data/price_observation_repository.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price_observation.dart';
import 'package:hive/hive.dart';

/// Demo-mode observations persist in Hive and come back as typed
/// history points — including after the box round-trips to disk (the
/// nested-map decode class of bug this codebase has been bitten by).
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('price_obs_test');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(LocalStore.cacheBox);
    await Hive.openBox<dynamic>(LocalStore.prefsBox);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('records and serves points per product, oldest first', () async {
    final repo = DemoPriceObservationRepository(LocalStore.instance);
    await repo.record(
      PriceObservation(
        id: 'b',
        productId: 'milk',
        storeId: 'aldi-1',
        price: 3.29,
        source: 'community',
        observedAt: DateTime(2026, 8, 2),
      ),
    );
    await repo.record(
      PriceObservation(
        id: 'a',
        productId: 'milk',
        price: 3.49,
        source: 'receipt',
        observedAt: DateTime(2026, 7, 20),
      ),
    );
    await repo.record(
      PriceObservation(
        id: 'c',
        productId: 'eggs',
        price: 2.19,
        source: 'receipt',
        observedAt: DateTime(2026, 8, 1),
      ),
    );

    final points = await repo.observationsFor('milk');
    expect(points, hasLength(2));
    expect(points.first.price, 3.49, reason: 'oldest first');
    expect(points.first.source, 'receipt');
    expect(points.last.storeId, 'aldi-1');
    expect(await repo.observationsFor('eggs'), hasLength(1));
  });

  test('survives a fresh repository instance reading the same store', () async {
    await DemoPriceObservationRepository(LocalStore.instance).record(
      PriceObservation(
        id: 'a',
        productId: 'milk',
        price: 3.49,
        source: 'receipt',
        observedAt: DateTime(2026, 7, 20),
      ),
    );

    final points = await DemoPriceObservationRepository(
      LocalStore.instance,
    ).observationsFor('milk');
    expect(points.single.price, 3.49);
  });
}
