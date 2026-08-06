import '../observability/telemetry.dart';
import '../storage/local_store.dart';

/// Hive-persisted JSON collection backing demo-mode user data
/// (lists, pantry, receipts, meal plans). Survives restarts so the demo
/// feels like a real account.
class DemoCollection<T> {
  DemoCollection(
    this._store,
    this._key, {
    required this._fromJson,
    required this._toJson,
    this._seed,
  });

  final LocalStore _store;
  final String _key;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;
  final List<T> Function()? _seed;

  List<T> load() {
    final cached = _store.getJsonList(_key);
    if (cached != null) {
      // One corrupt row (partial write, entity-shape drift across an
      // app update) must cost that row, not blank the entire
      // collection with a decode crash.
      final out = <T>[];
      for (final doc in cached) {
        try {
          out.add(_fromJson(doc));
        } catch (error, stack) {
          Telemetry.recordError(error, stack);
        }
      }
      return out;
    }
    final seeded = _seed?.call() ?? [];
    if (seeded.isNotEmpty) {
      // Persist the seed so later mutations build on it.
      _store.putJsonList(_key, seeded.map(_toJson).toList());
    }
    return seeded;
  }

  Future<void> saveAll(List<T> items) =>
      _store.putJsonList(_key, items.map(_toJson).toList());

  Future<void> upsert(T item, bool Function(T existing) matches) async {
    final items = load();
    final idx = items.indexWhere(matches);
    if (idx >= 0) {
      items[idx] = item;
    } else {
      items.add(item);
    }
    await saveAll(items);
  }

  Future<void> removeWhere(bool Function(T) test) async {
    final items = load()..removeWhere(test);
    await saveAll(items);
  }
}
