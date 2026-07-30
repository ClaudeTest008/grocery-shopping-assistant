import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_collection.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/pantry_item.dart';
import '../domain/pantry_repository.dart';

class DemoPantryRepository implements PantryRepository {
  DemoPantryRepository(LocalStore store)
    : _items = DemoCollection(
        store,
        'demo_pantry',
        fromJson: PantryItem.fromJson,
        toJson: (i) => i.toJson(),
        seed: _seed,
      );

  final DemoCollection<PantryItem> _items;

  static List<PantryItem> _seed() {
    const uuid = Uuid();
    final now = DateTime.now();
    PantryItem item(
      String name,
      double qty,
      String unit,
      int? expiresDays,
      String location,
    ) => PantryItem(
      id: uuid.v4(),
      userId: DemoSeed.demoUserId,
      name: name,
      quantity: qty,
      unit: unit,
      expiresAt: expiresDays == null
          ? null
          : now.add(Duration(days: expiresDays)),
      location: location,
      addedAt: now,
    );
    return [
      item('Long Grain Rice', 1.5, 'lb', null, 'pantry'),
      item('Black Beans', 4, 'can', null, 'pantry'),
      item('Spaghetti', 1, 'box', null, 'pantry'),
      item('Olive Oil', 0.5, 'bottle', null, 'pantry'),
      item('Soy Sauce', 1, 'bottle', null, 'pantry'),
      item('Greek Yogurt', 1, 'tub', 2, 'fridge'),
      item('Whole Milk', 0.3, 'gal', 3, 'fridge'),
      item('Shredded Cheddar', 1, 'bag', 12, 'fridge'),
      item('Frozen Broccoli', 2, 'bag', 60, 'freezer'),
      item('Chicken Thighs', 1, 'lb', 1, 'fridge'),
    ];
  }

  @override
  Future<List<PantryItem>> items() async {
    final all = _items.load();
    all.sort((a, b) {
      final ax = a.expiresAt, bx = b.expiresAt;
      if (ax == null && bx == null) return a.name.compareTo(b.name);
      if (ax == null) return 1;
      if (bx == null) return -1;
      return ax.compareTo(bx);
    });
    return all;
  }

  @override
  Future<void> upsert(PantryItem item) =>
      _items.upsert(item, (i) => i.id == item.id);

  @override
  Future<void> remove(String id) => _items.removeWhere((i) => i.id == id);
}

class SupabasePantryRepository implements PantryRepository {
  SupabasePantryRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.requireUserId;

  @override
  Future<List<PantryItem>> items() async {
    final rows = await _client
        .from('pantry')
        .select()
        .eq('user_id', _userId)
        .order('expires_at', ascending: true, nullsFirst: false);
    return rows.map(PantryItem.fromJson).toList();
  }

  @override
  Future<void> upsert(PantryItem item) =>
      _client.from('pantry').upsert(item.toJson());

  @override
  Future<void> remove(String id) =>
      _client.from('pantry').delete().eq('id', id);
}

final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  if (AppConfig.isDemoMode) {
    return DemoPantryRepository(ref.watch(localStoreProvider));
  }
  return SupabasePantryRepository(ref.watch(supabaseClientProvider));
});
