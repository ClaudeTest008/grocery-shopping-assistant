import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    await Hive.initFlutter();
    for (final name in _boxNames) {
      await Hive.openBox<dynamic>(name);
    }
  }

  Box<dynamic> get cache => Hive.box<dynamic>(cacheBox);
  Box<dynamic> get prefs => Hive.box<dynamic>(prefsBox);
  Box<dynamic> get pendingOps => Hive.box<dynamic>(pendingOpsBox);

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
    return docs
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  static final _instance = LocalStore._();
  static LocalStore get instance => _instance;
}

final localStoreProvider = Provider<LocalStore>((_) => LocalStore.instance);
