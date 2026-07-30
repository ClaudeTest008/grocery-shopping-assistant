import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_store.dart';

/// A mutation that could not reach the server and must not be lost.
@immutable
class PendingOp {
  const PendingOp({
    required this.key,
    required this.kind,
    required this.payload,
  });

  /// Hive's auto-increment key, used to delete the entry once applied.
  final int key;

  /// What to replay, e.g. `check_off`.
  final String kind;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {'kind': kind, 'payload': payload};
}

/// Durable outbox for writes made while offline.
///
/// A grocery app is used inside a steel-shelved building with one bar of
/// signal — ticking items off is exactly the action most likely to
/// happen without a connection, and losing it is invisible to the user
/// until the list is wrong.
///
/// Deliberately narrow: it replays whole operations in order and drops
/// any it cannot parse. It is an outbox, not a sync engine — there is no
/// conflict resolution here because the only queued operation is
/// last-write-wins on a single field.
class PendingOps {
  PendingOps(this._store);

  final LocalStore _store;

  Future<void> enqueue(String kind, Map<String, dynamic> payload) =>
      _store.pendingOps.add({'kind': kind, 'payload': payload});

  int get length => _store.pendingOps.length;

  List<PendingOp> all() {
    final box = _store.pendingOps;
    return [
      for (final key in box.keys)
        if (box.get(key) case final Map<dynamic, dynamic> raw)
          if (LocalStore.normalizeJsonMap(raw) case final json)
            if (json['kind'] case final String kind)
              PendingOp(
                key: key as int,
                kind: kind,
                payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
              ),
    ];
  }

  /// Replays every queued operation in the order it was made. An entry is
  /// removed only once [apply] succeeds, so a still-broken connection
  /// leaves the queue intact for the next attempt.
  Future<int> drain(Future<void> Function(PendingOp op) apply) async {
    var applied = 0;
    for (final op in all()) {
      try {
        await apply(op);
        await _store.pendingOps.delete(op.key);
        applied++;
      } catch (_) {
        // Still unreachable — stop and keep the rest queued rather than
        // hammering a dead connection.
        break;
      }
    }
    return applied;
  }

  Future<void> clear() => _store.pendingOps.clear();
}

final pendingOpsProvider = Provider<PendingOps>(
  (ref) => PendingOps(ref.watch(localStoreProvider)),
);
