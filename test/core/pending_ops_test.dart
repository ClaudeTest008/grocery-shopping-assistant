import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/storage/local_store.dart';
import 'package:grocery_shopping_assistant/core/storage/pending_ops.dart';
import 'package:hive/hive.dart';

/// The outbox exists so that ticking items off with no signal is not
/// silently discarded. Its contract: survive a restart, replay in order,
/// and keep anything that could not be applied.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pending_ops_test');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(LocalStore.cacheBox);
    await Hive.openBox<dynamic>(LocalStore.prefsBox);
    await Hive.openBox<dynamic>(LocalStore.pendingOpsBox);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  PendingOps queue() => PendingOps(LocalStore.instance);

  test('queues and reads back operations with their payload', () async {
    final ops = queue();
    await ops.enqueue('check_off', {'id': 'a', 'checked': true});

    final all = ops.all();
    expect(all, hasLength(1));
    expect(all.single.kind, 'check_off');
    expect(all.single.payload['id'], 'a');
    // Nested Hive maps must come back correctly typed, same as the
    // rest of local storage.
    expect(all.single.payload, isA<Map<String, dynamic>>());
  });

  test('replays in the order the changes were made', () async {
    final ops = queue();
    for (final id in ['a', 'b', 'c']) {
      await ops.enqueue('check_off', {'id': id});
    }

    final seen = <String>[];
    final applied = await ops.drain((op) async {
      seen.add(op.payload['id'] as String);
    });

    expect(applied, 3);
    expect(seen, ['a', 'b', 'c']);
    expect(ops.length, 0, reason: 'applied entries are removed');
  });

  test('keeps everything from the first failure onward', () async {
    final ops = queue();
    for (final id in ['a', 'b', 'c']) {
      await ops.enqueue('check_off', {'id': id});
    }

    final applied = await ops.drain((op) async {
      if (op.payload['id'] == 'b') throw Exception('still offline');
    });

    expect(applied, 1, reason: 'only "a" got through');
    expect(ops.length, 2, reason: 'b and c stay queued for the next attempt');
    expect(ops.all().first.payload['id'], 'b');
  });

  test('survives the box being reopened, as after an app restart', () async {
    await queue().enqueue('check_off', {'id': 'a'});

    await Hive.box<dynamic>(LocalStore.pendingOpsBox).close();
    await Hive.openBox<dynamic>(LocalStore.pendingOpsBox);

    expect(queue().all().single.payload['id'], 'a');
  });
}
