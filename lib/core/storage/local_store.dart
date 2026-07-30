import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../platform/platform_support.dart';

/// Hive-backed key/value + JSON document cache.
///
/// All values are stored as JSON-compatible maps/lists/primitives, so no
/// Hive type adapters are needed and entities stay Hive-agnostic.
class LocalStore {
  LocalStore._();

  static const _boxNames = [cacheBox, prefsBox, pendingOpsBox];

  static const cacheBox = 'cache';
  static const prefsBox = 'prefs';
  static const pendingOpsBox = 'pending_ops';

  static Future<void> init() async {
    // On desktop `initFlutter()` drops box files loose in the user's
    // Documents folder; give them their own directory there. Mobile
    // storage is already app-private, so leave that path untouched.
    await Hive.initFlutter(
      PlatformSupport.isDesktop ? 'GroceryShoppingAssistant' : null,
    );
    for (final name in _boxNames) {
      await Hive.openBox<dynamic>(name);
    }
  }

  Box<dynamic> get cache => Hive.box<dynamic>(cacheBox);
  Box<dynamic> get prefs => Hive.box<dynamic>(prefsBox);
  Box<dynamic> get pendingOps => Hive.box<dynamic>(pendingOpsBox);

  /// Demo reset: clears every box (lists, pantry, receipts, prefs,
  /// onboarding flag...). Caller is responsible for rebuilding app state
  /// afterwards (see AppBootstrap.restart).
  Future<void> wipe() async {
    for (final name in _boxNames) {
      await Hive.box<dynamic>(name).clear();
    }
  }

  /// Cache a JSON document list under [key] with a freshness timestamp.
  Future<void> putJsonList(String key, List<Map<String, dynamic>> docs) =>
      cache.put(key, {'at': DateTime.now().toIso8601String(), 'docs': docs});

  /// Returns cached docs, or null when absent/older than [maxAge].
  List<Map<String, dynamic>>? getJsonList(String key, {Duration? maxAge}) {
    final raw = cache.get(key);
    if (raw is! Map) return null;
    if (maxAge != null) {
      final at = DateTime.tryParse(raw['at'] as String? ?? '');
      if (at == null || DateTime.now().difference(at) > maxAge) return null;
    }
    final docs = raw['docs'];
    if (docs is! List) return null;
    return docs.whereType<Map>().map(normalizeJsonMap).toList();
  }

  /// Reads a single JSON document, deeply typed for `fromJson`.
  Map<String, dynamic>? getJsonMap(Box<dynamic> box, String key) {
    final raw = box.get(key);
    return raw is Map ? normalizeJsonMap(raw) : null;
  }

  /// Hive hands back every decoded map as `Map<dynamic, dynamic>`.
  /// `Map<String, dynamic>.from` only fixes the *outermost* level, so any
  /// nested object or list-of-objects still fails the
  /// `as Map<String, dynamic>` casts that `fromJson` performs — which is
  /// why persisted lists, receipts and meal plans blew up on the second
  /// launch. Convert the whole tree instead.
  static Map<String, dynamic> normalizeJsonMap(Map<dynamic, dynamic> source) =>
      {
        for (final entry in source.entries)
          entry.key.toString(): _normalizeJsonValue(entry.value),
      };

  static Object? _normalizeJsonValue(Object? value) => switch (value) {
    final Map<dynamic, dynamic> map => normalizeJsonMap(map),
    final List<dynamic> list => [
      for (final item in list) _normalizeJsonValue(item),
    ],
    _ => value,
  };

  static final _instance = LocalStore._();
  static LocalStore get instance => _instance;
}

final localStoreProvider = Provider<LocalStore>((_) => LocalStore.instance);
